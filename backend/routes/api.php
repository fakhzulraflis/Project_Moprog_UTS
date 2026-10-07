<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\VocabularyController;
use App\Http\Controllers\Api\LessonController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\LanguageController;

Route::get('/vocabularies', [VocabularyController::class, 'index']);

Route::get('/lessons', [LessonController::class, 'index']);

Route::get('/lessons/{lessonId}/questions', [QuestionController::class, 'index']);

Route::get('/languages', [LanguageController::class, 'index']);
Route::get('/languages/{code}/path', [LanguageController::class, 'path']);