<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Question;

class QuestionController extends Controller
{
    public function index($lessonId)
    {
        $questions = Question::where('lesson_id', $lessonId)
            ->orderBy('order')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $questions,
        ]);
    }
}