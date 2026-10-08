<?php

namespace Tests\Feature;

use App\Models\InventoryItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class InventoryTest extends TestCase
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

    public function test_inventory_requires_login(): void
    {
        $this->getJson('/api/inventory')->assertUnauthorized();
        $this->postJson('/api/inventory', ['item_key' => 'xp_boost_15'])->assertUnauthorized();
    }

    public function test_login_returns_token_that_opens_inventory(): void
    {
        $this->makeUser('adrian');

        $token = $this->postJson('/api/login', [
            'username_or_email' => 'adrian',
            'password' => 'securepass123',
        ])->assertOk()->json('token');

        $this->assertNotEmpty($token);

        $this->withToken($token)
            ->getJson('/api/inventory')
            ->assertOk()
            ->assertJsonPath('data.items', [])
            ->assertJsonPath('data.active', []);
    }

    public function test_user_can_add_item_and_see_it(): void
    {
        Sanctum::actingAs($this->makeUser('adrian'));

        $this->postJson('/api/inventory', ['item_key' => 'xp_boost_30', 'source' => 'shop'])
            ->assertCreated()
            ->assertJsonPath('data.item_key', 'xp_boost_30')
            ->assertJsonPath('data.effect', 'xp_boost')
            ->assertJsonPath('data.minutes', 30)
            ->assertJsonPath('data.status', 'unused');

        $this->getJson('/api/inventory')
            ->assertOk()
            ->assertJsonCount(1, 'data.items')
            ->assertJsonCount(0, 'data.active');
    }

    public function test_unknown_item_is_rejected(): void
    {
        Sanctum::actingAs($this->makeUser('adrian'));

        $this->postJson('/api/inventory', ['item_key' => 'gem_tak_terbatas'])
            ->assertUnprocessable();
        $this->postJson('/api/inventory', ['item_key' => 'xp_boost_15', 'source' => 'curang'])
            ->assertUnprocessable();
    }

    public function test_users_only_see_and_use_their_own_items(): void
    {
        $adrian = $this->makeUser('adrian');
        $lucio = $this->makeUser('lucio');

        $item = InventoryItem::create([
            'user_id' => $adrian->id,
            'item_key' => 'unlimited_hearts_30',
            'status' => InventoryItem::STATUS_UNUSED,
        ]);

        Sanctum::actingAs($lucio);
        $this->getJson('/api/inventory')->assertJsonCount(0, 'data.items');
        $this->postJson("/api/inventory/{$item->id}/use")->assertNotFound();

        $this->assertSame(InventoryItem::STATUS_UNUSED, $item->fresh()->status);
    }

    public function test_using_item_activates_it_for_its_duration(): void
    {
        Carbon::setTestNow('2026-10-08 10:00:00');
        Sanctum::actingAs($this->makeUser('adrian'));

        $id = $this->postJson('/api/inventory', ['item_key' => 'unlimited_hearts_60'])->json('data.id');

        $this->postJson("/api/inventory/{$id}/use")
            ->assertOk()
            ->assertJsonCount(0, 'data.items')
            ->assertJsonCount(1, 'data.active')
            ->assertJsonPath('data.active.0.status', 'active');

        $this->assertTrue(
            InventoryItem::find($id)->expires_at->equalTo(Carbon::parse('2026-10-08 11:00:00'))
        );

        // Tidak bisa dipakai dua kali
        $this->postJson("/api/inventory/{$id}/use")->assertUnprocessable();

        // Setelah waktunya habis, efeknya tidak aktif lagi
        Carbon::setTestNow('2026-10-08 11:00:01');
        $this->getJson('/api/inventory')->assertJsonCount(0, 'data.active');

        Carbon::setTestNow();
    }

    public function test_same_effect_is_extended_not_replaced(): void
    {
        Carbon::setTestNow('2026-10-08 10:00:00');
        Sanctum::actingAs($this->makeUser('adrian'));

        $first = $this->postJson('/api/inventory', ['item_key' => 'xp_boost_15'])->json('data.id');
        $second = $this->postJson('/api/inventory', ['item_key' => 'xp_boost_30'])->json('data.id');

        $this->postJson("/api/inventory/{$first}/use")->assertOk();
        $this->postJson("/api/inventory/{$second}/use")->assertOk();

        // 10:00 + 15 menit + 30 menit = 10:45
        $this->assertTrue(
            InventoryItem::find($second)->expires_at->equalTo(Carbon::parse('2026-10-08 10:45:00'))
        );

        Carbon::setTestNow();
    }
}
