<?php

use App\Http\Controllers\Api\AccountRegistrationController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\LessonController;
use App\Http\Controllers\Api\LoginController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\LanguageController;
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

// Inventory: hanya bisa diakses user yang login (pakai token Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/inventory', [InventoryController::class, 'index']);
    Route::post('/inventory', [InventoryController::class, 'store']);
    Route::post('/inventory/{id}/use', [InventoryController::class, 'use'])->whereNumber('id');

    // Profil user + syarat "Complete your profile"
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::post('/logout', [LoginController::class, 'logout']);
    Route::patch('/profile/language', [ProfileController::class, 'updateLanguage']);
    Route::get('/profile/following', [UserController::class, 'following']);
    Route::get('/profile/followers', [UserController::class, 'followers']);
    Route::get('/profile/blocked', [UserController::class, 'blocked']);
    Route::get('/users/search', [UserController::class, 'search']);
    Route::get('/users/{id}', [UserController::class, 'show'])->whereNumber('id');
    Route::post('/users/{id}/like', [UserController::class, 'toggleLike'])->whereNumber('id');
    Route::post('/users/{id}/block', [UserController::class, 'toggleBlock'])->whereNumber('id');
    Route::post('/users/{id}/report', [UserController::class, 'report'])->whereNumber('id');
    Route::put('/profile/avatar', [ProfileController::class, 'updateAvatar']);
    Route::post('/users/{id}/follow', [ProfileController::class, 'toggleFollow'])->whereNumber('id');
    Route::get('/posts', [ProfileController::class, 'posts']);
    Route::post('/posts/{id}/like', [ProfileController::class, 'toggleLike'])->whereNumber('id');
});
