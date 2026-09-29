<?php

use App\Http\Controllers\Api\AccountRegistrationController;
use App\Http\Controllers\Api\LessonController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\VocabularyController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AccountRegistrationController::class, 'store']);

Route::get('/vocabularies', [VocabularyController::class, 'index']);

Route::get('/lessons', [LessonController::class, 'index']);

Route::get('/lessons/{lessonId}/questions', [QuestionController::class, 'index']);
