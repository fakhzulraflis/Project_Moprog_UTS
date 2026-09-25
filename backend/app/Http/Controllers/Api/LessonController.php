<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Lesson;

class LessonController extends Controller
{
    public function index()
    {
        $lessons = Lesson::with('questions')
            ->orderBy('order')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $lessons,
        ]);
    }
}