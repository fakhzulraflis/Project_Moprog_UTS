<?php

use App\Models\User;
use App\Models\UserProgress;
use App\Support\ProgressStats;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * - Menghapus tabel `player_progress`. Tabel itu dibuat lebih dulu tetapi
     *   tidak pernah dipakai; progres user disimpan di `user_progress`.
     * - Memberi index pada `users.xp` supaya leaderboard cepat walau user banyak.
     * - Mengisi ulang `users.xp` dari progres yang sudah tersimpan. Sebelumnya
     *   XP hanya terkirim lewat jalur terpisah, sehingga leaderboard bisa
     *   menunjukkan 0 untuk user yang sebenarnya sudah menyelesaikan lesson.
     */
    public function up(): void
    {
        Schema::dropIfExists('player_progress');

        if (! $this->hasIndex('users', 'users_xp_index')) {
            Schema::table('users', function (Blueprint $table) {
                $table->index('xp');
            });
        }

        UserProgress::query()->each(function (UserProgress $row) {
            $xp = ProgressStats::fromData($row->data)['xp'];

            User::query()
                ->whereKey($row->user_id)
                ->where('xp', '<', $xp)
                ->update(['xp' => $xp]);
        });
    }

    public function down(): void
    {
        if ($this->hasIndex('users', 'users_xp_index')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropIndex('users_xp_index');
            });
        }

        // Tabel player_progress sengaja tidak dibuat ulang (tidak pernah dipakai).
    }

    private function hasIndex(string $table, string $index): bool
    {
        foreach (Schema::getIndexes($table) as $existing) {
            if ($existing['name'] === $index) {
                return true;
            }
        }

        return false;
    }
};
