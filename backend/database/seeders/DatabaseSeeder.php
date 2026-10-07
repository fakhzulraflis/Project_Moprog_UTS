<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            SectionSeeder::class,
            UnitSeeder::class,
            LessonSeeder::class,
            QuestionSeeder::class,
            LanguageSeeder::class,
            LanguageCoursesSeeder::class,
            JapaneseQuestionSeeder::class,
            KoreanQuestionSeeder::class,
        ]);
    }
}