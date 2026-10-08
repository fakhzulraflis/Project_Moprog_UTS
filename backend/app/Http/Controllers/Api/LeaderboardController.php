<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\Leaderboard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LeaderboardController extends Controller
{
    // GET /api/leaderboard
    // Semua user diurutkan dari XP tertinggi. Boleh dibuka tanpa login; kalau
    // ada token, user yang saling blokir disembunyikan dan baris milik sendiri
    // ditandai.
    public function index(Request $request): JsonResponse
    {
        $me = $request->user('sanctum');

        $users = Leaderboard::ordered(Leaderboard::visible($me?->id))
            ->limit(Leaderboard::LIMIT)
            ->get(['id', 'name', 'username', 'xp', 'learning_language', 'avatar_character']);

        $rows = $users->values()->map(fn (User $u, int $i) => [
            'id' => (string) $u->id,
            'rank' => $i + 1,
            'name' => $u->name,
            'username' => $u->username,
            'xp' => (int) $u->xp,
            'learning_language' => $u->learning_language ?? 'English',
            'avatar_character' => $u->avatar_character,
            'is_me' => $me !== null && $me->id === $u->id,
        ]);

        return response()->json([
            'data' => $rows,
            'meta' => [
                'total' => $rows->count(),
                'my_rank' => $rows->firstWhere('is_me', true)['rank'] ?? null,
            ],
        ]);
    }
}
