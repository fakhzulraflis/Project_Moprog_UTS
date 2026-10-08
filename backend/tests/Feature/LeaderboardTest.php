<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class LeaderboardTest extends TestCase
{
    use RefreshDatabase;

    private function makeUser(string $username, int $xp = 0, array $extra = []): User
    {
        $user = User::create([
            'name' => ucfirst($username).' Test',
            'username' => $username,
            'email' => "$username@example.com",
            'password' => 'securepass123',
            'learning_language' => 'English',
            ...$extra,
        ]);

        // xp tidak ada di $fillable
        $user->forceFill(['xp' => $xp])->save();

        return $user->fresh();
    }

    public function test_leaderboard_lists_every_user_sorted_by_highest_xp(): void
    {
        $this->makeUser('low', 10);
        $this->makeUser('top', 900);
        $this->makeUser('zero', 0);
        $this->makeUser('mid', 250);

        $response = $this->getJson('/api/leaderboard')->assertOk();

        $this->assertSame(
            ['top', 'mid', 'low', 'zero'],
            collect($response->json('data'))->pluck('username')->all(),
        );
        $this->assertSame([1, 2, 3, 4], collect($response->json('data'))->pluck('rank')->all());
        $this->assertSame(4, $response->json('meta.total'));
    }

    public function test_users_with_the_same_xp_keep_a_stable_order(): void
    {
        $first = $this->makeUser('first', 100);
        $second = $this->makeUser('second', 100);

        $ids = collect($this->getJson('/api/leaderboard')->json('data'))->pluck('id')->all();

        $this->assertSame([(string) $first->id, (string) $second->id], $ids);
    }

    public function test_rows_carry_what_the_app_needs_to_draw_them(): void
    {
        $this->makeUser('bunny', 120, [
            'avatar_character' => 'binbin_winter',
            'learning_language' => 'Korean',
        ]);

        $this->getJson('/api/leaderboard')
            ->assertOk()
            ->assertJsonPath('data.0.name', 'Bunny Test')
            ->assertJsonPath('data.0.username', 'bunny')
            ->assertJsonPath('data.0.xp', 120)
            ->assertJsonPath('data.0.avatar_character', 'binbin_winter')
            ->assertJsonPath('data.0.learning_language', 'Korean')
            ->assertJsonPath('data.0.is_me', false);
    }

    public function test_own_row_is_marked_when_logged_in(): void
    {
        $this->makeUser('rival', 500);
        $me = $this->makeUser('me', 40);

        Sanctum::actingAs($me);

        $response = $this->getJson('/api/leaderboard')->assertOk();

        $this->assertSame(2, $response->json('meta.my_rank'));
        $this->assertTrue($response->json('data.1.is_me'));
        $this->assertFalse($response->json('data.0.is_me'));
    }

    public function test_blocked_users_are_hidden_in_both_directions(): void
    {
        $me = $this->makeUser('me', 100);
        $blocked = $this->makeUser('blocked', 900);
        $blocker = $this->makeUser('blocker', 800);
        $this->makeUser('visible', 700);

        Sanctum::actingAs($me);
        $this->postJson("/api/users/{$blocked->id}/block")->assertOk();
        Sanctum::actingAs($blocker);
        $this->postJson("/api/users/{$me->id}/block")->assertOk();

        Sanctum::actingAs($me);
        $names = collect($this->getJson('/api/leaderboard')->json('data'))->pluck('username')->all();

        $this->assertSame(['visible', 'me'], $names);
    }

    public function test_profile_rank_matches_the_leaderboard(): void
    {
        $this->makeUser('rival', 500);
        $me = $this->makeUser('me', 40);
        $this->makeUser('behind', 5);

        Sanctum::actingAs($me);

        $this->getJson('/api/profile')
            ->assertOk()
            ->assertJsonPath('data.xp', 40)
            ->assertJsonPath('data.rank', 2)
            ->assertJsonPath('data.total_players', 3);
    }
}
