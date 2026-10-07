<?php

namespace Database\Seeders;

class JapaneseQuestionSeeder extends LanguageQuestionSeeder
{
    protected function languageCode(): string
    {
        return 'ja';
    }

    protected function lessons(): array
    {
        return [
            1 => $this->lessonOne(),
            2 => $this->lessonTwo(),
        ];
    }

    // ---------------- Pelajaran 1: makanan ----------------
    private function lessonOne(): array
    {
        return [
            $this->q(1, 'image_choice', 'ごはん', 'nasi', [
                $this->pic('nasi', 'rice'),
                $this->pic('air', 'water'),
                $this->pic('roti', 'bread'),
                $this->pic('ikan', 'fish'),
            ], audio: 'ごはん', romaji: 'gohan', meaning: 'nasi'),

            $this->q(2, 'multiple_choice', 'nasi', 'ごはん', [
                $this->o('パン', 'pan'),
                $this->o('ごはん', 'gohan'),
                $this->o('さかな', 'sakana'),
                $this->o('にく', 'niku'),
            ]),

            $this->q(3, 'image_choice', 'とりにく', 'ayam', [
                $this->pic('ayam', 'chicken'),
                $this->pic('ikan', 'fish'),
                $this->pic('telur', 'egg'),
                $this->pic('nasi', 'rice'),
            ], audio: 'とりにく', romaji: 'toriniku', meaning: 'ayam'),

            $this->q(4, 'listening', 'ごはんを たべます', 'ごはん を たべます', [
                $this->o('パン', 'pan'),
                $this->o('たべます', 'tabemasu'),
                $this->o('ごはん', 'gohan'),
                $this->o('のみます', 'nomimasu'),
                $this->o('を', 'o'),
            ], audio: 'ごはんをたべます', meaning: 'Saya makan nasi.'),

            $this->q(5, 'word_bank', 'Saya makan roti.', 'パン を たべます', [
                $this->o('たべます', 'tabemasu'),
                $this->o('ごはん', 'gohan'),
                $this->o('パン', 'pan'),
                $this->o('を', 'o'),
                $this->o('のみます', 'nomimasu'),
            ]),

            $this->q(6, 'multiple_choice', 'さかな', 'ikan', [
                'nasi',
                'ikan',
                'sup',
                'roti',
            ], audio: 'さかな', romaji: 'sakana', meaning: 'ikan'),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Jepang.',
                'nasi=ごはん,ayam=とりにく,ikan=さかな',
                [
                    ['left' => 'nasi', 'right' => 'ごはん (gohan)'],
                    ['left' => 'ayam', 'right' => 'とりにく (toriniku)'],
                    ['left' => 'ikan', 'right' => 'さかな (sakana)'],
                ]
            ),

            $this->q(8, 'word_bank', 'Saya makan telur.', 'たまご を たべます', [
                $this->o('を', 'o'),
                $this->o('たまご', 'tamago'),
                $this->o('のみます', 'nomimasu'),
                $this->o('たべます', 'tabemasu'),
                $this->o('ごはん', 'gohan'),
                $this->o('パン', 'pan'),
            ]),

            $this->q(9, 'image_choice', 'たまご', 'telur', [
                $this->pic('pisang', 'banana'),
                $this->pic('telur', 'egg'),
                $this->pic('nasi', 'rice'),
                $this->pic('roti', 'bread'),
            ], audio: 'たまご', romaji: 'tamago', meaning: 'telur'),

            $this->q(10, 'listening', 'パンを たべます', 'パン を たべます', [
                $this->o('たべます', 'tabemasu'),
                $this->o('を', 'o'),
                $this->o('わたし', 'watashi'),
                $this->o('パン', 'pan'),
                $this->o('ごはん', 'gohan'),
                $this->o('のみます', 'nomimasu'),
            ], audio: 'パンをたべます', meaning: 'Saya makan roti.'),

            $this->q(11, 'fill_blank', 'ごはんを ___。', 'たべます', [
                $this->o('のみます', 'nomimasu'),
                $this->o('たべます', 'tabemasu'),
                $this->o('パン', 'pan'),
                $this->o('ごはん', 'gohan'),
            ], romaji: 'gohan o ___.', meaning: 'makan'),

            $this->q(12, 'multiple_choice', 'バナナ', 'pisang', [
                'apel',
                'pisang',
                'nasi',
                'sup',
            ], audio: 'バナナ', romaji: 'banana', meaning: 'pisang'),
        ];
    }

    // ---------------- Pelajaran 2: minuman ----------------
    private function lessonTwo(): array
    {
        return [
            $this->q(1, 'image_choice', 'みず', 'air', [
                $this->pic('air', 'water'),
                $this->pic('susu', 'milk'),
                $this->pic('kopi', 'coffee'),
                $this->pic('teh', 'tea'),
            ], audio: 'みず', romaji: 'mizu', meaning: 'air'),

            $this->q(2, 'multiple_choice', 'kopi', 'コーヒー', [
                $this->o('おちゃ', 'ocha'),
                $this->o('コーヒー', 'koohii'),
                $this->o('みず', 'mizu'),
                $this->o('ぎゅうにゅう', 'gyuunyuu'),
            ]),

            $this->q(3, 'image_choice', 'おちゃ', 'teh', [
                $this->pic('kopi', 'coffee'),
                $this->pic('jus', 'juice'),
                $this->pic('teh', 'tea'),
                $this->pic('air', 'water'),
            ], audio: 'おちゃ', romaji: 'ocha', meaning: 'teh'),

            $this->q(4, 'listening', 'みずを のみます', 'みず を のみます', [
                $this->o('のみます', 'nomimasu'),
                $this->o('たべます', 'tabemasu'),
                $this->o('みず', 'mizu'),
                $this->o('ぎゅうにゅう', 'gyuunyuu'),
                $this->o('を', 'o'),
            ], audio: 'みずをのみます', meaning: 'Saya minum air.'),

            $this->q(5, 'word_bank', 'Saya minum kopi.', 'コーヒー を のみます', [
                $this->o('のみます', 'nomimasu'),
                $this->o('コーヒー', 'koohii'),
                $this->o('を', 'o'),
                $this->o('みず', 'mizu'),
                $this->o('たべます', 'tabemasu'),
                $this->o('おちゃ', 'ocha'),
            ]),

            $this->q(6, 'multiple_choice', 'ぎゅうにゅう', 'susu', [
                'jus',
                'susu',
                'kopi',
                'air',
            ], audio: 'ぎゅうにゅう', romaji: 'gyuunyuu', meaning: 'susu'),

            $this->q(
                7,
                'matching',
                'Cocokkan kata bahasa Indonesia dengan bahasa Jepang.',
                'air=みず,kopi=コーヒー,teh=おちゃ',
                [
                    ['left' => 'air', 'right' => 'みず (mizu)'],
                    ['left' => 'kopi', 'right' => 'コーヒー (koohii)'],
                    ['left' => 'teh', 'right' => 'おちゃ (ocha)'],
                ]
            ),

            $this->q(8, 'word_bank', 'Saya minum jus.', 'ジュース を のみます', [
                $this->o('ジュース', 'juusu'),
                $this->o('のみます', 'nomimasu'),
                $this->o('を', 'o'),
                $this->o('みず', 'mizu'),
                $this->o('たべます', 'tabemasu'),
                $this->o('ぎゅうにゅう', 'gyuunyuu'),
            ]),

            $this->q(9, 'image_choice', 'ジュース', 'jus', [
                $this->pic('susu', 'milk'),
                $this->pic('teh', 'tea'),
                $this->pic('jus', 'juice'),
                $this->pic('kopi', 'coffee'),
            ], audio: 'ジュース', romaji: 'juusu', meaning: 'jus'),

            $this->q(10, 'listening', 'ぎゅうにゅうを のみます', 'ぎゅうにゅう を のみます', [
                $this->o('のみます', 'nomimasu'),
                $this->o('ぎゅうにゅう', 'gyuunyuu'),
                $this->o('を', 'o'),
                $this->o('みず', 'mizu'),
                $this->o('コーヒー', 'koohii'),
                $this->o('たべます', 'tabemasu'),
            ], audio: 'ぎゅうにゅうをのみます', meaning: 'Saya minum susu.'),

            $this->q(11, 'fill_blank', 'おちゃを ___。', 'のみます', [
                $this->o('のみます', 'nomimasu'),
                $this->o('たべます', 'tabemasu'),
                $this->o('みず', 'mizu'),
                $this->o('おちゃ', 'ocha'),
            ], romaji: 'ocha o ___.', meaning: 'minum'),

            $this->q(12, 'multiple_choice', 'ください', 'tolong', [
                'terima kasih',
                'tolong',
                'maaf',
                'selamat pagi',
            ], audio: 'ください', romaji: 'kudasai', meaning: 'tolong'),
        ];
    }
}