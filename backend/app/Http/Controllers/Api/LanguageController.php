<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Language;

class LanguageController extends Controller
{
    public function index()
    {
        $languages = Language::where('is_active', true)
            ->orderBy('order')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $languages,
        ]);
    }

    public function path(string $code)
    {
        $language = Language::where('code', $code)->firstOrFail();

        $sections = $language->sections()
            ->with([
                'units' => fn ($q) => $q->orderBy('id'),
                'units.lessons' => fn ($q) => $q->orderBy('id'),
            ])
            ->orderBy('id')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'language' => $language,
                'sections' => $sections,
            ],
        ]);
    }
}