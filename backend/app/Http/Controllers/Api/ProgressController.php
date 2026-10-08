<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserProgress;
use App\Support\ProgressStats;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * Progres belajar milik user yang sedang login: gem, XP, hati bonus, lesson
 * yang sudah selesai, misi, streak, roda harian, dan peliharaan Quacko.
 *
 * Data selalu dicari berdasarkan user dari token, jadi user tidak bisa
 * membaca atau mengubah progres milik user lain. XP yang tersimpan di sini
 * juga menjadi dasar leaderboard (kolom users.xp).
 */
class ProgressController extends Controller
{
    // Batas ukuran supaya isi progres tidak bisa dipakai menimbun database.
    private const MAX_BYTES = 200_000;

    // GET /api/progress
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        $row = UserProgress::where('user_id', $user->id)->first();

        $data = $row?->data;

        // XP akun (users.xp) adalah acuan; progres di HP harus mulai dari sana.
        if ($data !== null) {
            $data = ProgressStats::merge($data, null, (int) $user->xp);
        }

        return response()->json([
            'data' => [
                // null artinya user ini belum pernah menyimpan progres
                'progress' => $data,
                'xp' => max((int) $user->xp, (int) ($data['totalXp'] ?? 0)),
                'stats' => ProgressStats::fromData($data),
                'updated_at' => $row?->updated_at?->toIso8601String(),
            ],
        ]);
    }

    // PUT /api/progress
    public function update(Request $request): JsonResponse
    {
        $request->validate([
            'progress' => ['required', 'array', 'max:100'],
            'progress.totalXp' => ['nullable', 'integer', 'min:0', 'max:10000000'],
            'progress.gems' => ['nullable', 'integer', 'min:0', 'max:10000000'],
            'progress.bonusHearts' => ['nullable', 'integer', 'min:0', 'max:100000'],
            'progress.streak' => ['nullable', 'integer', 'min:0', 'max:100000'],
            'progress.bestStreak' => ['nullable', 'integer', 'min:0', 'max:100000'],
            'progress.completedLessonIds' => ['nullable', 'array', 'max:5000'],
            'progress.completedLessonIds.*' => ['numeric'],
            'progress.studiedDays' => ['nullable', 'array', 'max:5000'],
            'progress.openedChests' => ['nullable', 'array', 'max:5000'],
        ]);

        $incoming = $request->input('progress');

        if (strlen(json_encode($incoming)) > self::MAX_BYTES) {
            return response()->json(['message' => 'Progress data is too large.'], 422);
        }

        $user = $request->user();

        $saved = DB::transaction(function () use ($user, $incoming) {
            // Kunci baris user ini supaya dua permintaan bersamaan tidak
            // saling menimpa saat digabung.
            $row = UserProgress::where('user_id', $user->id)->lockForUpdate()->first();

            $data = ProgressStats::merge($incoming, $row?->data, (int) $user->fresh()->xp);

            $row = UserProgress::updateOrCreate(['user_id' => $user->id], ['data' => $data]);

            // XP yang sama dipakai leaderboard. Tidak pernah diturunkan.
            $xp = ProgressStats::fromData($data)['xp'];
            if ($xp > (int) $user->xp) {
                $user->forceFill(['xp' => $xp])->save();
            }

            return $row;
        });

        $data = $saved->data;

        return response()->json([
            'data' => [
                'progress' => $data,
                'xp' => (int) $user->fresh()->xp,
                'stats' => ProgressStats::fromData($data),
                'updated_at' => $saved->updated_at?->toIso8601String(),
            ],
        ]);
    }
}
