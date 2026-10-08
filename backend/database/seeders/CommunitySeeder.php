<?php

namespace Database\Seeders;

use App\Models\Language;
use App\Models\Post;
use App\Models\User;
use App\Models\UserProgress;
use App\Support\ProgressStats;
use Illuminate\Database\Seeder;

/**
 * Pemain contoh supaya leaderboard, pencarian teman, dan "Complete your
 * profile" bisa dicoba. Semua pemain contoh memakai password: password123
 *
 * XP tiap pemain selaras dengan progres belajarnya: lesson yang sudah selesai
 * dihitung dari XP (10 XP per lesson, sejauh lesson yang ada di database),
 * dan sisa XP berasal dari misi, peti, dan roda harian. Jadi kalau pemain
 * contoh dipakai login, Learn page menampilkan lesson yang sudah selesai dan
 * XP-nya bertambah dari angka yang sama, bukan dari 0.
 *
 * Seeder ini aman dijalankan berulang: pemain yang sudah punya progres tidak
 * diubah.
 */
class CommunitySeeder extends Seeder
{
    /** [nama, username, bahasa, karakter, XP, streak, postingan] */
    private const PLAYERS = [
        ['Dimas Aryo', 'dimas_ar', 'Japanese', 'japduck', 430, 21, null],
        ['Maya Putri', 'maya_p', 'Korean', 'korduck', 400, 14, null],
        ['Aditya Pratama', 'aditya_q', 'English', 'engduck', 360, 9, 'Hari ini berhasil 7 hari streak! Semangat semua!'],
        ['Bunga Lestari', 'bunga_dev', 'Japanese', null, 330, 7, 'Akhirnya hafal hiragana. Next: katakana!'],
        ['Citra Dewi', 'citra_kr', 'Korean', null, 290, 12, 'Tips: dengarkan lagu K-pop sambil baca liriknya.'],
        ['Eka Saputra', 'eka_sap', 'English', 'qua_chef', 250, 5, null],
        ['Fajar Nugroho', 'fajar_n', 'English', 'qua_scholar', 220, 4, null],
        ['Gita Permata', 'gita_p', 'Korean', 'binbin_cardigan', 190, 6, null],
        ['Hadi Wijaya', 'hadi_w', 'Japanese', 'binbin_winter', 160, 3, null],
        ['Indah Sari', 'indah_s', 'English', 'binbin_florist', 130, 2, null],
        ['Joko Santoso', 'joko_s', 'Korean', null, 100, 1, null],
        ['Kirana Dewi', 'kirana_d', 'Japanese', null, 70, 3, null],
        ['Lestari Ayu', 'lestari_a', 'English', null, 40, 1, null],
        ['Made Surya', 'made_s', 'Korean', 'korduck', 20, 0, null],
    ];

    public function run(): void
    {
        foreach (self::PLAYERS as [$name, $username, $language, $character, $xp, $streak, $post]) {
            $user = User::firstOrCreate(
                ['username' => $username],
                [
                    'name' => $name,
                    'email' => $username.'@example.com',
                    'password' => 'password123',
                    'learning_language' => $language,
                    'native_language' => 'Bahasa Indonesia',
                    'country' => 'Indonesia',
                    'avatar_character' => $character,
                    'avatar_path' => match ($language) {
                        'Japanese' => 'assets/app/japanese.gif',
                        'Korean' => 'assets/app/korean.gif',
                        default => 'assets/app/english.gif',
                    },
                ],
            );

            if (! UserProgress::where('user_id', $user->id)->exists()) {
                $data = $this->progressFor($language, $xp, $streak);

                UserProgress::create(['user_id' => $user->id, 'data' => $data]);

                // Kolom xp tidak ada di $fillable, jadi diisi lewat query builder.
                User::whereKey($user->id)->where('xp', '<', $data['totalXp'])->update(['xp' => $data['totalXp']]);
            }

            if ($post !== null) {
                Post::firstOrCreate(['user_id' => $user->id, 'body' => $post]);
            }
        }
    }

    /** @return array<string, mixed> */
    private function progressFor(string $language, int $xp, int $streak): array
    {
        $available = $this->lessonIds($language);

        // Lesson yang selesai: sebanyak yang XP-nya cukup, dan yang memang ada.
        $lessons = min(intdiv($xp, ProgressStats::XP_PER_LESSON), count($available));
        $done = array_slice($available, 0, $lessons);

        $today = now();
        $studiedDays = [];
        for ($i = 0; $i < $streak; $i++) {
            $studiedDays[] = $today->copy()->subDays($i)->toDateString();
        }

        return [
            'gems' => 50 + intdiv($xp, 5),
            'totalXp' => $xp,
            'bonusHearts' => $xp % 3,
            'completedLessonIds' => array_map('strval', $done),
            'streak' => $streak,
            'bestStreak' => max($streak, intdiv($streak * 3, 2)),
            // Streak 0 berarti terakhir belajar beberapa hari lalu
            'lastStudyDay' => $today->copy()->subDays($streak > 0 ? 0 : 3)->toDateString(),
            'studiedDays' => $studiedDays,
            'streakGoal' => 7,
        ];
    }

    /**
     * Id lesson sebuah bahasa menurut urutan di Learn page:
     * section, lalu unit, lalu lesson (semuanya diurutkan menurut id).
     *
     * @return list<int>
     */
    private function lessonIds(string $language): array
    {
        $code = match ($language) {
            'Japanese' => 'ja',
            'Korean' => 'ko',
            default => 'en',
        };

        $model = Language::where('code', $code)->first();

        if (! $model) {
            return [];
        }

        $ids = [];

        foreach ($model->sections()->orderBy('id')->get() as $section) {
            foreach ($section->units()->orderBy('id')->get() as $unit) {
                foreach ($unit->lessons()->orderBy('id')->get() as $lesson) {
                    $ids[] = $lesson->id;
                }
            }
        }

        return $ids;
    }
}
