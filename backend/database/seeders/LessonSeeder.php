<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Lesson;

class LessonSeeder extends Seeder
{
    public function run(): void
    {
        Lesson::updateOrCreate(
            ['id' => 1],
            [
                'unit_id' => 1,
                'title' => 'Basic Food',
                'order' => 1,
            ]

            
        );

        Lesson::updateOrCreate(
        ['id' => 2],
        [
            'unit_id' => 1,
            'title' => 'Basic Drinks',
            'order' => 2,
        ]
    );
    }
}