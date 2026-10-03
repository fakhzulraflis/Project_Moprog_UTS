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

            [
                'lesson_id' => 2,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "air"?',
                'correct_answer' => 'water',
                'options' => [
                    'water',
                    'milk',
                    'tea',
                    'juice',
                ],
                'order' => 1,
            ],

            [
                'lesson_id' => 2,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "kopi"?',
                'correct_answer' => 'coffee',
                'options' => [
                    'tea',
                    'coffee',
                    'water',
                    'milk',
                ],
                'order' => 2,
            ],

            [
                'lesson_id' => 2,
                'type' => 'translation',
                'prompt' => 'Saya minum air.',
                'correct_answer' => 'I drink water.',
                'options' => null,
                'order' => 3,
            ],

            [
                'lesson_id' => 2,
                'type' => 'word_bank',
                'prompt' => 'Saya minum kopi.',
                'correct_answer' => 'I drink coffee.',
                'options' => [
                    'coffee',
                    'I',
                    'drink',
                    'water',
                    'eat',
                    'tea',
                ],
                'order' => 4,
            ],

            [
                'lesson_id' => 2,
                'type' => 'fill_blank',
                'prompt' => 'I ___ tea.',
                'correct_answer' => 'drink',
                'options' => [
                    'drink',
                    'drinks',
                    'drinking',
                    'drank',
                ],
                'order' => 5,
            ],

            [
                'lesson_id' => 2,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "susu"?',
                'correct_answer' => 'milk',
                'options' => [
                    'milk',
                    'juice',
                    'coffee',
                    'water',
                ],
                'order' => 6,
            ],

            [
                'lesson_id' => 2,
                'type' => 'word_bank',
                'prompt' => 'Saya minum susu.',
                'correct_answer' => 'I drink milk.',
                'options' => [
                    'I',
                    'drink',
                    'milk',
                    'water',
                    'eat',
                    'coffee',
                ],
                'order' => 7,
            ],

            [
                'lesson_id' => 2,
                'type' => 'matching',
                'prompt' => 'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'correct_answer' => 'air=water,kopi=coffee,teh=tea',
                'options' => [
                    [
                        'left' => 'air',
                        'right' => 'water',
                    ],
                    [
                        'left' => 'kopi',
                        'right' => 'coffee',
                    ],
                    [
                        'left' => 'teh',
                        'right' => 'tea',
                    ],
                ],
                'order' => 8,
            ],

            [
                'lesson_id' => 2,
                'type' => 'translation',
                'prompt' => 'Saya minum jus.',
                'correct_answer' => 'I drink juice.',
                'options' => null,
                'order' => 9,
            ],

            [
                'lesson_id' => 2,
                'type' => 'multiple_choice',
                'prompt' => 'Apa bahasa Inggris dari "jus"?',
                'correct_answer' => 'juice',
                'options' => [
                    'juice',
                    'milk',
                    'tea',
                    'coffee',
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