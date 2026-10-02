<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;

class PasswordResetController extends Controller
{
    public function sendCode(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username_or_email' => ['required', 'string', 'max:255'],
        ]);

        $identifier = trim($validated['username_or_email']);
        $user = User::query()
            ->where('username', $identifier)
            ->orWhere('email', $identifier)
            ->first();

        if ($user) {
            Password::broker()->sendResetLink(['email' => $user->email]);
        }

        return response()->json([
            'message' => 'If the account exists, a reset code has been sent to its email.',
        ]);
    }

    public function reset(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username_or_email' => ['required', 'string', 'max:255'],
            'token' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $identifier = trim($validated['username_or_email']);
        $user = User::query()
            ->where('username', $identifier)
            ->orWhere('email', $identifier)
            ->first();

        if (! $user) {
            return $this->invalidTokenResponse();
        }

        $status = Password::broker()->reset([
            'email' => $user->email,
            'token' => $validated['token'],
            'password' => $validated['password'],
            'password_confirmation' => $request->input('password_confirmation'),
        ], function (User $user, string $password): void {
            $user->forceFill([
                'password' => $password,
                'remember_token' => Str::random(60),
            ])->save();
        });

        if ($status !== Password::PASSWORD_RESET) {
            return $this->invalidTokenResponse();
        }

        return response()->json([
            'message' => 'Password changed successfully.',
        ]);
    }

    private function invalidTokenResponse(): JsonResponse
    {
        return response()->json([
            'message' => 'The reset code is invalid or expired. Request a new code and try again.',
        ], 422);
    }
}
