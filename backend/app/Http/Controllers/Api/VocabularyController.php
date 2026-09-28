<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Vocabulary;

class VocabularyController extends Controller
{
    public function index()
    {
        $vocabularies = Vocabulary::all();

        return response()->json([
            'success' => true,
            'data' => $vocabularies,
        ]);
    }
}