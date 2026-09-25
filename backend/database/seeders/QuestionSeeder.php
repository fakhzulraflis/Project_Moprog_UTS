<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Question;

class QuestionSeeder extends Seeder
{
    public function run(): void
    {
        $questions = [
            [
                'lesson_id' => 1,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "nasi"?',
                'correct_answer' => 'rice',
                'options' => [
                    'rice',
                    'bread',
                    'meat',
                    'fish',
                ],
                'order' => 1,
            ],

            [
                'lesson_id' => 1,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "ayam"?',
                'correct_answer' => 'chicken',
                'options' => [
                    'fish',
                    'chicken',
                    'egg',
                    'meat',
                ],
                'order' => 2,
            ],

            [
                'lesson_id' => 1,
                'type' => 'translation',
                'prompt' => 'Saya makan nasi.',
                'correct_answer' => 'I eat rice.',
                'options' => null,
                'order' => 3,
            ],

            [
                'lesson_id' => 1,
                'type' => 'translation',
                'prompt' => 'Saya makan ayam.',
                'correct_answer' => 'I eat chicken.',
                'options' => null,
                'order' => 4,
            ],

            [
                'lesson_id' => 1,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "ikan"?',
                'correct_answer' => 'fish',
                'options' => [
                    'fish',
                    'rice',
                    'soup',
                    'bread',
                ],
                'order' => 5,
            ],

            [
                'lesson_id' => 1,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "telur"?',
                'correct_answer' => 'egg',
                'options' => [
                    'apple',
                    'egg',
                    'banana',
                    'vegetable',
                ],
                'order' => 6,
            ],

            [
                'lesson_id' => 1,
                'type' => 'translation',
                'prompt' => 'Saya makan telur.',
                'correct_answer' => 'I eat an egg.',
                'options' => null,
                'order' => 7,
            ],

            [
                'lesson_id' => 1,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "apel"?',
                'correct_answer' => 'apple',
                'options' => [
                    'banana',
                    'apple',
                    'orange',
                    'bread',
                ],
                'order' => 8,
            ],

            [
                'lesson_id' => 1,
                'type' => 'translation',
                'prompt' => 'Saya makan roti.',
                'correct_answer' => 'I eat bread.',
                'options' => null,
                'order' => 9,
            ],

            [
                'lesson_id' => 1,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "pisang"?',
                'correct_answer' => 'banana',
                'options' => [
                    'apple',
                    'banana',
                    'rice',
                    'soup',
                ],
                'order' => 10,
            ],
        ];

        foreach ($questions as $question) {
            Question::updateOrCreate(
                [
                    'lesson_id' => $question['lesson_id'],
                    'order' => $question['order'],
                ],
                $question
            );
        }
    }
}