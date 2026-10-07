<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\PasswordResetCodeNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
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

    public function test_user_can_login_with_username_or_email(): void
    {
        $this->postJson('/api/register', $this->validPayload());

        $response = $this->postJson('/api/login', [
            'username_or_email' => 'fakhzulrafli',
            'password' => 'securepass123',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('message', 'Login successful.')
            ->assertJsonPath('user.username', 'fakhzulrafli');

        $invalidResponse = $this->postJson('/api/login', [
            'username_or_email' => 'fakhzul@example.com',
            'password' => 'wrong-password',
        ]);

        $invalidResponse->assertUnauthorized()
            ->assertJsonPath('message', 'Invalid username/email or password.');
    }

    public function test_user_can_reset_password_with_email_reset_code(): void
    {
        $this->postJson('/api/register', $this->validPayload());
        Notification::fake();

        $user = User::where('username', 'fakhzulrafli')->firstOrFail();

        $this->postJson('/api/forgot-password', [
            'username_or_email' => 'fakhzulrafli',
        ])
            ->assertOk()
            ->assertJsonPath('message', 'If the account exists, a reset code has been sent to its email.');

        $token = null;
        Notification::assertSentTo(
            $user,
            PasswordResetCodeNotification::class,
            function (PasswordResetCodeNotification $notification) use (&$token): bool {
                $token = $notification->token;

                return true;
            },
        );

        $this->postJson('/api/reset-password', [
            'username_or_email' => 'fakhzulrafli',
            'token' => $token,
            'password' => 'newsecurepass123',
            'password_confirmation' => 'newsecurepass123',
        ])
            ->assertOk()
            ->assertJsonPath('message', 'Password changed successfully.');

        $user->refresh();
        $this->assertTrue(Hash::check('newsecurepass123', $user->password));
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
