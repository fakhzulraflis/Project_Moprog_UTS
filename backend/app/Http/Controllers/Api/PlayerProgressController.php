<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PlayerProgress;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlayerProgressController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $progress = PlayerProgress::firstOrCreate(
            ['user_id' => $request->user()->id],
            [
                'completed_lesson_ids' => [],
                'today_quest_ids' => [],
                'completed_today' => [],
                'claimed_today' => [],
                'studied_days' => [],
                'claimed_streak_milestones' => [],
            ]
        );

        return response()->json([
            'success' => true,
            'data' => $progress,
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'gems' => ['required', 'integer', 'min:0'],
            'total_xp' => ['required', 'integer', 'min:0'],
            'bonus_hearts' => ['required', 'integer', 'min:0'],
            'xp_boost_until' => ['nullable', 'date'],

            'completed_lesson_ids' => ['nullable', 'array'],
            'completed_lesson_ids.*' => ['integer'],

            'day' => ['required', 'string'],
            'xp_today' => ['required', 'integer', 'min:0'],
            'lessons_today' => ['required', 'integer', 'min:0'],
            'correct_today' => ['required', 'integer', 'min:0'],
            'pets_today' => ['required', 'integer', 'min:0'],
            'feeds_today' => ['required', 'integer', 'min:0'],
            'purchases_today' => ['required', 'integer', 'min:0'],

            'today_quest_ids' => ['nullable', 'array'],
            'completed_today' => ['nullable', 'array'],
            'claimed_today' => ['nullable', 'array'],

            'rerolled_today' => ['required', 'boolean'],

            'week' => ['required', 'string'],
            'lessons_this_week' => ['required', 'integer', 'min:0'],
            'weekly_claimed' => ['required', 'boolean'],

            'month' => ['required', 'string'],
            'quests_this_month' => ['required', 'integer', 'min:0'],
            'monthly_claimed' => ['required', 'boolean'],

            'stored_streak' => ['required', 'integer', 'min:0'],
            'best_streak' => ['required', 'integer', 'min:0'],
            'last_study_day' => ['nullable', 'string'],
            'streak_goal' => ['required', 'integer', 'min:0'],

            'studied_days' => ['nullable', 'array'],
            'claimed_streak_milestones' => ['nullable', 'array'],
            'pending_streak_milestone' => ['nullable', 'integer', 'min:0'],

            'last_spin_day' => ['nullable', 'string'],
            'last_spin_prize' => ['nullable', 'integer'],
        ]);

        $progress = PlayerProgress::updateOrCreate(
            ['user_id' => $request->user()->id],
            $validated
        );

        return response()->json([
            'success' => true,
            'data' => $progress->fresh(),
        ]);
    }
}