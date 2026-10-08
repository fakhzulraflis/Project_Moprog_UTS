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
                '밥 을 먹어요',
                [
                    $this->o('빵', 'ppang'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('밥', 'bap'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('을', 'eul'),
                ],
                audio: '밥을 먹어요',
                meaning: 'Saya makan nasi.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya makan roti.',
                '빵 을 먹어요',
                [
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('밥', 'bap'),
                    $this->o('빵', 'ppang'),
                    $this->o('을', 'eul'),
                    $this->o('마셔요', 'masyeoyo'),
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
                '계란 을 먹어요',
                [
                    $this->o('을', 'eul'),
                    $this->o('계란', 'gyeran'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('밥', 'bap'),
                    $this->o('빵', 'ppang'),
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
                '빵 을 먹어요',
                [
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('을', 'eul'),
                    $this->o('저', 'jeo'),
                    $this->o('빵', 'ppang'),
                    $this->o('밥', 'bap'),
                    $this->o('마셔요', 'masyeoyo'),
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
                romaji: 'bap-eul ___',
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
                '물 을 마셔요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('물', 'mul'),
                    $this->o('우유', 'uyu'),
                    $this->o('을', 'eul'),
                ],
                audio: '물을 마셔요',
                meaning: 'Saya minum air.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya minum kopi.',
                '커피 를 마셔요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('커피', 'keopi'),
                    $this->o('를', 'reul'),
                    $this->o('물', 'mul'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('차', 'cha'),
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
                '주스 를 마셔요',
                [
                    $this->o('주스', 'juseu'),
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('를', 'reul'),
                    $this->o('물', 'mul'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('우유', 'uyu'),
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
                '우유 를 마셔요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('우유', 'uyu'),
                    $this->o('를', 'reul'),
                    $this->o('물', 'mul'),
                    $this->o('커피', 'keopi'),
                    $this->o('먹어요', 'meogeoyo'),
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
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('물', 'mul'),
                    $this->o('차', 'cha'),
                ],
                romaji: 'cha-reul ___',
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

    // ---------------- Pelajaran 3: Sapaan ----------------
    private function lessonThree(): array
    {
        return [
            $this->q(
                1,
                'image_choice',
                '안녕하세요',
                'halo',
                [
                    $this->pic('halo', 'hello'),
                    $this->pic('selamat tinggal', 'goodbye'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('maaf', 'sorry'),
                ],
                audio: '안녕하세요',
                romaji: 'annyeonghaseyo',
                meaning: 'halo'
            ),

            $this->q(
                2,
                'multiple_choice',
                'halo',
                '안녕하세요',
                [
                    $this->o('안녕히 가세요', 'annyeonghi gaseyo'),
                    $this->o('안녕하세요', 'annyeonghaseyo'),
                    $this->o('감사합니다', 'gamsahamnida'),
                    $this->o('미안합니다', 'mianhamnida'),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                '안녕히 가세요',
                'selamat tinggal',
                [
                    $this->pic('halo', 'hello'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('selamat tinggal', 'goodbye'),
                    $this->pic('maaf', 'sorry'),
                ],
                audio: '안녕히 가세요',
                romaji: 'annyeonghi gaseyo',
                meaning: 'selamat tinggal'
            ),

            $this->q(
                4,
                'listening',
                '안녕하세요',
                '안녕하세요',
                [
                    $this->o('안녕히 가세요', 'annyeonghi gaseyo'),
                    $this->o('안녕하세요', 'annyeonghaseyo'),
                    $this->o('감사합니다', 'gamsahamnida'),
                    $this->o('미안합니다', 'mianhamnida'),
                ],
                audio: '안녕하세요',
                meaning: 'Halo.'
            ),

            $this->q(
                5,
                'word_bank',
                'Terima kasih.',
                '감사합니다',
                [
                    $this->o('감사합니다', 'gamsahamnida'),
                    $this->o('안녕하세요', 'annyeonghaseyo'),
                    $this->o('안녕히 가세요', 'annyeonghi gaseyo'),
                    $this->o('미안합니다', 'mianhamnida'),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                '감사합니다',
                'terima kasih',
                [
                    'maaf',
                    'selamat tinggal',
                    'terima kasih',
                    'halo',
                ],
                audio: '감사합니다',
                romaji: 'gamsahamnida',
                meaning: 'terima kasih'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Korea.',
                'halo=안녕하세요,selamat tinggal=안녕히 가세요,terima kasih=감사합니다',
                [
                    [
                        'left' => 'halo',
                        'right' => '안녕하세요 (annyeonghaseyo)',
                    ],
                    [
                        'left' => 'selamat tinggal',
                        'right' => '안녕히 가세요 (annyeonghi gaseyo)',
                    ],
                    [
                        'left' => 'terima kasih',
                        'right' => '감사합니다 (gamsahamnida)',
                    ],
                ]
            ),

            $this->q(
                8,
                'translation',
                'Terima kasih.',
                '감사합니다'
            ),

            $this->q(
                9,
                'image_choice',
                '감사합니다',
                'terima kasih',
                [
                    $this->pic('maaf', 'sorry'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('halo', 'hello'),
                    $this->pic('selamat tinggal', 'goodbye'),
                ],
                audio: '감사합니다',
                romaji: 'gamsahamnida',
                meaning: 'terima kasih'
            ),

            $this->q(
                10,
                'listening',
                '감사합니다',
                '감사합니다',
                [
                    $this->o('미안합니다', 'mianhamnida'),
                    $this->o('안녕하세요', 'annyeonghaseyo'),
                    $this->o('감사합니다', 'gamsahamnida'),
                    $this->o('안녕히 가세요', 'annyeonghi gaseyo'),
                ],
                audio: '감사합니다',
                meaning: 'Terima kasih.'
            ),

            $this->q(
                11,
                'fill_blank',
                '좋은 ___ 되세요.',
                '하루',
                [
                    $this->o('하루', 'haru'),
                    $this->o('감사합니다', 'gamsahamnida'),
                    $this->o('안녕하세요', 'annyeonghaseyo'),
                    $this->o('미안합니다', 'mianhamnida'),
                ],
                romaji: 'joeun ___ doeseyo.',
                meaning: 'hari yang baik'
            ),

            $this->q(
                12,
                'multiple_choice',
                '미안합니다',
                'maaf',
                [
                    'halo',
                    'terima kasih',
                    'maaf',
                    'selamat tinggal',
                ],
                audio: '미안합니다',
                romaji: 'mianhamnida',
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
                '밥',
                'nasi',
                [
                    $this->pic('nasi', 'rice'),
                    $this->pic('ayam', 'chicken'),
                    $this->pic('ikan', 'fish'),
                    $this->pic('telur', 'egg'),
                ],
                audio: '밥',
                romaji: 'bap',
                meaning: 'nasi'
            ),

            $this->q(
                2,
                'multiple_choice',
                'susu',
                '우유',
                [
                    $this->o('물', 'mul'),
                    $this->o('우유', 'uyu'),
                    $this->o('커피', 'keopi'),
                    $this->o('차', 'cha'),
                ]
            ),

            $this->q(
                3,
                'image_choice',
                '감사합니다',
                'terima kasih',
                [
                    $this->pic('halo', 'hello'),
                    $this->pic('selamat tinggal', 'goodbye'),
                    $this->pic('terima kasih', 'thank_you'),
                    $this->pic('maaf', 'sorry'),
                ],
                audio: '감사합니다',
                romaji: 'gamsahamnida',
                meaning: 'terima kasih'
            ),

            $this->q(
                4,
                'listening',
                '물을 마셔요',
                '물 을 마셔요',
                [
                    $this->o('마셔요', 'masyeoyo'),
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('물', 'mul'),
                    $this->o('우유', 'uyu'),
                    $this->o('을', 'eul'),
                ],
                audio: '물을 마셔요',
                meaning: 'Saya minum air.'
            ),

            $this->q(
                5,
                'word_bank',
                'Saya makan nasi.',
                '밥 을 먹어요',
                [
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('물', 'mul'),
                    $this->o('밥', 'bap'),
                    $this->o('을', 'eul'),
                    $this->o('마셔요', 'masyeoyo'),
                ]
            ),

            $this->q(
                6,
                'multiple_choice',
                '안녕히 가세요',
                'selamat tinggal',
                [
                    'halo',
                    'terima kasih',
                    'selamat tinggal',
                    'maaf',
                ],
                audio: '안녕히 가세요',
                romaji: 'annyeonghi gaseyo',
                meaning: 'selamat tinggal'
            ),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Korea.',
                'nasi=밥,air=물,terima kasih=감사합니다',
                [
                    [
                        'left' => 'nasi',
                        'right' => '밥 (bap)',
                    ],
                    [
                        'left' => 'air',
                        'right' => '물 (mul)',
                    ],
                    [
                        'left' => 'terima kasih',
                        'right' => '감사합니다 (gamsahamnida)',
                    ],
                ]
            ),

            $this->q(
                8,
                'translation',
                'Saya minum kopi.',
                '커피 를 마셔요'
            ),

            $this->q(
                9,
                'image_choice',
                '바나나',
                'pisang',
                [
                    $this->pic('pisang', 'banana'),
                    $this->pic('roti', 'bread'),
                    $this->pic('telur', 'egg'),
                    $this->pic('nasi', 'rice'),
                ],
                audio: '바나나',
                romaji: 'banana',
                meaning: 'pisang'
            ),

            $this->q(
                10,
                'listening',
                '빵을 먹어요',
                '빵 을 먹어요',
                [
                    $this->o('먹어요', 'meogeoyo'),
                    $this->o('을', 'eul'),
                    $this->o('빵', 'ppang'),
                    $this->o('밥', 'bap'),
                    $this->o('마셔요', 'masyeoyo'),
                ],
                audio: '빵을 먹어요',
                meaning: 'Saya makan roti.'
            ),

            $this->q(
                11,
                'fill_blank',
                '좋은 ___ 되세요.',
                '하루',
                [
                    $this->o('하루', 'haru'),
                    $this->o('감사합니다', 'gamsahamnida'),
                    $this->o('안녕하세요', 'annyeonghaseyo'),
                    $this->o('미안합니다', 'mianhamnida'),
                ],
                romaji: 'joeun ___ doeseyo.',
                meaning: 'hari yang baik'
            ),

            $this->q(
                12,
                'multiple_choice',
                '미안합니다',
                'maaf',
                [
                    'halo',
                    'terima kasih',
                    'maaf',
                    'selamat tinggal',
                ],
                audio: '미안합니다',
                romaji: 'mianhamnida',
                meaning: 'maaf'
            ),
        ];
    }
}