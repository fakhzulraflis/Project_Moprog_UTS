<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProgressTest extends TestCase
{
    use RefreshDatabase;

    private function makeUser(string $username): User
    {
        return User::create([
            'name' => $username,
            'username' => $username,
            'email' => "$username@example.com",
            'password' => 'securepass123',
        ]);
    }

    public function test_progress_requires_login(): void
    {
        $this->getJson('/api/progress')->assertUnauthorized();
        $this->putJson('/api/progress', ['progress' => ['gems' => 5]])->assertUnauthorized();
    }

    public function test_new_user_has_no_progress_yet(): void
    {
        Sanctum::actingAs($this->makeUser('adrian'));

        $this->getJson('/api/progress')
            ->assertOk()
            ->assertJsonPath('data.progress', null);
    }

    public function test_progress_is_saved_and_loaded_back(): void
    {
        Sanctum::actingAs($this->makeUser('adrian'));

        $progress = [
            'gems' => 120,
            'totalXp' => 340,
            'todayQuests' => ['earn_xp', 'complete_lesson', 'feed_duck'],
            'pet_fullness' => 72.5,
            'pet_equipped' => ['crown'],
        ];

        $this->putJson('/api/progress', ['progress' => $progress])->assertOk();

        $this->getJson('/api/progress')
            ->assertOk()
            ->assertJsonPath('data.progress.gems', 120)
            ->assertJsonPath('data.progress.todayQuests.2', 'feed_duck')
            ->assertJsonPath('data.progress.pet_fullness', 72.5)
            ->assertJsonPath('data.progress.pet_equipped.0', 'crown');
    }

    public function test_each_user_has_their_own_progress(): void
    {
        $adrian = $this->makeUser('adrian');
        $lucio = $this->makeUser('lucio');

        Sanctum::actingAs($adrian);
        $this->putJson('/api/progress', ['progress' => ['gems' => 999]])->assertOk();

        Sanctum::actingAs($lucio);
        $this->getJson('/api/progress')->assertJsonPath('data.progress', null);
        $this->putJson('/api/progress', ['progress' => ['gems' => 7]])->assertOk();

        Sanctum::actingAs($adrian);
        $this->getJson('/api/progress')->assertJsonPath('data.progress.gems', 999);
    }

    public function test_saving_progress_updates_leaderboard_xp_without_lowering_it(): void
    {
        $user = $this->makeUser('adrian');
        Sanctum::actingAs($user);

        $this->putJson('/api/progress', ['progress' => ['totalXp' => 250]])->assertOk();
        $this->assertSame(250, (int) $user->fresh()->xp);

        $this->putJson('/api/progress', ['progress' => ['totalXp' => 10]])->assertOk();
        $this->assertSame(250, (int) $user->fresh()->xp);

        $this->getJson('/api/leaderboard')
            ->assertOk()
            ->assertJsonPath('data.0.xp', 250);
    }

    public function test_invalid_progress_is_rejected(): void
    {
        Sanctum::actingAs($this->makeUser('adrian'));

        $this->putJson('/api/progress', ['progress' => 'bukan-data'])->assertUnprocessable();
        $this->putJson('/api/progress', ['progress' => ['gems' => -5]])->assertUnprocessable();
    }
}
