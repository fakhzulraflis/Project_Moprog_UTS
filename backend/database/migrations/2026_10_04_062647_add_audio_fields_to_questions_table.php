<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questions', function (Blueprint $table) {
            $table->string('audio_text')->nullable()->after('options');
            $table->string('romanization')->nullable()->after('audio_text');
            $table->string('meaning')->nullable()->after('romanization');
        });
    }

    public function down(): void
    {
        Schema::table('questions', function (Blueprint $table) {
            $table->dropColumn(['audio_text', 'romanization', 'meaning']);
        });
    }
};