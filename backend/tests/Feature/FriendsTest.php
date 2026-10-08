<?php

namespace Tests\Feature;

use App\Models\Post;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FriendsTest extends TestCase
{
    use RefreshDatabase;

    private function makeUser(string $username, array $extra = []): User
    {
        return User::create([
            'name' => ucfirst($username).' Test',
            'username' => $username,
            'email' => "$username@example.com",
            'password' => 'securepass123',
            'learning_language' => 'English',
            ...$extra,
        ]);
    }

    public function test_friend_endpoints_require_login(): void
    {
        $this->getJson('/api/users/search')->assertUnauthorized();
        $this->getJson('/api/profile/following')->assertUnauthorized();
        $this->postJson('/api/users/1/follow')->assertUnauthorized();
        $this->postJson('/api/logout')->assertUnauthorized();
    }

    public function test_search_shows_suggestions_without_a_query_and_filters_with_one(): void
    {
        $me = $this->makeUser('me');
        $this->makeUser('citra');
        $this->makeUser('budi');

        Sanctum::actingAs($me);

        $all = collect($this->getJson('/api/users/search')->assertOk()->json('data'))->pluck('username')->all();
        $this->assertEqualsCanonicalizing(['budi', 'citra'], $all);
        $this->assertNotContains('me', $all);

        $found = collect($this->getJson('/api/users/search?q=%40cit')->json('data'))->pluck('username')->all();
        $this->assertSame(['citra'], $found);

        $this->assertSame([], $this->getJson('/api/users/search?q=zzz')->json('data'));
    }

    public function test_search_treats_percent_signs_literally(): void
    {
        Sanctum::actingAs($this->makeUser('me'));
        $this->makeUser('budi');

        $this->assertSame([], $this->getJson('/api/users/search?q=%25')->json('data'));
    }

    public function test_follow_toggles_and_updates_the_lists(): void
    {
        $me = $this->makeUser('me');
        $friend = $this->makeUser('friend');

        Sanctum::actingAs($me);

        $this->postJson("/api/users/{$friend->id}/follow")->assertOk()->assertJsonPath('is_following', true);
        $this->assertSame(['friend'], collect($this->getJson('/api/profile/following')->json('data'))->pluck('username')->all());

        Sanctum::actingAs($friend);
        $this->assertSame(['me'], collect($this->getJson('/api/profile/followers')->json('data'))->pluck('username')->all());

        Sanctum::actingAs($me);
        $this->postJson("/api/users/{$friend->id}/follow")->assertJsonPath('is_following', false);
        $this->assertSame([], $this->getJson('/api/profile/following')->json('data'));
    }

    public function test_cannot_follow_or_like_yourself(): void
    {
        $me = $this->makeUser('me');
        Sanctum::actingAs($me);

        $this->postJson("/api/users/{$me->id}/follow")->assertUnprocessable();
        $this->postJson("/api/users/{$me->id}/like")->assertUnprocessable();
        $this->postJson("/api/users/{$me->id}/block")->assertUnprocessable();
        $this->postJson("/api/users/{$me->id}/report", ['reason' => 'spam'])->assertUnprocessable();
    }

    public function test_like_toggles_and_counts(): void
    {
        $me = $this->makeUser('me');
        $friend = $this->makeUser('friend');
        Sanctum::actingAs($me);

        $this->postJson("/api/users/{$friend->id}/like")
            ->assertOk()
            ->assertJsonPath('data.liked', true)
            ->assertJsonPath('data.like_count', 1);

        $this->postJson("/api/users/{$friend->id}/like")
            ->assertJsonPath('data.liked', false)
            ->assertJsonPath('data.like_count', 0);
    }

    public function test_blocking_removes_follows_and_hides_the_user_everywhere(): void
    {
        $me = $this->makeUser('me');
        $other = $this->makeUser('other');

        Sanctum::actingAs($me);
        $this->postJson("/api/users/{$other->id}/follow")->assertOk();
        Sanctum::actingAs($other);
        $this->postJson("/api/users/{$me->id}/follow")->assertOk();

        Sanctum::actingAs($me);
        $this->postJson("/api/users/{$other->id}/block")->assertOk()->assertJsonPath('blocked', true);

        $this->assertSame([], $this->getJson('/api/profile/following')->json('data'));
        $this->assertSame([], $this->getJson('/api/profile/followers')->json('data'));
        $this->assertSame([], $this->getJson('/api/users/search')->json('data'));
        $this->getJson("/api/users/{$other->id}")->assertNotFound();
        $this->postJson("/api/users/{$other->id}/follow")->assertNotFound();
        $this->assertSame(['other'], collect($this->getJson('/api/profile/blocked')->json('data'))->pluck('username')->all());

        // Yang diblokir juga tidak bisa melihat saya
        Sanctum::actingAs($other);
        $this->getJson("/api/users/{$me->id}")->assertNotFound();

        Sanctum::actingAs($me);
        $this->postJson("/api/users/{$other->id}/block")->assertJsonPath('blocked', false);
        $this->getJson("/api/users/{$other->id}")->assertOk();
    }

    public function test_report_needs_a_known_reason(): void
    {
        $me = $this->makeUser('me');
        $other = $this->makeUser('other');
        Sanctum::actingAs($me);

        $this->postJson("/api/users/{$other->id}/report", ['reason' => 'nonsense'])->assertUnprocessable();
        $this->postJson("/api/users/{$other->id}/report")->assertUnprocessable();
        $this->postJson("/api/users/{$other->id}/report", ['reason' => 'spam'])->assertCreated();

        $this->assertDatabaseHas('user_reports', [
            'reporter_id' => $me->id,
            'reported_id' => $other->id,
            'reason' => 'spam',
        ]);
    }

    public function test_public_user_card_includes_xp_and_streak(): void
    {
        $me = $this->makeUser('me');
        $other = $this->makeUser('other');
        $other->forceFill(['xp' => 150])->save();

        Sanctum::actingAs($me);

        $this->getJson("/api/users/{$other->id}")
            ->assertOk()
            ->assertJsonPath('data.username', 'other')
            ->assertJsonPath('data.xp', 150)
            ->assertJsonPath('data.streak', 0);
    }

    public function test_complete_profile_needs_one_follow_and_one_like(): void
    {
        $me = $this->makeUser('me');
        $friend = $this->makeUser('friend');
        $post = Post::create(['user_id' => $friend->id, 'body' => 'Halo']);

        Sanctum::actingAs($me);
        $this->getJson('/api/profile')->assertJsonPath('data.profile_completed', false);

        $this->postJson("/api/users/{$friend->id}/follow")->assertOk();
        $this->postJson("/api/posts/{$post->id}/like")->assertOk()->assertJsonPath('data.profile_completed', true);
    }

    public function test_avatar_must_be_a_known_character(): void
    {
        Sanctum::actingAs($this->makeUser('me'));

        $this->putJson('/api/profile/avatar', ['avatar_character' => 'binbin_florist'])
            ->assertOk()
            ->assertJsonPath('data.avatar_character', 'binbin_florist');
        $this->putJson('/api/profile/avatar', ['avatar_character' => 'hacker'])->assertUnprocessable();
    }

    public function test_language_can_change_but_only_to_a_supported_one(): void
    {
        Sanctum::actingAs($this->makeUser('me'));

        $this->patchJson('/api/profile/language', ['learning_language' => 'Korean'])
            ->assertOk()
            ->assertJsonPath('data.learning_language', 'Korean');
        $this->patchJson('/api/profile/language', ['learning_language' => 'French'])->assertUnprocessable();
    }

    public function test_logout_revokes_only_the_current_token(): void
    {
        $user = $this->makeUser('me');
        $keep = $user->createToken('phone')->plainTextToken;
        $drop = $user->createToken('tablet')->plainTextToken;

        $this->withHeader('Authorization', "Bearer $drop")->postJson('/api/logout')->assertOk();

        $this->app['auth']->forgetGuards();

        $this->withHeader('Authorization', "Bearer $drop")->getJson('/api/profile')->assertUnauthorized();

        $this->app['auth']->forgetGuards();

        $this->withHeader('Authorization', "Bearer $keep")->getJson('/api/profile')->assertOk();
    }
}
