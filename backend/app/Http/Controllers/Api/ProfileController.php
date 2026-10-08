<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * Profil user yang sedang login + syarat "Complete your profile":
 * mengikuti minimal 1 user dan menyukai minimal 1 postingan.
 */
class ProfileController extends Controller
{
    // GET /api/profile
    public function show(Request $request): JsonResponse
    {
        return response()->json(['data' => $this->payload($request->user())]);
    }

    // Kunci karakter yang boleh dipilih (harus sama dengan AvatarCatalog di Flutter)
    public const AVATARS = [
        'engduck', 'japduck', 'korduck',
        'qua_chef', 'qua_scholar',
        'binbin_cardigan', 'binbin_florist', 'binbin_winter',
    ];

    // PUT /api/profile/avatar
    public function updateAvatar(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'avatar_character' => ['required', 'string', 'in:'.implode(',', self::AVATARS)],
        ]);

        $me = $request->user();
        $me->update(['avatar_character' => $validated['avatar_character']]);

        return response()->json(['data' => $this->payload($me)]);
    }

    // PUT /api/profile/xp
    public function updateXp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'xp' => ['required', 'integer', 'min:0'],
        ]);

        $me = $request->user();
        $me->update(['xp' => $validated['xp']]);

        return response()->json(['data' => $this->payload($me)]);
    }

    // GET /api/profile/suggestions
    public function suggestions(Request $request): JsonResponse
    {
        $me = $request->user();
        $followingIds = $me->following()->pluck('users.id');

        $users = User::query()
            ->where('id', '!=', $me->id)
            ->whereNotIn('id', UserController::hiddenIds($me->id))
            ->orderByDesc('id')
            ->limit(20)
            ->get()
            ->map(fn (User $user) => [
                'id' => $user->id,
                'fullname' => $user->name,
                'username' => $user->username,
                'learning_language' => $user->learning_language ?? 'English',
                'is_following' => $followingIds->contains($user->id),
            ]);

        return response()->json(['data' => $users]);
    }

    // PATCH /api/profile/language (ganti bahasa yang dipelajari)
    public function updateLanguage(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'learning_language' => ['required', 'string', 'in:English,Japanese,Korean'],
        ]);

        $me = $request->user();
        $me->update([
            'learning_language' => $validated['learning_language'],
            'avatar_path' => match ($validated['learning_language']) {
                'Japanese' => 'assets/app/japanese.gif',
                'Korean' => 'assets/app/korean.gif',
                default => 'assets/app/english.gif',
            },
        ]);

        return response()->json(['data' => $this->payload($me)]);
    }

    // POST /api/users/{id}/follow  (toggle: ikuti / berhenti mengikuti)
    public function toggleFollow(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        if ($me->id === $id) {
            return response()->json(['message' => 'You cannot follow yourself.'], 422);
        }

        $target = User::find($id);
        if (! $target || UserController::hiddenIds($me->id)->contains($id)) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        $result = $me->following()->toggle($target->id);

        return response()->json([
            'is_following' => count($result['attached']) > 0,
            'data' => $this->payload($me),
        ]);
    }

    // GET /api/posts
    public function posts(Request $request): JsonResponse
    {
        $meId = $request->user()->id;
        $likedIds = DB::table('post_likes')->where('user_id', $meId)->pluck('post_id');

        $posts = Post::query()
            ->with('user:id,name,username,learning_language')
            ->latest()
            ->limit(20)
            ->get();

        $counts = DB::table('post_likes')
            ->whereIn('post_id', $posts->pluck('id'))
            ->select('post_id', DB::raw('count(*) as total'))
            ->groupBy('post_id')
            ->pluck('total', 'post_id');

        return response()->json([
            'data' => $posts->map(fn (Post $p) => [
                'id' => $p->id,
                'body' => $p->body,
                'author_name' => $p->user?->name,
                'author_username' => $p->user?->username,
                'learning_language' => $p->user?->learning_language ?? 'English',
                'like_count' => (int) ($counts[$p->id] ?? 0),
                'liked' => $likedIds->contains($p->id),
            ]),
        ]);
    }

    // POST /api/posts/{id}/like  (toggle suka / batal suka)
    public function toggleLike(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        if (! Post::whereKey($id)->exists()) {
            return response()->json(['message' => 'Post not found.'], 404);
        }

        $row = ['post_id' => $id, 'user_id' => $me->id];

        if (DB::table('post_likes')->where($row)->exists()) {
            DB::table('post_likes')->where($row)->delete();
            $liked = false;
        } else {
            DB::table('post_likes')->insert($row + [
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $liked = true;
        }

        return response()->json([
            'liked' => $liked,
            'like_count' => DB::table('post_likes')->where('post_id', $id)->count(),
            'data' => $this->payload($me),
        ]);
    }

    private function payload(User $user): array
    {
        $hasFollowed = $user->following()->exists();
        $hasLiked = DB::table('post_likes')->where('user_id', $user->id)->exists();

        return [
            'id' => $user->id,
            'fullname' => $user->name,
            'username' => $user->username,
            'email' => $user->email,
            'learning_language' => $user->learning_language ?? 'English',
            'native_language' => $user->native_language,
            'country' => $user->country,
            'avatar_path' => $user->avatar_path,
            'avatar_character' => $user->avatar_character,
            'xp' => $user->xp,
            'joined_at' => optional($user->created_at)->toIso8601String(),
            'following_count' => $user->following()->count(),
            'followers_count' => $user->followers()->count(),
            'profile_steps' => [
                ['key' => 'follow', 'done' => $hasFollowed],
                ['key' => 'like', 'done' => $hasLiked],
            ],
            'profile_completed' => $hasFollowed && $hasLiked,
        ];
    }
}
