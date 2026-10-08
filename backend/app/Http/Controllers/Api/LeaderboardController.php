<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class LeaderboardController extends Controller
{
    // GET /api/leaderboard
    public function index(): JsonResponse
    {
        $users = User::query()
            ->orderByDesc('xp')
            ->orderBy('id') // tie-breaker biar urutan stabil kalau XP sama
            ->limit(50)
            ->get(['id', 'name', 'username', 'xp', 'avatar_path']);

        $data = $users->values()->map(fn (User $u, int $i) => [
            'id' => (string) $u->id,
            'rank' => $i + 1,
            'name' => $u->username ?? $u->name,
            'xp' => (int) $u->xp,
            'avatarUrl' => $u->avatar_path,
        ]);

        return response()->json(['data' => $data]);
    }
}
