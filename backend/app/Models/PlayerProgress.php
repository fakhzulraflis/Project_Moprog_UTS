<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlayerProgress extends Model
{
    protected $fillable = [
        'user_id',
        'gems',
        'total_xp',
        'bonus_hearts',
        'xp_boost_until',
        'completed_lesson_ids',
        'day',
        'xp_today',
        'lessons_today',
        'correct_today',
        'pets_today',
        'feeds_today',
        'purchases_today',
        'today_quest_ids',
        'rerolled_today',
        'completed_today',
        'claimed_today',
        'week',
        'lessons_this_week',
        'weekly_claimed',
        'month',
        'quests_this_month',
        'monthly_claimed',
        'stored_streak',
        'best_streak',
        'last_study_day',
        'streak_goal',
        'studied_days',
        'claimed_streak_milestones',
        'pending_streak_milestone',
        'last_spin_day',
        'last_spin_prize',
    ];

    protected $casts = [
        'xp_boost_until' => 'datetime',
        'completed_lesson_ids' => 'array',
        'today_quest_ids' => 'array',
        'completed_today' => 'array',
        'claimed_today' => 'array',
        'studied_days' => 'array',
        'claimed_streak_milestones' => 'array',
        'rerolled_today' => 'boolean',
        'weekly_claimed' => 'boolean',
        'monthly_claimed' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}