<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserProgress;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

/**
 * Progres halaman Misi milik user yang sedang login. Data selalu dicari
 * berdasarkan user dari token, jadi user tidak bisa membaca atau mengubah
 * progres milik user lain.
 */
class ProgressController extends Controller
{
    // GET /api/progress
    public function show(Request $request): JsonResponse
    {
        $progress = UserProgress::where('user_id', $request->user()->id)->first();

        return response()->json([
            'data' => [
                // null artinya user ini belum pernah menyimpan progres
                'progress' => $progress?->data,
                'updated_at' => $progress?->updated_at?->toIso8601String(),
            ],
        ]);
    }

    // PUT /api/progress
    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'progress' => ['required', 'array', 'max:100'],
            'progress.totalXp' => ['nullable', 'integer', 'min:0'],
            'progress.gems' => ['nullable', 'integer', 'min:0'],
        ]);

        $user = $request->user();

        // validated() hanya berisi kunci yang punya aturan, jadi seluruh
        // isi progres diambil dari input setelah lolos validasi.
        $data = $request->input('progress');

        $progress = UserProgress::updateOrCreate(
            ['user_id' => $user->id],
            ['data' => $data],
        );

        // XP yang sama dipakai leaderboard. Ambil yang paling besar supaya
        // posisi di leaderboard tidak turun.
        $totalXp = (int) ($validated['progress']['totalXp'] ?? 0);
        if (Schema::hasColumn('users', 'xp') && $totalXp > (int) $user->xp) {
            $user->forceFill(['xp' => $totalXp])->save();
        }

        return response()->json([
            'data' => [
                'progress' => $progress->data,
                'updated_at' => $progress->updated_at?->toIso8601String(),
            ],
        ]);
    }
}
