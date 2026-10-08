<?php

namespace Database\Seeders;

class EnglishQuestionSeeder extends LanguageQuestionSeeder
{
    protected function languageCode(): string
    {
        return 'en';
    }

    protected function lessons(): array
    {
        return [
            'Makanan Dasar' => $this->lessonOne(),
            'Minuman Dasar' => $this->lessonTwo(),
            'Sapaan' => $this->lessonThree(),
            'Tantangan Dasar' => $this->lessonFour(),
        ];
    }

    // ---------------- Pelajaran 1: Makanan Dasar ----------------
    private function lessonOne(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Rice',
                'nasi',
                [
                    $this->pic('nasi', 'rice'),
                    $this->pic('air', 'water'),
                    $this->pic('roti', 'bread'),
                    $this->pic('ikan', 'fish'),
                ],
                audio: 'Rice',
                meaning: 'nasi'
            ),

            $this->q(
                2,
                'multiple_choice',
                'nasi',
                'rice',
                [
                    $this->o('bread', ''),
                    $this->o('rice', ''),
                    $this->o('fish', ''),
                    $this->o('meat', ''),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                'Chicken',
                'ayam',
                [
                    $this->pic('ayam', 'chicken'),
                    $this->pic('ikan', 'fish'),
                    $this->pic('telur', 'egg'),
                    $this->pic('nasi', 'rice'),
                ],
                audio: 'Chicken',
                meaning: 'ayam'
            ),

            $this->q(
                4,
                'listening',
                'I eat rice.',
                'I eat rice.',
                [
                    $this->o('bread', ''),
                    $this->o('eat', ''),
                    $this->o('rice', ''),
                    $this->o('drink', ''),
                    $this->o('I', ''),
                ],
                audio: 'I eat rice.',
                meaning: 'Saya makan nasi.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya makan roti.',
                'I eat bread.',
                [
                    $this->o('eat', ''),
                    $this->o('rice', ''),
                    $this->o('bread', ''),
                    $this->o('I', ''),
                    $this->o('drink', ''),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                'Fish',
                'ikan',
                [
                    'nasi',
                    'ikan',
                    'sup',
                    'roti',
                ],
                audio: 'Fish',
                meaning: 'ikan'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'nasi=rice,ayam=chicken,ikan=fish',
                [
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
                ]
            ),

            $this->q(
                8,
                'word_bank',
                'Saya makan telur.',
                'I eat an egg.',
                [
                    $this->o('I', ''),
                    $this->o('eat', ''),
                    $this->o('egg', ''),
                    $this->o('an', ''),
                    $this->o('rice', ''),
                    $this->o('bread', ''),
                ]
            ),

            $this->q(
                9,
                'image_choice',
                'Egg',
                'telur',
                [
                    $this->pic('pisang', 'banana'),
                    $this->pic('telur', 'egg'),
                    $this->pic('nasi', 'rice'),
                    $this->pic('roti', 'bread'),
                ],
                audio: 'Egg',
                meaning: 'telur'
            ),

            $this->q(
                10,
                'listening',
                'I eat bread.',
                'I eat bread.',
                [
                    $this->o('eat', ''),
                    $this->o('I', ''),
                    $this->o('bread', ''),
                    $this->o('rice', ''),
                    $this->o('drink', ''),
                ],
                audio: 'I eat bread.',
                meaning: 'Saya makan roti.'
            ),

            $this->q(
                11,
                'fill_blank',
                'I ___ rice.',
                'eat',
                [
                    $this->o('drink', ''),
                    $this->o('eat', ''),
                    $this->o('bread', ''),
                    $this->o('rice', ''),
                ],
                meaning: 'makan'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Banana',
                'pisang',
                [
                    'apel',
                    'pisang',
                    'nasi',
                    'sup',
                ],
                audio: 'Banana',
                meaning: 'pisang'
            ),
        ];
    }

    // ---------------- Pelajaran 2: Minuman Dasar ----------------
    private function lessonTwo(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Water',
                'air',
                [
                    $this->pic('air', 'water'),
                    $this->pic('susu', 'milk'),
                    $this->pic('kopi', 'coffee'),
                    $this->pic('teh', 'tea'),
                ],
                audio: 'Water',
                meaning: 'air'
            ),

            $this->q(
                2,
                'multiple_choice',
                'kopi',
                'coffee',
                [
                    $this->o('tea', ''),
                    $this->o('coffee', ''),
                    $this->o('water', ''),
                    $this->o('milk', ''),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                'Tea',
                'teh',
                [
                    $this->pic('kopi', 'coffee'),
                    $this->pic('jus', 'juice'),
                    $this->pic('teh', 'tea'),
                    $this->pic('air', 'water'),
                ],
                audio: 'Tea',
                meaning: 'teh'
            ),

            $this->q(
                4,
                'listening',
                'I drink water.',
                'I drink water.',
                [
                    $this->o('drink', ''),
                    $this->o('eat', ''),
                    $this->o('water', ''),
                    $this->o('milk', ''),
                    $this->o('I', ''),
                ],
                audio: 'I drink water.',
                meaning: 'Saya minum air.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya minum kopi.',
                'I drink coffee.',
                [
                    $this->o('drink', ''),
                    $this->o('coffee', ''),
                    $this->o('I', ''),
                    $this->o('water', ''),
                    $this->o('eat', ''),
                    $this->o('tea', ''),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                'Milk',
                'susu',
                [
                    'jus',
                    'susu',
                    'kopi',
                    'air',
                ],
                audio: 'Milk',
                meaning: 'susu'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'air=water,kopi=coffee,teh=tea',
                [
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
                ]
            ),

            $this->q(
                8,
                'word_bank',
                'Saya minum jus.',
                'I drink juice.',
                [
                    $this->o('juice', ''),
                    $this->o('drink', ''),
                    $this->o('I', ''),
                    $this->o('water', ''),
                    $this->o('eat', ''),
                    $this->o('milk', ''),
                ]
            ),

            $this->q(
                9,
                'image_choice',
                'Juice',
                'jus',
                [
                    $this->pic('susu', 'milk'),
                    $this->pic('teh', 'tea'),
                    $this->pic('jus', 'juice'),
                    $this->pic('kopi', 'coffee'),
                ],
                audio: 'Juice',
                meaning: 'jus'
            ),

            $this->q(
                10,
                'listening',
                'I drink milk.',
                'I drink milk.',
                [
                    $this->o('drink', ''),
                    $this->o('milk', ''),
                    $this->o('I', ''),
                    $this->o('water', ''),
                    $this->o('coffee', ''),
                    $this->o('eat', ''),
                ],
                audio: 'I drink milk.',
                meaning: 'Saya minum susu.'
            ),

            $this->q(
                11,
                'fill_blank',
                'I ___ tea.',
                'drink',
                [
                    $this->o('drink', ''),
                    $this->o('eat', ''),
                    $this->o('water', ''),
                    $this->o('tea', ''),
                ],
                meaning: 'minum'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Please',
                'tolong',
                [
                    'terima kasih',
                    'tolong',
                    'maaf',
                    'selamat pagi',
                ],
                audio: 'Please',
                meaning: 'tolong'
            ),
        ];
    }

    // ---------------- Pelajaran 3: Sapaan ----------------
    private function lessonThree(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Hello',
                'halo',
                [
                    $this->pic('halo', 'hello'),
                    $this->pic('selamat tinggal', 'goodbye'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('maaf', 'sorry'),
                ],
                audio: 'Hello',
                meaning: 'halo'
            ),

            $this->q(
                2,
                'multiple_choice',
                'halo',
                'hello',
                [
                    $this->o('goodbye', ''),
                    $this->o('hello', ''),
                    $this->o('thank you', ''),
                    $this->o('sorry', ''),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                'Goodbye',
                'selamat tinggal',
                [
                    $this->pic('halo', 'hello'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('selamat tinggal', 'goodbye'),
                    $this->pic('maaf', 'sorry'),
                ],
                audio: 'Goodbye',
                meaning: 'selamat tinggal'
            ),

            $this->q(
                4,
                'listening',
                'Hello',
                'Hello',
                [
                    $this->o('goodbye', ''),
                    $this->o('hello', ''),
                    $this->o('thank you', ''),
                    $this->o('sorry', ''),
                ],
                audio: 'Hello',
                meaning: 'Halo.'
            ),

            $this->q(
                5,
                'word_bank',
                'Terima kasih.',
                'Thank you.',
                [
                    $this->o('Thank', ''),
                    $this->o('you', ''),
                    $this->o('hello', ''),
                    $this->o('goodbye', ''),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                'Thank you',
                'terima kasih',
                [
                    'maaf',
                    'selamat tinggal',
                    'terima kasih',
                    'halo',
                ],
                audio: 'Thank you',
                meaning: 'terima kasih'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'halo=hello,selamat tinggal=goodbye,terima kasih=thank you',
                [
                    [
                        'left' => 'halo',
                        'right' => 'hello',
                    ],
                    [
                        'left' => 'selamat tinggal',
                        'right' => 'goodbye',
                    ],
                    [
                        'left' => 'terima kasih',
                        'right' => 'thank you',
                    ],
                ]
            ),

            $this->q(
                8,
                'translation',
                'Terima kasih.',
                'Thank you.'
            ),

            $this->q(
                9,
                'image_choice',
                'Thank you',
                'terima kasih',
                [
                    $this->pic('maaf', 'sorry'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('halo', 'hello'),
                    $this->pic('selamat tinggal', 'goodbye'),
                ],
                audio: 'Thank you',
                meaning: 'terima kasih'
            ),

            $this->q(
                10,
                'listening',
                'Thank you',
                'Thank you',
                [
                    $this->o('sorry', ''),
                    $this->o('hello', ''),
                    $this->o('thank you', ''),
                    $this->o('goodbye', ''),
                ],
                audio: 'Thank you',
                meaning: 'Terima kasih.'
            ),

            $this->q(
                11,
                'fill_blank',
                'Good morning, ___!',
                'good',
                [
                    $this->o('good', ''),
                    $this->o('thank', ''),
                    $this->o('hello', ''),
                    $this->o('goodbye', ''),
                ],
                meaning: 'selamat pagi'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Sorry',
                'maaf',
                [
                    'halo',
                    'terima kasih',
                    'maaf',
                    'selamat tinggal',
                ],
                audio: 'Sorry',
                meaning: 'maaf'
            ),
        ];
    }

    // ---------------- Pelajaran 4: Tantangan Dasar ----------------
    private function lessonFour(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Rice',
                'nasi',
                [
                    $this->pic('nasi', 'rice'),
                    $this->pic('ayam', 'chicken'),
                    $this->pic('ikan', 'fish'),
                    $this->pic('telur', 'egg'),
                ],
                audio: 'Rice',
                meaning: 'nasi'
            ),

            $this->q(
                2,
                'multiple_choice',
                'susu',
                'milk',
                [
                    $this->o('water', ''),
                    $this->o('milk', ''),
                    $this->o('coffee', ''),
                    $this->o('tea', ''),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                'Thank you',
                'terima kasih',
                [
                    $this->pic('maaf', 'sorry'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('halo', 'hello'),
                    $this->pic('selamat tinggal', 'goodbye'),
                ],
                audio: 'Thank you',
                meaning: 'terima kasih'
            ),

            $this->q(
                4,
                'listening',
                'Dengarkan kalimat berikut.',
                'I drink water.',
                [
                    $this->o('water', ''),
                    $this->o('drink', ''),
                    $this->o('rice', ''),
                    $this->o('eat', ''),
                    $this->o('I', ''),
                ],
                audio: 'I drink water.',
                meaning: 'Saya minum air.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya makan nasi.',
                'I eat rice.',
                [
                    $this->o('I', ''),
                    $this->o('eat', ''),
                    $this->o('rice', ''),
                    $this->o('drink', ''),
                    $this->o('bread', ''),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                'Goodbye',
                'selamat tinggal',
                [
                    'halo',
                    'terima kasih',
                    'selamat tinggal',
                    'maaf',
                ],
                audio: 'Goodbye',
                meaning: 'selamat tinggal'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Inggris.',
                'nasi=rice,air=water,terima kasih=thank you',
                [
                    [
                        'left' => 'nasi',
                        'right' => 'rice',
                    ],
                    [
                        'left' => 'air',
                        'right' => 'water',
                    ],
                    [
                        'left' => 'terima kasih',
                        'right' => 'thank you',
                    ],
                ]
            ),

            $this->q(
                8,
                'translation',
                'Saya minum kopi.',
                'I drink coffee.'
            ),

            $this->q(
                9,
                'image_choice',
                'Banana',
                'pisang',
                [
                    $this->pic('pisang', 'banana'),
                    $this->pic('roti', 'bread'),
                    $this->pic('telur', 'egg'),
                    $this->pic('nasi', 'rice'),
                ],
                audio: 'Banana',
                meaning: 'pisang'
            ),

            $this->q(
                10,
                'listening',
                'Dengarkan kalimat berikut.',
                'I eat bread.',
                [
                    $this->o('bread', ''),
                    $this->o('eat', ''),
                    $this->o('drink', ''),
                    $this->o('rice', ''),
                    $this->o('I', ''),
                ],
                audio: 'I eat bread.',
                meaning: 'Saya makan roti.'
            ),

            $this->q(
                11,
                'fill_blank',
                'Good morning, ___!',
                'good',
                [
                    $this->o('good', ''),
                    $this->o('thank', ''),
                    $this->o('hello', ''),
                    $this->o('goodbye', ''),
                ],
                meaning: 'selamat pagi'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Sorry',
                'maaf',
                [
                    'halo',
                    'terima kasih',
                    'maaf',
                    'selamat tinggal',
                ],
                audio: 'Sorry',
                meaning: 'maaf'
            ),
        ];
    }
}