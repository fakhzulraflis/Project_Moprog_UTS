<?php

namespace App\Support;

use App\Http\Controllers\Api\UserController;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

/**
 * Aturan urutan leaderboard: XP tertinggi di atas, dan kalau XP sama, akun
 * yang lebih dulu dibuat berada di atas. Aturan ini dipakai oleh daftar
 * leaderboard dan oleh peringkat di profil, supaya angkanya selalu sama.
 */
final class Leaderboard
{
    // Batas jumlah baris yang dikirim sekali jalan.
    public const LIMIT = 500;

    /** User yang boleh dilihat oleh $viewerId (tanpa user yang saling blokir). */
    public static function visible(?int $viewerId): Builder
    {
        $query = User::query();

        if ($viewerId !== null) {
            $query->whereNotIn('id', UserController::hiddenIds($viewerId));
        }

        return $query;
    }

    public static function ordered(Builder $query): Builder
    {
        return $query->orderByDesc('xp')->orderBy('id');
    }

    /** Peringkat (mulai dari 1) sebuah user di antara user yang terlihat. */
    public static function rankOf(User $user, ?int $viewerId = null): int
    {
        // Model yang baru dibuat belum membawa nilai bawaan kolom xp
        $xp = (int) $user->xp;

        return self::visible($viewerId ?? $user->id)
            ->where(fn (Builder $q) => $q
                ->where('xp', '>', $xp)
                ->orWhere(fn (Builder $q2) => $q2->where('xp', $xp)->where('id', '<', $user->id)))
            ->count() + 1;
    }
}
