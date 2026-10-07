<?php

namespace Database\Seeders;

use App\Models\Question;
use Illuminate\Database\Seeder;

class QuestionSeeder extends Seeder
{
    public function run(): void
    {
        // Hapus soal lama di lesson yang dirombak, supaya tidak ada sisa
        Question::whereIn('lesson_id', [1, 2])->delete();

        foreach ($this->lessonOne() as $question) {
            Question::create($question);
        }

        foreach ($this->lessonTwo() as $question) {
            Question::create($question);
        }
    }

    /*
    |--------------------------------------------------------------------------
    | LESSON 1 - MAKANAN
    |--------------------------------------------------------------------------
    */
    private function lessonOne(): array
    {
        return [
            // 1. Pilih gambar
            $this->q(1, 1, 'image_choice', 'rice', 'nasi', [
                $this->food('nasi', 'rice'),
                $this->food('air', 'water'),
                $this->food('roti', 'bread'),
                $this->food('ikan', 'fish'),
            ], audio: 'rice', meaning: 'nasi'),

            // 2. Pilih terjemahan (Indonesia -> Inggris)
            $this->q(1, 2, 'multiple_choice', 'nasi', 'rice', [
                'bread',
                'rice',
                'fish',
                'meat',
            ]),

            // 3. Pilih gambar
            $this->q(1, 3, 'image_choice', 'chicken', 'ayam', [
                $this->food('ayam', 'chicken'),
                $this->food('ikan', 'fish'),
                $this->food('telur', 'egg'),
                $this->food('nasi', 'rice'),
            ], audio: 'chicken', meaning: 'ayam'),

            // 4. Ketuk apa yang kamu dengar
            $this->q(1, 4, 'listening', 'I eat rice.', 'I eat rice.', [
                'rice',
                'I',
                'eat',
                'bread',
                'you',
            ], audio: 'I eat rice.', meaning: 'Saya makan nasi.'),

            // 5. Susun kata
            $this->q(1, 5, 'word_bank', 'Saya makan ayam.', 'I eat chicken.', [
                'chicken',
                'I',
                'eat',
                'rice',
                'you',
            ]),

            // 6. Pilih terjemahan dengan audio (Inggris -> Indonesia)
            $this->q(1, 6, 'multiple_choice', 'fish', 'ikan', [
                'nasi',
                'ikan',
                'sup',
                'roti',
            ], audio: 'fish', meaning: 'ikan'),

            // 7. Mencocokkan pasangan
            $this->q(
                1,
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'nasi=rice,ayam=chicken,ikan=fish',
                [
                    ['left' => 'nasi', 'right' => 'rice'],
                    ['left' => 'ayam', 'right' => 'chicken'],
                    ['left' => 'ikan', 'right' => 'fish'],
                ]
            ),

            // 8. Terjemahan ketik
            $this->q(1, 8, 'translation', 'Saya makan roti.', 'I eat bread.'),

            // 9. Pilih gambar
            $this->q(1, 9, 'image_choice', 'egg', 'telur', [
                $this->food('pisang', 'banana'),
                $this->food('telur', 'egg'),
                $this->food('nasi', 'rice'),
                $this->food('roti', 'bread'),
            ], audio: 'egg', meaning: 'telur'),

            // 10. Ketuk apa yang kamu dengar
            $this->q(1, 10, 'listening', 'I eat an egg.', 'I eat an egg.', [
                'egg',
                'rice',
                'I',
                'an',
                'chicken',
                'eat',
            ], audio: 'I eat an egg.', meaning: 'Saya makan telur.'),

            // 11. Isian
            $this->q(1, 11, 'fill_blank', 'I ___ rice.', 'eat'),

            // 12. Pilih terjemahan dengan audio
            $this->q(1, 12, 'multiple_choice', 'banana', 'pisang', [
                'apel',
                'pisang',
                'nasi',
                'sup',
            ], audio: 'banana', meaning: 'pisang'),
        ];
    }

    /*
    |--------------------------------------------------------------------------
    | LESSON 2 - MINUMAN
    |--------------------------------------------------------------------------
    */
    private function lessonTwo(): array
    {
        return [
            // 1. Pilih gambar
            $this->q(2, 1, 'image_choice', 'water', 'air', [
                $this->food('air', 'water'),
                $this->food('susu', 'milk'),
                $this->food('kopi', 'coffee'),
                $this->food('teh', 'tea'),
            ], audio: 'water', meaning: 'air'),

            // 2. Pilih terjemahan (Indonesia -> Inggris)
            $this->q(2, 2, 'multiple_choice', 'kopi', 'coffee', [
                'tea',
                'coffee',
                'water',
                'milk',
            ]),

            // 3. Pilih gambar
            $this->q(2, 3, 'image_choice', 'tea', 'teh', [
                $this->food('kopi', 'coffee'),
                $this->food('jus', 'juice'),
                $this->food('teh', 'tea'),
                $this->food('air', 'water'),
            ], audio: 'tea', meaning: 'teh'),

            // 4. Ketuk apa yang kamu dengar
            $this->q(2, 4, 'listening', 'I drink water.', 'I drink water.', [
                'water',
                'I',
                'drink',
                'eat',
                'milk',
            ], audio: 'I drink water.', meaning: 'Saya minum air.'),

            // 5. Susun kata
            $this->q(2, 5, 'word_bank', 'Saya minum kopi.', 'I drink coffee.', [
                'coffee',
                'I',
                'drink',
                'water',
                'eat',
                'tea',
            ]),

            // 6. Pilih terjemahan dengan audio (Inggris -> Indonesia)
            $this->q(2, 6, 'multiple_choice', 'milk', 'susu', [
                'jus',
                'susu',
                'kopi',
                'air',
            ], audio: 'milk', meaning: 'susu'),

            // 7. Mencocokkan pasangan
            $this->q(
                2,
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'air=water,kopi=coffee,teh=tea',
                [
                    ['left' => 'air', 'right' => 'water'],
                    ['left' => 'kopi', 'right' => 'coffee'],
                    ['left' => 'teh', 'right' => 'tea'],
                ]
            ),

            // 8. Terjemahan ketik
            $this->q(2, 8, 'translation', 'Saya minum jus.', 'I drink juice.'),

            // 9. Pilih gambar
            $this->q(2, 9, 'image_choice', 'juice', 'jus', [
                $this->food('susu', 'milk'),
                $this->food('teh', 'tea'),
                $this->food('jus', 'juice'),
                $this->food('kopi', 'coffee'),
            ], audio: 'juice', meaning: 'jus'),

            // 10. Ketuk apa yang kamu dengar
            $this->q(2, 10, 'listening', 'I drink milk.', 'I drink milk.', [
                'milk',
                'drink',
                'I',
                'water',
                'coffee',
                'eat',
            ], audio: 'I drink milk.', meaning: 'Saya minum susu.'),

            // 11. Isian
            $this->q(2, 11, 'fill_blank', 'I ___ tea.', 'drink'),

            // 12. Pilih terjemahan dengan audio
            $this->q(2, 12, 'multiple_choice', 'please', 'tolong', [
                'terima kasih',
                'tolong',
                'maaf',
                'selamat pagi',
            ], audio: 'please', meaning: 'tolong'),
        ];
    }

    /*
    |--------------------------------------------------------------------------
    | HELPER
    |--------------------------------------------------------------------------
    */

    /** Satu baris soal. romanization dikosongkan (bahasa Inggris tidak perlu). */
    private function q(
        int $lesson,
        int $order,
        string $type,
        string $prompt,
        string $answer,
        ?array $options = null,
        ?string $audio = null,
        ?string $meaning = null
    ): array {
        return [
            'lesson_id' => $lesson,
            'order' => $order,
            'type' => $type,
            'prompt' => $prompt,
            'correct_answer' => $answer,
            'options' => $options,
            'audio_text' => $audio,
            'romanization' => null,
            'meaning' => $meaning,
        ];
    }

    /** Satu pilihan untuk soal image_choice. */
    private function food(string $label, string $file): array
    {
        return [
            'label' => $label,
            'image' => "assets/foods/{$file}.png",
        ];
    }
}