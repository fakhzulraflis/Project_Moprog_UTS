<?php

use App\Http\Controllers\Api\AccountRegistrationController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\LessonController;
use App\Http\Controllers\Api\LoginController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\LanguageController;
use App\Http\Controllers\Api\LeaderboardController;
use App\Http\Controllers\Api\VocabularyController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AccountRegistrationController::class, 'store']);
Route::post('/login', [LoginController::class, 'login']);
Route::post('/forgot-password', [PasswordResetController::class, 'sendCode']);
Route::post('/reset-password', [PasswordResetController::class, 'reset']);

Route::get('/vocabularies', [VocabularyController::class, 'index']);

Route::get('/lessons', [LessonController::class, 'index']);

Route::get('/lessons/{lessonId}/questions', [QuestionController::class, 'index']);

Route::get('/languages', [LanguageController::class, 'index']);
Route::get('/languages/{code}/path', [LanguageController::class, 'path']);

// Leaderboard: publik, siapapun boleh lihat tanpa login
Route::get('/leaderboard', [LeaderboardController::class, 'index']);

// Inventory: hanya bisa diakses user yang login (pakai token Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/inventory', [InventoryController::class, 'index']);
    Route::post('/inventory', [InventoryController::class, 'store']);
    Route::post('/inventory/{id}/use', [InventoryController::class, 'use'])->whereNumber('id');

    // Profil user + syarat "Complete your profile"
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile/avatar', [ProfileController::class, 'updateAvatar']);
    Route::put('/profile/xp', [ProfileController::class, 'updateXp']);
    Route::get('/profile/suggestions', [ProfileController::class, 'suggestions']);
    Route::post('/users/{id}/follow', [ProfileController::class, 'toggleFollow'])->whereNumber('id');
    Route::get('/posts', [ProfileController::class, 'posts']);
    Route::post('/posts/{id}/like', [ProfileController::class, 'toggleLike'])->whereNumber('id');
});
