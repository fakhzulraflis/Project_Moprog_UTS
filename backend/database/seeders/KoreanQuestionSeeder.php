<?php

namespace Database\Seeders;

class KoreanQuestionSeeder extends LanguageQuestionSeeder
{
    protected function languageCode(): string
    {
        return 'ko';
    }

    protected function lessons(): array
    {
        return [
            'Makanan Dasar' => $this->lessonOne(),
            'Minuman Dasar' => $this->lessonTwo(),
        ];
    }

    // ---------------- Pelajaran 1: Makanan Dasar ----------------
    private function lessonOne(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                '밥',
                'nasi',
                [
                    $this->pic('nasi', 'rice'),
                    $this->pic('air', 'water'),
                    $this->pic('roti', 'bread'),
                    $this->pic('ikan', 'fish'),
                ],
                audio: '밥',
                romaji: 'bap',
                meaning: 'nasi'
            ),

            $this->q(
                2,
                'multiple_choice',
                'nasi',
                '밥',
                [
                    $this->o('빵', 'ppang'),
                    $this->o('밥', 'bap'),
                    $this->o('생선', 'saengseon'),
                    $this->o('고기', 'gogi'),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                '닭고기',
                'ayam',
                [
                    $this->pic('ayam', 'chicken'),
                    $this->pic('ikan', 'fish'),
                    $this->pic('telur', 'egg'),
                    $this->pic('nasi', 'rice'),
                ],
                audio: '닭고기',
                romaji: 'dakgogi',
                meaning: 'ayam'
            ),

            $this->q(
                4,
                'listening',
                '밥을 먹어요',
                '밥을 먹어요',
                [
                    $this->o('빵을', 'ppangeul'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('밥을', 'babeul'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('계란을', 'gyeraneul'),
                ],
                audio: '밥을 먹어요',
                meaning: 'Saya makan nasi.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya makan roti.',
                '빵을 먹어요',
                [
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('밥을', 'babeul'),
                    $this->o('빵을', 'ppangeul'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('물을', 'mureul'),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                '생선',
                'ikan',
                [
                    'nasi',
                    'ikan',
                    'sup',
                    'roti',
                ],
                audio: '생선',
                romaji: 'saengseon',
                meaning: 'ikan'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Korea.',
                'nasi=밥,ayam=닭고기,ikan=생선',
                [
                    [
                        'left' => 'nasi',
                        'right' => '밥 (bap)',
                    ],
                    [
                        'left' => 'ayam',
                        'right' => '닭고기 (dakgogi)',
                    ],
                    [
                        'left' => 'ikan',
                        'right' => '생선 (saengseon)',
                    ],
                ]
            ),

            $this->q(
                8,
                'word_bank',
                'Saya makan telur.',
                '계란을 먹어요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('계란을', 'gyeraneul'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('밥을', 'babeul'),
                    $this->o('빵을', 'ppangeul'),
                    $this->o('물을', 'mureul'),
                ]
            ),

            $this->q(
                9,
                'image_choice',
                '계란',
                'telur',
                [
                    $this->pic('pisang', 'banana'),
                    $this->pic('telur', 'egg'),
                    $this->pic('nasi', 'rice'),
                    $this->pic('roti', 'bread'),
                ],
                audio: '계란',
                romaji: 'gyeran',
                meaning: 'telur'
            ),

            $this->q(
                10,
                'listening',
                '빵을 먹어요',
                '빵을 먹어요',
                [
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('빵을', 'ppangeul'),
                    $this->o('저는', 'jeoneun'),
                    $this->o('밥을', 'babeul'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('계란을', 'gyeraneul'),
                ],
                audio: '빵을 먹어요',
                meaning: 'Saya makan roti.'
            ),

            $this->q(
                11,
                'fill_blank',
                '밥을 ___',
                '먹어요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('빵', 'ppang'),
                    $this->o('밥', 'bap'),
                ],
                romaji: 'babeul ___',
                meaning: 'makan'
            ),

            $this->q(
                12,
                'multiple_choice',
                '바나나',
                'pisang',
                [
                    'apel',
                    'pisang',
                    'nasi',
                    'sup',
                ],
                audio: '바나나',
                romaji: 'banana',
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
                '물',
                'air',
                [
                    $this->pic('air', 'water'),
                    $this->pic('susu', 'milk'),
                    $this->pic('kopi', 'coffee'),
                    $this->pic('teh', 'tea'),
                ],
                audio: '물',
                romaji: 'mul',
                meaning: 'air'
            ),

            $this->q(
                2,
                'multiple_choice',
                'kopi',
                '커피',
                [
                    $this->o('차', 'cha'),
                    $this->o('커피', 'keopi'),
                    $this->o('물', 'mul'),
                    $this->o('우유', 'uyu'),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                '차',
                'teh',
                [
                    $this->pic('kopi', 'coffee'),
                    $this->pic('jus', 'juice'),
                    $this->pic('teh', 'tea'),
                    $this->pic('air', 'water'),
                ],
                audio: '차',
                romaji: 'cha',
                meaning: 'teh'
            ),

            $this->q(
                4,
                'listening',
                '물을 마셔요',
                '물을 마셔요',
                [
                    $this->o('물을', 'mureul'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('우유를', 'uyureul'),
                    $this->o('밥을', 'babeul'),
                ],
                audio: '물을 마셔요',
                meaning: 'Saya minum air.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya minum kopi.',
                '커피를 마셔요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('커피를', 'keopireul'),
                    $this->o('물을', 'mureul'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('차를', 'chareul'),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                '우유',
                'susu',
                [
                    'jus',
                    'susu',
                    'kopi',
                    'air',
                ],
                audio: '우유',
                romaji: 'uyu',
                meaning: 'susu'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Korea.',
                'air=물,kopi=커피,teh=차',
                [
                    [
                        'left' => 'air',
                        'right' => '물 (mul)',
                    ],
                    [
                        'left' => 'kopi',
                        'right' => '커피 (keopi)',
                    ],
                    [
                        'left' => 'teh',
                        'right' => '차 (cha)',
                    ],
                ]
            ),

            $this->q(
                8,
                'word_bank',
                'Saya minum jus.',
                '주스를 마셔요',
                [
                    $this->o('주스를', 'juseureul'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('물을', 'mureul'),
                    $this->o('우유를', 'uyureul'),
                    $this->o('커피를', 'keopireul'),
                ]
            ),

            $this->q(
                9,
                'image_choice',
                '주스',
                'jus',
                [
                    $this->pic('susu', 'milk'),
                    $this->pic('teh', 'tea'),
                    $this->pic('jus', 'juice'),
                    $this->pic('kopi', 'coffee'),
                ],
                audio: '주스',
                romaji: 'juseu',
                meaning: 'jus'
            ),

            $this->q(
                10,
                'listening',
                '우유를 마셔요',
                '우유를 마셔요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('우유를', 'uyureul'),
                    $this->o('물을', 'mureul'),
                    $this->o('커피를', 'keopireul'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('저는', 'jeoneun'),
                ],
                audio: '우유를 마셔요',
                meaning: 'Saya minum susu.'
            ),

            $this->q(
                11,
                'fill_blank',
                '차를 ___',
                '마셔요',
                [
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('물', 'mul'),
                    $this->o('차', 'cha'),
                ],
                romaji: 'chareul ___',
                meaning: 'minum'
            ),

            $this->q(
                12,
                'multiple_choice',
                '주세요',
                'tolong',
                [
                    'terima kasih',
                    'tolong',
                    'maaf',
                    'selamat pagi',
                ],
                audio: '주세요',
                romaji: 'juseyo',
                meaning: 'tolong'
            ),
        ];
    }
}