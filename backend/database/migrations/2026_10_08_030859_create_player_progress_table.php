<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('player_progress', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->unique()
                ->constrained()
                ->cascadeOnDelete();

            $table->unsignedInteger('gems')->default(50);
            $table->unsignedInteger('total_xp')->default(0);
            $table->unsignedInteger('bonus_hearts')->default(0);

            $table->dateTime('xp_boost_until')->nullable();

            $table->json('completed_lesson_ids')->nullable();

            $table->string('day')->default('');
            $table->unsignedInteger('xp_today')->default(0);
            $table->unsignedInteger('lessons_today')->default(0);
            $table->unsignedInteger('correct_today')->default(0);
            $table->unsignedInteger('pets_today')->default(0);
            $table->unsignedInteger('feeds_today')->default(0);
            $table->unsignedInteger('purchases_today')->default(0);

            $table->json('today_quest_ids')->nullable();
            $table->boolean('rerolled_today')->default(false);
            $table->json('completed_today')->nullable();
            $table->json('claimed_today')->nullable();

            $table->string('week')->default('');
            $table->unsignedInteger('lessons_this_week')->default(0);
            $table->boolean('weekly_claimed')->default(false);

            $table->string('month')->default('');
            $table->unsignedInteger('quests_this_month')->default(0);
            $table->boolean('monthly_claimed')->default(false);

            $table->unsignedInteger('stored_streak')->default(0);
            $table->unsignedInteger('best_streak')->default(0);
            $table->string('last_study_day')->default('');
            $table->unsignedInteger('streak_goal')->default(7);

            $table->json('studied_days')->nullable();
            $table->json('claimed_streak_milestones')->nullable();

            $table->unsignedInteger('pending_streak_milestone')->nullable();

            $table->string('last_spin_day')->default('');
            $table->integer('last_spin_prize')->default(-1);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('player_progress');
    }
};