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

    private function lessonOne(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Pilih gambar yang menunjukkan "nasi".',
                'nasi',
                [
                    $this->pic('nasi', 'rice'),
                    $this->pic('ayam', 'chicken'),
                    $this->pic('ikan', 'fish'),
                    $this->pic('roti', 'bread'),
                ],
                'rice',
                null,
                'nasi'
            ),

            $this->q(
                2,
                'multiple_choice',
                'Apa bahasa Inggris dari "nasi"?',
                'rice',
                [
                    $this->o('chicken', ''),
                    $this->o('rice', ''),
                    $this->o('bread', ''),
                    $this->o('fish', ''),
                ],
                'rice',
                null,
                'nasi'
            ),

            $this->q(
                3,
                'image_choice',
                'Pilih gambar yang menunjukkan "ayam".',
                'ayam',
                [
                    $this->pic('roti', 'bread'),
                    $this->pic('ayam', 'chicken'),
                    $this->pic('telur', 'egg'),
                    $this->pic('ikan', 'fish'),
                ],
                'chicken',
                null,
                'ayam'
            ),

            $this->q(
                4,
                'listening',
                'Dengarkan kata berikut.',
                'chicken',
                [
                    $this->o('fish', ''),
                    $this->o('bread', ''),
                    $this->o('chicken', ''),
                    $this->o('rice', ''),
                ],
                'chicken',
                null,
                'ayam'
            ),

            $this->q(
                5,
                'word_bank',
                'Susun kata berikut menjadi kalimat yang benar.',
                'I eat rice.',
                [
                    $this->o('rice', ''),
                    $this->o('I', ''),
                    $this->o('eat', ''),
                    $this->o('drink', ''),
                    $this->o('bread', ''),
                ],
                'I eat rice.',
                null,
                'Saya makan nasi.'
            ),

            $this->q(
                6,
                'multiple_choice',
                'Apa bahasa Inggris dari "ikan"?',
                'fish',
                [
                    $this->o('egg', ''),
                    $this->o('fish', ''),
                    $this->o('chicken', ''),
                    $this->o('rice', ''),
                ],
                'fish',
                null,
                'ikan'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Inggris dengan artinya.',
                'rice=nasi,chicken=ayam,fish=ikan',
                [
                    [
                        'left' => 'rice',
                        'right' => 'nasi',
                    ],
                    [
                        'left' => 'chicken',
                        'right' => 'ayam',
                    ],
                    [
                        'left' => 'fish',
                        'right' => 'ikan',
                    ],
                ]
            ),

            $this->q(
                8,
                'translation',
                'Terjemahkan kalimat berikut ke bahasa Inggris.',
                'I eat bread.',
                null,
                'I eat bread.',
                null,
                'Saya makan roti.'
            ),

            $this->q(
                9,
                'image_choice',
                'Pilih gambar yang menunjukkan "telur".',
                'telur',
                [
                    $this->pic('ikan', 'fish'),
                    $this->pic('telur', 'egg'),
                    $this->pic('nasi', 'rice'),
                    $this->pic('ayam', 'chicken'),
                ],
                'egg',
                null,
                'telur'
            ),

            $this->q(
                10,
                'listening',
                'Dengarkan kata berikut.',
                'bread',
                [
                    $this->o('rice', ''),
                    $this->o('egg', ''),
                    $this->o('bread', ''),
                    $this->o('fish', ''),
                ],
                'bread',
                null,
                'roti'
            ),

            $this->q(
                11,
                'fill_blank',
                'I eat ___ for breakfast.',
                'egg',
                [
                    $this->o('fish', ''),
                    $this->o('egg', ''),
                    $this->o('rice', ''),
                    $this->o('bread', ''),
                ],
                'I eat egg for breakfast.',
                null,
                'Saya makan telur untuk sarapan.'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Apa bahasa Inggris dari "roti"?',
                'bread',
                [
                    $this->o('fish', ''),
                    $this->o('rice', ''),
                    $this->o('bread', ''),
                    $this->o('egg', ''),
                ],
                'bread',
                null,
                'roti'
            ),
        ];
    }

    private function lessonTwo(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Pilih gambar yang menunjukkan "air".',
                'air',
                [
                    $this->pic('kopi', 'coffee'),
                    $this->pic('air', 'water'),
                    $this->pic('susu', 'milk'),
                    $this->pic('jus', 'juice'),
                ],
                'water',
                null,
                'air'
            ),

            $this->q(
                2,
                'multiple_choice',
                'Apa bahasa Inggris dari "air"?',
                'water',
                [
                    $this->o('coffee', ''),
                    $this->o('water', ''),
                    $this->o('milk', ''),
                    $this->o('juice', ''),
                ],
                'water',
                null,
                'air'
            ),

            $this->q(
                3,
                'image_choice',
                'Pilih gambar yang menunjukkan "kopi".',
                'kopi',
                [
                    $this->pic('teh', 'tea'),
                    $this->pic('jus', 'juice'),
                    $this->pic('kopi', 'coffee'),
                    $this->pic('air', 'water'),
                ],
                'coffee',
                null,
                'kopi'
            ),

            $this->q(
                4,
                'listening',
                'Dengarkan kata berikut.',
                'milk',
                [
                    $this->o('juice', ''),
                    $this->o('coffee', ''),
                    $this->o('water', ''),
                    $this->o('milk', ''),
                ],
                'milk',
                null,
                'susu'
            ),

            $this->q(
                5,
                'word_bank',
                'Susun kata berikut menjadi kalimat yang benar.',
                'I drink water.',
                [
                    $this->o('water', ''),
                    $this->o('drink', ''),
                    $this->o('I', ''),
                    $this->o('coffee', ''),
                    $this->o('milk', ''),
                ],
                'I drink water.',
                null,
                'Saya minum air.'
            ),

            $this->q(
                6,
                'multiple_choice',
                'Apa bahasa Inggris dari "teh"?',
                'tea',
                [
                    $this->o('juice', ''),
                    $this->o('tea', ''),
                    $this->o('milk', ''),
                    $this->o('coffee', ''),
                ],
                'tea',
                null,
                'teh'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Inggris dengan artinya.',
                'water=air,coffee=kopi,milk=susu',
                [
                    [
                        'left' => 'water',
                        'right' => 'air',
                    ],
                    [
                        'left' => 'coffee',
                        'right' => 'kopi',
                    ],
                    [
                        'left' => 'milk',
                        'right' => 'susu',
                    ],
                ]
            ),

            $this->q(
                8,
                'translation',
                'Terjemahkan kalimat berikut ke bahasa Inggris.',
                'I drink coffee.',
                null,
                'I drink coffee.',
                null,
                'Saya minum kopi.'
            ),

            $this->q(
                9,
                'image_choice',
                'Pilih gambar yang menunjukkan "jus".',
                'jus',
                [
                    $this->pic('susu', 'milk'),
                    $this->pic('teh', 'tea'),
                    $this->pic('jus', 'juice'),
                    $this->pic('kopi', 'coffee'),
                ],
                'juice',
                null,
                'jus'
            ),

            $this->q(
                10,
                'listening',
                'Dengarkan kata berikut.',
                'coffee',
                [
                    $this->o('tea', ''),
                    $this->o('juice', ''),
                    $this->o('coffee', ''),
                    $this->o('water', ''),
                ],
                'coffee',
                null,
                'kopi'
            ),

            $this->q(
                11,
                'fill_blank',
                'I drink ___ every morning.',
                'milk',
                [
                    $this->o('juice', ''),
                    $this->o('milk', ''),
                    $this->o('coffee', ''),
                    $this->o('water', ''),
                ],
                'I drink milk every morning.',
                null,
                'Saya minum susu setiap pagi.'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Apa bahasa Inggris dari "jus"?',
                'juice',
                [
                    $this->o('water', ''),
                    $this->o('tea', ''),
                    $this->o('juice', ''),
                    $this->o('milk', ''),
                ],
                'juice',
                null,
                'jus'
            ),
        ];
    }

    private function lessonThree(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Pilih gambar yang menunjukkan "halo".',
                'halo',
                [
                    $this->pic('halo', 'hello'),
                    $this->pic('selamat tinggal', 'goodbye'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('maaf', 'sorry'),
                ],
                'Hello',
                null,
                'halo'
            ),

            $this->q(
                2,
                'multiple_choice',
                'Apa bahasa Inggris dari "halo"?',
                'hello',
                [
                    $this->o('goodbye', ''),
                    $this->o('hello', ''),
                    $this->o('thank you', ''),
                    $this->o('sorry', ''),
                ],
                'Hello',
                null,
                'halo'
            ),

            $this->q(
                3,
                'image_choice',
                'Pilih gambar yang menunjukkan "selamat tinggal".',
                'selamat tinggal',
                [
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('maaf', 'sorry'),
                    $this->pic('selamat tinggal', 'goodbye'),
                    $this->pic('halo', 'hello'),
                ],
                'Goodbye',
                null,
                'selamat tinggal'
            ),

            $this->q(
                4,
                'listening',
                'Dengarkan kata berikut.',
                'Hello!',
                [
                    $this->o('Goodbye', ''),
                    $this->o('Hello', ''),
                    $this->o('Thank you', ''),
                    $this->o('Sorry', ''),
                ],
                'Hello!',
                null,
                'Halo!'
            ),

            $this->q(
                5,
                'word_bank',
                'Susun kata berikut menjadi kalimat yang benar.',
                'Hello see you.',
                [
                    $this->o('you', ''),
                    $this->o('Hello', ''),
                    $this->o('goodbye', ''),
                    $this->o('see', ''),
                    $this->o('Thank', ''),
                ],
                'Hello see you.',
                null,
                'Halo, sampai jumpa.'
            ),

            $this->q(
                6,
                'multiple_choice',
                'Apa bahasa Inggris dari "terima kasih"?',
                'thank you',
                [
                    $this->o('sorry', ''),
                    $this->o('goodbye', ''),
                    $this->o('thank you', ''),
                    $this->o('hello', ''),
                ],
                'Thank you',
                null,
                'terima kasih'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Inggris dengan artinya.',
                'hello=halo,goodbye=selamat tinggal,thank you=terima kasih',
                [
                    [
                        'left' => 'hello',
                        'right' => 'halo',
                    ],
                    [
                        'left' => 'goodbye',
                        'right' => 'selamat tinggal',
                    ],
                    [
                        'left' => 'thank you',
                        'right' => 'terima kasih',
                    ],
                ]
            ),

            $this->q(
                8,
                'translation',
                'Terjemahkan kalimat berikut ke bahasa Inggris.',
                'I am sorry.',
                null,
                'I am sorry.',
                null,
                'Saya minta maaf.'
            ),

            $this->q(
                9,
                'image_choice',
                'Pilih gambar yang menunjukkan "terima kasih".',
                'terima kasih',
                [
                    $this->pic('maaf', 'sorry'),
                    $this->pic('halo', 'hello'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('selamat tinggal', 'goodbye'),
                ],
                'Thank you',
                null,
                'terima kasih'
            ),

            $this->q(
                10,
                'listening',
                'Dengarkan kata berikut.',
                'Thank you!',
                [
                    $this->o('Sorry', ''),
                    $this->o('Hello', ''),
                    $this->o('Thank you', ''),
                    $this->o('Goodbye', ''),
                ],
                'Thank you!',
                null,
                'Terima kasih!'
            ),

            $this->q(
                11,
                'fill_blank',
                'Good ___!',
                'morning',
                [
                    $this->o('morning', ''),
                    $this->o('goodbye', ''),
                    $this->o('thank', ''),
                    $this->o('sorry', ''),
                ],
                'Good morning!',
                null,
                'Selamat pagi!'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Apa bahasa Inggris dari "maaf"?',
                'sorry',
                [
                    $this->o('hello', ''),
                    $this->o('thank you', ''),
                    $this->o('sorry', ''),
                    $this->o('goodbye', ''),
                ],
                'Sorry',
                null,
                'maaf'
            ),
        ];
    }

    private function lessonFour(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                'Pilih gambar yang menunjukkan "nasi".',
                'nasi',
                [
                    $this->pic('kopi', 'coffee'),
                    $this->pic('nasi', 'rice'),
                    $this->pic('halo', 'hello'),
                    $this->pic('jus', 'juice'),
                ],
                'rice',
                null,
                'nasi'
            ),

            $this->q(
                2,
                'multiple_choice',
                'Apa bahasa Inggris dari "susu"?',
                'milk',
                [
                    $this->o('water', ''),
                    $this->o('juice', ''),
                    $this->o('milk', ''),
                    $this->o('tea', ''),
                ],
                'milk',
                null,
                'susu'
            ),

            $this->q(
                3,
                'listening',
                'Dengarkan kata berikut.',
                'Goodbye',
                [
                    $this->o('Hello', ''),
                    $this->o('Sorry', ''),
                    $this->o('Goodbye', ''),
                    $this->o('Thank you', ''),
                ],
                'Goodbye',
                null,
                'Selamat tinggal'
            ),

            $this->q(
                4,
                'word_bank',
                'Susun kata berikut menjadi kalimat yang benar.',
                'I drink milk.',
                [
                    $this->o('milk', ''),
                    $this->o('I', ''),
                    $this->o('drink', ''),
                    $this->o('rice', ''),
                    $this->o('eat', ''),
                ],
                'I drink milk.',
                null,
                'Saya minum susu.'
            ),

            $this->q(
                5,
                'translation',
                'Terjemahkan kalimat berikut ke bahasa Inggris.',
                'I eat rice.',
                null,
                'I eat rice.',
                null,
                'Saya makan nasi.'
            ),

            $this->q(
                6,
                'image_choice',
                'Pilih gambar yang menunjukkan "terima kasih".',
                'terima kasih',
                [
                    $this->pic('halo', 'hello'),
                    $this->pic('maaf', 'sorry'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('selamat tinggal', 'goodbye'),
                ],
                'Thank you',
                null,
                'terima kasih'
            ),

            $this->q(
                7,
                'multiple_choice',
                'Apa arti dari "I drink water"?',
                'Saya minum air.',
                [
                    $this->o('Saya makan nasi', ''),
                    $this->o('Saya minum air', ''),
                    $this->o('Saya minum kopi', ''),
                    $this->o('Saya makan roti', ''),
                ],
                'I drink water.',
                null,
                'Saya minum air.'
            ),

            $this->q(
                8,
                'matching',
                'Cocokkan kata bahasa Inggris dengan artinya.',
                'coffee=kopi,bread=roti,hello=halo',
                [
                    [
                        'left' => 'coffee',
                        'right' => 'kopi',
                    ],
                    [
                        'left' => 'bread',
                        'right' => 'roti',
                    ],
                    [
                        'left' => 'hello',
                        'right' => 'halo',
                    ],
                ]
            ),

            $this->q(
                9,
                'fill_blank',
                'Good ___!',
                'morning',
                [
                    $this->o('morning', ''),
                    $this->o('hello', ''),
                    $this->o('sorry', ''),
                    $this->o('goodbye', ''),
                ],
                'Good morning!',
                null,
                'Selamat pagi!'
            ),

            $this->q(
                10,
                'listening',
                'Dengarkan kalimat berikut.',
                'I eat bread.',
                [
                    $this->o('I drink water', ''),
                    $this->o('I eat bread', ''),
                    $this->o('I drink milk', ''),
                    $this->o('I eat rice', ''),
                ],
                'I eat bread.',
                null,
                'Saya makan roti.'
            ),

            $this->q(
                11,
                'translation',
                'Terjemahkan kalimat berikut ke bahasa Inggris.',
                'I am sorry.',
                null,
                'I am sorry.',
                null,
                'Saya minta maaf.'
            ),

            $this->q(
                12,
                'multiple_choice',
                'Apa arti dari "Thank you"?',
                'Terima kasih',
                [
                    $this->o('Halo', ''),
                    $this->o('Maaf', ''),
                    $this->o('Selamat tinggal', ''),
                    $this->o('Terima kasih', ''),
                ],
                'Thank you',
                null,
                'Terima kasih'
            ),
        ];
    }
}