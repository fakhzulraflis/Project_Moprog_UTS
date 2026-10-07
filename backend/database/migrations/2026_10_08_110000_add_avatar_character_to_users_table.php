<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Karakter yang dipilih user untuk foto profilnya (null = ikut bahasa belajar).
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('avatar_character')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('avatar_character');
        });
    }
};
