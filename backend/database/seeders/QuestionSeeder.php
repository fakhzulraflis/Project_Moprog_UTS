<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Question;

class QuestionSeeder extends Seeder
{
    public function run(): void
    {
        $questions = [
            /*
            |--------------------------------------------------------------------------
            | 1. MULTIPLE CHOICE
            |--------------------------------------------------------------------------
            */
            [
                'lesson_id' => 1,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "nasi"?',
                'correct_answer' => 'rice',
                'options' => [
                    'rice',
                    'bread',
                    'fish',
                    'meat',
                ],
                'order' => 1,
            ],

            /*
            |--------------------------------------------------------------------------
            | 2. MULTIPLE CHOICE
            |--------------------------------------------------------------------------
            */
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

            /*
            |--------------------------------------------------------------------------
            | 3. TRANSLATION
            |--------------------------------------------------------------------------
            */
            [
                'lesson_id' => 1,
                'type' => 'translation',
                'prompt' => 'Saya makan nasi.',
                'correct_answer' => 'I eat rice.',
                'options' => null,
                'order' => 3,
            ],

            /*
            |--------------------------------------------------------------------------
            | 4. WORD BANK
            |--------------------------------------------------------------------------
            */
            [
                'lesson_id' => 1,
                'type' => 'word_bank',
                'prompt' => 'Saya makan ayam.',
                'correct_answer' => 'I eat chicken.',
                'options' => [
                    'chicken',
                    'I',
                    'eat',
                    'rice',
                    'you',
                ],
                'order' => 4,
            ],

            /*
            |--------------------------------------------------------------------------
            | 5. FILL IN THE BLANK
            |--------------------------------------------------------------------------
            */
            [
                'lesson_id' => 1,
                'type' => 'fill_blank',
                'prompt' => 'I ___ rice.',
                'correct_answer' => 'eat',
                'options' => [
                    'eat',
                    'eats',
                    'eating',
                    'ate',
                ],
                'order' => 5,
            ],

            /*
            |--------------------------------------------------------------------------
            | 6. MULTIPLE CHOICE
            |--------------------------------------------------------------------------
            */
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
                'order' => 6,
            ],

            /*
            |--------------------------------------------------------------------------
            | 7. WORD BANK
            |--------------------------------------------------------------------------
            */
            [
                'lesson_id' => 1,
                'type' => 'word_bank',
                'prompt' => 'Saya makan telur.',
                'correct_answer' => 'I eat an egg.',
                'options' => [
                    'I',
                    'eat',
                    'an',
                    'egg',
                    'rice',
                    'chicken',
                ],
                'order' => 7,
            ],

            /*
            |--------------------------------------------------------------------------
            | 8. MATCHING
            |--------------------------------------------------------------------------
            */
            [
                'lesson_id' => 1,
                'type' => 'matching',
                'prompt' => 'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'correct_answer' => 'nasi=rice,ayam=chicken,ikan=fish',
                'options' => [
                    [
                        'left' => 'nasi',
                        'right' => 'rice',
                    ],
                    [
                        'left' => 'ayam',
                        'right' => 'chicken',
                    ],
                    [
                        'left' => 'ikan',
                        'right' => 'fish',
                    ],
                ],
                'order' => 8,
            ],

            /*
            |--------------------------------------------------------------------------
            | 9. TRANSLATION
            |--------------------------------------------------------------------------
            */
            [
                'lesson_id' => 1,
                'type' => 'translation',
                'prompt' => 'Saya makan roti.',
                'correct_answer' => 'I eat bread.',
                'options' => null,
                'order' => 9,
            ],

            /*
            |--------------------------------------------------------------------------
            | 10. MULTIPLE CHOICE
            |--------------------------------------------------------------------------
            */
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