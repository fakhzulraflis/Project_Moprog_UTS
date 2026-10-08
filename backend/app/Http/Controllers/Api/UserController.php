<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

/**
 * Melihat dan berinteraksi dengan user lain: cari, lihat profil, daftar
 * following/followers, like, blokir, dan laporkan.
 * Semua query memakai id user dari token, dan user yang saling memblokir
 * tidak akan muncul satu sama lain.
 */
class UserController extends Controller
{
    public const REPORT_REASONS = [
        'inappropriate_name',
        'spam',
        'harassment',
        'other',
    ];

    // GET /api/users/search?q=
    // Tanpa q: saran user. Dengan q: user yang username/namanya cocok.
    public function search(Request $request): JsonResponse
    {
        $me = $request->user();
        $q = trim((string) $request->query('q', ''));

        $query = User::query()
            ->where('id', '!=', $me->id)
            ->whereNotIn('id', $this->hiddenIds($me->id));

        if ($q !== '') {
            $like = '%'.addcslashes(ltrim($q, '@'), '%_\\').'%';
            $query->where(fn ($w) => $w->where('username', 'like', $like)->orWhere('name', 'like', $like));
        }

        $users = $query->orderBy('username')->limit(20)->get();

        return response()->json(['data' => $this->present($users, $me)]);
    }

    // GET /api/users/{id}
    public function show(Request $request, int $id): JsonResponse
    {
        $me = $request->user();
        $user = User::find($id);

        if (! $user || $this->hiddenIds($me->id)->contains($id)) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        return response()->json(['data' => $this->present(collect([$user]), $me)->first()]);
    }

    // GET /api/profile/following
    public function following(Request $request): JsonResponse
    {
        $me = $request->user();
        $users = $me->following()
            ->whereNotIn('users.id', $this->hiddenIds($me->id))
            ->orderBy('username')
            ->get();

        return response()->json(['data' => $this->present($users, $me)]);
    }

    // GET /api/profile/followers
    public function followers(Request $request): JsonResponse
    {
        $me = $request->user();
        $users = $me->followers()
            ->whereNotIn('users.id', $this->hiddenIds($me->id))
            ->orderBy('username')
            ->get();

        return response()->json(['data' => $this->present($users, $me)]);
    }

    // POST /api/users/{id}/like  (toggle)
    public function toggleLike(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        if ($error = $this->guardTarget($me->id, $id)) {
            return $error;
        }

        $row = ['liker_id' => $me->id, 'liked_id' => $id];

        if (DB::table('user_likes')->where($row)->exists()) {
            DB::table('user_likes')->where($row)->delete();
        } else {
            DB::table('user_likes')->insert($row + ['created_at' => now(), 'updated_at' => now()]);
        }

        return response()->json(['data' => $this->present(collect([User::find($id)]), $me)->first()]);
    }

    // POST /api/users/{id}/block  (toggle blokir / buka blokir)
    public function toggleBlock(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        if ($me->id === $id) {
            return response()->json(['message' => 'You cannot block yourself.'], 422);
        }
        if (! User::whereKey($id)->exists()) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        $row = ['blocker_id' => $me->id, 'blocked_id' => $id];

        if (DB::table('user_blocks')->where($row)->exists()) {
            DB::table('user_blocks')->where($row)->delete();

            return response()->json(['blocked' => false]);
        }

        DB::table('user_blocks')->insert($row + ['created_at' => now(), 'updated_at' => now()]);

        // Blokir memutus follow di kedua arah
        DB::table('follows')->where(['follower_id' => $me->id, 'followed_id' => $id])->delete();
        DB::table('follows')->where(['follower_id' => $id, 'followed_id' => $me->id])->delete();

        return response()->json(['blocked' => true]);
    }

    // GET /api/profile/blocked
    public function blocked(Request $request): JsonResponse
    {
        $me = $request->user();
        $ids = DB::table('user_blocks')->where('blocker_id', $me->id)->pluck('blocked_id');
        $users = User::whereIn('id', $ids)->orderBy('username')->get();

        return response()->json(['data' => $this->present($users, $me)]);
    }

    // POST /api/users/{id}/report
    public function report(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        $validated = $request->validate([
            'reason' => ['required', 'string', 'in:'.implode(',', self::REPORT_REASONS)],
        ]);

        if ($me->id === $id) {
            return response()->json(['message' => 'You cannot report yourself.'], 422);
        }
        if (! User::whereKey($id)->exists()) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        DB::table('user_reports')->insert([
            'reporter_id' => $me->id,
            'reported_id' => $id,
            'reason' => $validated['reason'],
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['message' => 'Report sent. Thank you!'], 201);
    }

    // Id user yang tidak boleh terlihat: yang saya blokir dan yang memblokir saya.
    public static function hiddenIds(int $meId): Collection
    {
        return DB::table('user_blocks')->where('blocker_id', $meId)->pluck('blocked_id')
            ->merge(DB::table('user_blocks')->where('blocked_id', $meId)->pluck('blocker_id'))
            ->unique()
            ->values();
    }

    private function guardTarget(int $meId, int $targetId): ?JsonResponse
    {
        if ($meId === $targetId) {
            return response()->json(['message' => 'You cannot do that to yourself.'], 422);
        }
        if (! User::whereKey($targetId)->exists() || self::hiddenIds($meId)->contains($targetId)) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        return null;
    }

    // Bentuk data publik user, sekaligus hitung semuanya dengan query massal.
    private function present(Collection $users, User $me): Collection
    {
        $ids = $users->pluck('id');

        $following = DB::table('follows')->where('follower_id', $me->id)->whereIn('followed_id', $ids)->pluck('followed_id');
        $liked = DB::table('user_likes')->where('liker_id', $me->id)->whereIn('liked_id', $ids)->pluck('liked_id');
        $likeCounts = DB::table('user_likes')->whereIn('liked_id', $ids)->select('liked_id', DB::raw('count(*) as c'))->groupBy('liked_id')->pluck('c', 'liked_id');
        $followerCounts = DB::table('follows')->whereIn('followed_id', $ids)->select('followed_id', DB::raw('count(*) as c'))->groupBy('followed_id')->pluck('c', 'followed_id');
        $followingCounts = DB::table('follows')->whereIn('follower_id', $ids)->select('follower_id', DB::raw('count(*) as c'))->groupBy('follower_id')->pluck('c', 'follower_id');
        $blocked = DB::table('user_blocks')->where('blocker_id', $me->id)->whereIn('blocked_id', $ids)->pluck('blocked_id');

        return $users->filter()->map(fn (User $u) => [
            'id' => $u->id,
            'fullname' => $u->name,
            'username' => $u->username,
            'learning_language' => $u->learning_language ?? 'English',
            'avatar_character' => $u->avatar_character,
            'joined_at' => optional($u->created_at)->toIso8601String(),
            'following_count' => (int) ($followingCounts[$u->id] ?? 0),
            'followers_count' => (int) ($followerCounts[$u->id] ?? 0),
            'like_count' => (int) ($likeCounts[$u->id] ?? 0),
            'is_following' => $following->contains($u->id),
            'liked' => $liked->contains($u->id),
            'blocked' => $blocked->contains($u->id),
        ])->values();
    }
}
