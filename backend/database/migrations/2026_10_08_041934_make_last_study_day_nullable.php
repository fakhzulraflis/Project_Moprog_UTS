<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('player_progress', function (Blueprint $table) {
            $table->string('last_study_day')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('player_progress', function (Blueprint $table) {
            $table->string('last_study_day')->default('')->nullable(false)->change();
        });
    }
};