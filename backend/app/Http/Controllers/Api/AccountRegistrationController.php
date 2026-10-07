<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class AccountRegistrationController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fullname' => ['required', 'string', 'max:255'],
            'username' => ['required', 'string', 'max:40', 'alpha_dash', 'unique:users,username'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'birth_day' => ['required', 'integer', 'between:1,31'],
            'birth_month' => ['required', 'integer', 'between:1,12'],
            'birth_year' => ['required', 'integer', 'between:1900,'.now()->year],
            'country' => ['required', 'string', 'max:120'],
            'native_language' => ['required', 'string', 'in:Bahasa Indonesia,English,Japanese,Korean'],
            'learning_language' => ['required', 'string', 'in:English,Japanese,Korean'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'terms_accepted' => ['accepted'],
        ]);

        if (! checkdate(
            (int) $validated['birth_month'],
            (int) $validated['birth_day'],
            (int) $validated['birth_year'],
        )) {
            throw ValidationException::withMessages([
                'birth_day' => ['Please enter a valid date of birth.'],
            ]);
        }

        $avatarPath = match ($validated['learning_language']) {
            'Japanese' => 'assets/app/japanese.gif',
            'Korean' => 'assets/app/korean.gif',
            default => 'assets/app/english.gif',
        };

        $user = User::create([
            'name' => $validated['fullname'],
            'username' => $validated['username'],
            'email' => $validated['email'],
            'password' => $validated['password'],
            'birth_day' => $validated['birth_day'],
            'birth_month' => $validated['birth_month'],
            'birth_year' => $validated['birth_year'],
            'country' => $validated['country'],
            'native_language' => $validated['native_language'],
            'learning_language' => $validated['learning_language'],
            'avatar_path' => $avatarPath,
        ]);

        return response()->json([
            'message' => 'Account created successfully.',
            'data' => [
                'id' => $user->id,
                'fullname' => $user->name,
                'username' => $user->username,
                'email' => $user->email,
                'birth_day' => $user->birth_day,
                'birth_month' => $user->birth_month,
                'birth_year' => $user->birth_year,
                'country' => $user->country,
                'native_language' => $user->native_language,
                'learning_language' => $user->learning_language,
                'avatar_path' => $user->avatar_path,
            ],
        ], 201);
    }
}
