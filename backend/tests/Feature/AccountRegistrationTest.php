<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AccountRegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_with_profile_details(): void
    {
        $response = $this->postJson('/api/register', $this->validPayload());

        $response
            ->assertCreated()
            ->assertJsonPath('data.fullname', 'Fakhzul Rafli')
            ->assertJsonPath('data.learning_language', 'Japanese')
            ->assertJsonPath('data.avatar_path', 'assets/app/japanese.gif');

        $user = User::where('email', 'fakhzul@example.com')->firstOrFail();

        $this->assertDatabaseHas('users', [
            'username' => 'fakhzulrafli',
            'birth_day' => 12,
            'birth_month' => 6,
            'birth_year' => 2002,
        ]);
        $this->assertTrue(Hash::check('securepass123', $user->password));
    }

    public function test_registration_rejects_mismatched_password_confirmation(): void
    {
        $response = $this->postJson('/api/register', [
            ...$this->validPayload(),
            'password_confirmation' => 'differentpass123',
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors('password');
    }

    private function validPayload(): array
    {
        return [
            'fullname' => 'Fakhzul Rafli',
            'username' => 'fakhzulrafli',
            'email' => 'fakhzul@example.com',
            'birth_day' => 12,
            'birth_month' => 6,
            'birth_year' => 2002,
            'country' => 'Indonesia',
            'native_language' => 'Bahasa Indonesia',
            'learning_language' => 'Japanese',
            'password' => 'securepass123',
            'password_confirmation' => 'securepass123',
            'terms_accepted' => true,
        ];
    }
}
