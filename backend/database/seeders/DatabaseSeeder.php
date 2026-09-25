<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            VocabularySeeder::class,
            SectionSeeder::class,
            UnitSeeder::class,
            LessonSeeder::class,
            QuestionSeeder::class,
        ]);
    }
}