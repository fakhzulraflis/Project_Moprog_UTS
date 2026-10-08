<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserProgress;
use App\Support\ProgressStats;
use Database\Seeders\CommunitySeeder;
use Database\Seeders\CurriculumSeeder;
use Database\Seeders\LanguageCoursesSeeder;
use Database\Seeders\LanguageSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProgressSyncTest extends TestCase
{
    use RefreshDatabase;

    private function makeUser(string $username, int $xp = 0): User
    {
        $user = User::create([
            'name' => $username,
            'username' => $username,
            'email' => "$username@example.com",
            'password' => 'securepass123',
        ]);

        $user->forceFill(['xp' => $xp])->save();

        return $user->fresh();
    }

    public function test_finished_lessons_survive_a_stale_push(): void
    {
        $user = $this->makeUser('adrian');
        Sanctum::actingAs($user);

        $this->putJson('/api/progress', ['progress' => [
            'completedLessonIds' => ['1', '2', '3'],
            'studiedDays' => ['2026-10-01', '2026-10-02'],
        ]])->assertOk();

        // HP lain yang datanya lama: hanya tahu lesson 1 dan hari pertama
        $this->putJson('/api/progress', ['progress' => [
            'completedLessonIds' => ['1', '4'],
            'studiedDays' => ['2026-10-01'],
        ]])->assertOk();

        $data = $this->getJson('/api/progress')->json('data.progress');

        $this->assertEqualsCanonicalizing(['1', '2', '3', '4'], $data['completedLessonIds']);
        $this->assertEqualsCanonicalizing(['2026-10-01', '2026-10-02'], $data['studiedDays']);
    }

    public function test_xp_is_at_least_ten_per_finished_lesson(): void
    {
        $user = $this->makeUser('adrian');
        Sanctum::actingAs($user);

        // 12 lesson selesai tetapi XP di HP masih 0 (data lama sebelum XP dicatat)
        $this->putJson('/api/progress', ['progress' => [
            'totalXp' => 0,
            'completedLessonIds' => array_map('strval', range(1, 12)),
        ]])->assertOk()
            ->assertJsonPath('data.progress.totalXp', 120)
            ->assertJsonPath('data.xp', 120);

        $this->assertSame(120, (int) $user->fresh()->xp);
    }

    public function test_account_xp_is_the_baseline_for_the_device(): void
    {
        // Akun sudah punya 300 XP, tetapi HP baru mengirim 10 XP
        $user = $this->makeUser('adrian', 300);
        Sanctum::actingAs($user);

        $this->getJson('/api/progress')
            ->assertOk()
            ->assertJsonPath('data.progress', null)
            ->assertJsonPath('data.xp', 300);

        $this->putJson('/api/progress', ['progress' => ['totalXp' => 10, 'gems' => 80]])
            ->assertOk()
            ->assertJsonPath('data.progress.totalXp', 300)
            ->assertJsonPath('data.progress.gems', 80);

        $this->assertSame(300, (int) $user->fresh()->xp);
    }

    public function test_xp_keeps_growing_from_the_saved_number(): void
    {
        $user = $this->makeUser('adrian', 300);
        Sanctum::actingAs($user);

        $this->putJson('/api/progress', ['progress' => ['totalXp' => 310]])->assertOk();

        $this->assertSame(310, (int) $user->fresh()->xp);
        $this->getJson('/api/progress')->assertJsonPath('data.progress.totalXp', 310);
    }

    public function test_pushing_progress_moves_the_user_on_the_leaderboard(): void
    {
        $this->makeUser('rival', 200);
        $me = $this->makeUser('me', 50);

        Sanctum::actingAs($me);
        $this->putJson('/api/progress', ['progress' => ['totalXp' => 260]])->assertOk();

        $rows = $this->getJson('/api/leaderboard')->json('data');

        $this->assertSame(['me', 'rival'], collect($rows)->pluck('username')->all());
        $this->assertSame(260, $rows[0]['xp']);
    }

    public function test_stats_are_computed_from_the_saved_progress(): void
    {
        $today = now()->toDateString();

        $stats = ProgressStats::fromData([
            'totalXp' => 95,
            'gems' => 70,
            'bonusHearts' => 2,
            'streak' => 4,
            'bestStreak' => 9,
            'lastStudyDay' => $today,
            'completedLessonIds' => ['1', '2', '3', '3'],
        ]);

        $this->assertSame(95, $stats['xp']);
        $this->assertSame(3, $stats['lessons_completed']);
        $this->assertSame(4, $stats['streak']);
        $this->assertSame(9, $stats['best_streak']);
        $this->assertSame(7, $stats['hearts']);
    }

    public function test_streak_is_zero_after_a_missed_day(): void
    {
        $stats = ProgressStats::fromData([
            'streak' => 6,
            'lastStudyDay' => now()->subDays(3)->toDateString(),
        ]);

        $this->assertSame(0, $stats['streak']);
    }

    public function test_oversized_or_invalid_progress_is_rejected(): void
    {
        Sanctum::actingAs($this->makeUser('adrian'));

        $this->putJson('/api/progress', ['progress' => ['totalXp' => -1]])->assertUnprocessable();
        $this->putJson('/api/progress', ['progress' => ['totalXp' => 99999999]])->assertUnprocessable();
        $this->putJson('/api/progress', ['progress' => ['completedLessonIds' => ['abc']]])->assertUnprocessable();
        $this->putJson('/api/progress', ['progress' => [
            'completedLessonIds' => range(1, 5001),
        ]])->assertUnprocessable();
        $this->putJson('/api/progress', ['progress' => [
            'note' => str_repeat('x', 250_000),
        ]])->assertUnprocessable();
    }

    public function test_demo_players_have_xp_that_matches_their_lessons(): void
    {
        $this->seed([LanguageSeeder::class, CurriculumSeeder::class, LanguageCoursesSeeder::class, CommunitySeeder::class]);

        $users = User::whereNotNull('username')->get();
        $this->assertGreaterThanOrEqual(10, $users->count());

        foreach ($users as $user) {
            $data = UserProgress::where('user_id', $user->id)->value('data');
            $lessons = count($data['completedLessonIds']);

            $this->assertSame((int) $user->xp, (int) $data['totalXp'], "{$user->username}: users.xp harus sama dengan progres");
            $this->assertGreaterThanOrEqual($lessons * 10, (int) $user->xp, "{$user->username}: XP harus mencakup XP lesson");
        }

        $xp = User::orderByDesc('xp')->pluck('xp')->all();
        $this->assertGreaterThan(0, $xp[0]);
        $this->assertNotSame(1, count(array_unique($xp)), 'XP pemain contoh harus bervariasi');
    }

    public function test_seeding_twice_does_not_change_existing_players(): void
    {
        $this->seed([LanguageSeeder::class, CurriculumSeeder::class, LanguageCoursesSeeder::class, CommunitySeeder::class]);

        $before = User::orderBy('id')->pluck('xp', 'username')->all();

        // Pemain mendapat XP lagi dari bermain, lalu seeder dijalankan ulang
        $player = User::where('username', 'dimas_ar')->first();
        $player->forceFill(['xp' => 999])->save();
        $this->seed(CommunitySeeder::class);

        $this->assertSame(999, (int) $player->fresh()->xp);
        $this->assertSame(count($before), User::count());
    }

    public function test_a_demo_player_can_continue_from_their_saved_xp(): void
    {
        $this->seed([LanguageSeeder::class, CurriculumSeeder::class, LanguageCoursesSeeder::class, CommunitySeeder::class]);

        $player = User::where('username', 'maya_p')->first();
        $startXp = (int) $player->xp;
        $saved = UserProgress::where('user_id', $player->id)->value('data');

        Sanctum::actingAs($player);

        $remote = $this->getJson('/api/progress')->assertOk();
        $this->assertSame($startXp, $remote->json('data.xp'));
        $this->assertSame($startXp, $remote->json('data.progress.totalXp'));

        // Selesai satu lesson lagi: HP mengirim XP + 10 dari angka yang sama
        $next = (string) (max(array_map('intval', $saved['completedLessonIds'])) + 1);
        $this->putJson('/api/progress', ['progress' => [
            ...$remote->json('data.progress'),
            'totalXp' => $startXp + 10,
            'completedLessonIds' => [...$saved['completedLessonIds'], $next],
        ]])->assertOk();

        $this->assertSame($startXp + 10, (int) $player->fresh()->xp);
    }
}
