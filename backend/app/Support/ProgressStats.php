<?php

namespace App\Support;

use Carbon\CarbonInterface;

/**
 * Menghitung statistik dari isi progres user (JSON `user_progress.data`).
 * Dipakai bersama oleh sinkronisasi progres, leaderboard, profil, dan seeder,
 * supaya XP, streak, dan jumlah lesson selalu dihitung dengan cara yang sama.
 */
final class ProgressStats
{
    // Harus sama dengan PlayerProgress.xpPerLesson di aplikasi.
    public const XP_PER_LESSON = 10;

    // Hati dasar tiap lesson; hati bonus ditambahkan di atasnya.
    public const BASE_HEARTS = 5;

    // Kunci yang hanya boleh bertambah. Saat disimpan, nilai di server dan
    // nilai dari HP digabung, jadi data yang sudah lama (misalnya dari HP
    // lain) tidak bisa menghapus progres belajar yang sudah tercatat.
    public const UNION_KEYS = [
        'completedLessonIds',
        'studiedDays',
        'claimedStreakMilestones',
        'openedChests',
    ];

    public const MAX_KEYS = ['totalXp', 'bestStreak'];

    /**
     * @param  array<string, mixed>|null  $data
     * @return array{xp:int, lessons_completed:int, streak:int, best_streak:int, gems:int, bonus_hearts:int, hearts:int, last_study_day:?string}
     */
    public static function fromData(?array $data, ?CarbonInterface $today = null): array
    {
        $data ??= [];
        $today ??= now();

        $lessons = count(self::idList($data['completedLessonIds'] ?? []));

        $xp = max((int) ($data['totalXp'] ?? 0), $lessons * self::XP_PER_LESSON);

        $bonusHearts = max(0, (int) ($data['bonusHearts'] ?? 0));

        $last = isset($data['lastStudyDay']) && is_string($data['lastStudyDay'])
            && preg_match('/^\d{4}-\d{2}-\d{2}$/', $data['lastStudyDay'])
            ? $data['lastStudyDay']
            : null;

        // Streak hanya berlaku kalau terakhir belajar hari ini atau kemarin.
        // Zona waktu HP bisa berbeda dari server, jadi hari esok juga dianggap
        // masih berlaku.
        $active = $last !== null && $last >= $today->copy()->subDay()->toDateString();
        $stored = max(0, (int) ($data['streak'] ?? 0));
        $best = max((int) ($data['bestStreak'] ?? 0), $stored);

        return [
            'xp' => $xp,
            'lessons_completed' => $lessons,
            'streak' => $active ? $stored : 0,
            'best_streak' => $best,
            'gems' => max(0, (int) ($data['gems'] ?? 0)),
            'bonus_hearts' => $bonusHearts,
            'hearts' => self::BASE_HEARTS + $bonusHearts,
            'last_study_day' => $last,
        ];
    }

    /**
     * Menggabungkan progres baru dari HP dengan yang sudah ada di server.
     *
     * @param  array<string, mixed>  $incoming
     * @param  array<string, mixed>|null  $existing
     * @return array<string, mixed>
     */
    public static function merge(array $incoming, ?array $existing, int $baselineXp = 0): array
    {
        $existing ??= [];
        $merged = $incoming;

        foreach (self::UNION_KEYS as $key) {
            if (! array_key_exists($key, $incoming) && ! array_key_exists($key, $existing)) {
                continue;
            }

            $merged[$key] = self::union($existing[$key] ?? [], $incoming[$key] ?? []);
        }

        foreach (self::MAX_KEYS as $key) {
            if (! array_key_exists($key, $incoming) && ! array_key_exists($key, $existing)) {
                continue;
            }

            $merged[$key] = max((int) ($existing[$key] ?? 0), (int) ($incoming[$key] ?? 0));
        }

        // XP tidak boleh lebih kecil dari XP yang sudah tercatat di akun, dan
        // tidak boleh lebih kecil dari jumlah lesson yang sudah selesai.
        $lessons = count(self::idList($merged['completedLessonIds'] ?? []));
        $merged['totalXp'] = max(
            (int) ($merged['totalXp'] ?? 0),
            $baselineXp,
            $lessons * self::XP_PER_LESSON,
        );

        return $merged;
    }

    /** @return list<string> */
    private static function union(mixed $a, mixed $b): array
    {
        $seen = [];

        foreach ([$a, $b] as $list) {
            foreach ((array) $list as $value) {
                $seen[(string) $value] = true;
            }
        }

        return array_map('strval', array_keys($seen));
    }

    /** @return list<int> */
    private static function idList(mixed $list): array
    {
        $ids = [];

        foreach ((array) $list as $value) {
            if (is_numeric($value)) {
                $ids[(int) $value] = true;
            }
        }

        return array_keys($ids);
    }
}
