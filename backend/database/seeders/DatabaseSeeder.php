<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            LanguageSeeder::class,
            CurriculumSeeder::class,
            EnglishQuestionSeeder::class,
            LanguageCoursesSeeder::class,
            JapaneseQuestionSeeder::class,
            KoreanQuestionSeeder::class,
            VocabularySeeder::class,
            CommunitySeeder::class,
        ]);
    }
}