<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class LoginController extends Controller
{
    // POST /api/logout  (hanya mencabut token perangkat ini)
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Signed out.']);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username_or_email' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        $identifier = trim($validated['username_or_email']);

        $user = User::query()
            ->where('username', $identifier)
            ->orWhere('email', $identifier)
            ->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'message' => 'Invalid username/email or password.',
            ], 401);
        }

        return response()->json([
            'message' => 'Login successful.',
            // Token untuk API yang butuh login (misalnya inventory)
            'token' => $user->createToken('mobile')->plainTextToken,
            'user' => [
                'id' => $user->id,
                'fullname' => $user->name,
                'username' => $user->username,
                'email' => $user->email,
                'learning_language' => $user->learning_language ?? 'English',
                'avatar_path' => $user->avatar_path ?? 'assets/app/english.gif',
            ],
        ]);
    }
}
