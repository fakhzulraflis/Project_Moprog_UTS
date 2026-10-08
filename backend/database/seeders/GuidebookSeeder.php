<?php

namespace Database\Seeders;

use App\Models\Language;
use Illuminate\Database\Seeder;

class GuidebookSeeder extends Seeder
{
    public function run(): void
    {
        $guides = [
            'en' => $this->english(),
            'ja' => $this->japanese(),
            'ko' => $this->korean(),
        ];

        foreach ($guides as $code => $blocks) {
            $language = Language::where('code', $code)->firstOrFail();

            $section = $language->sections()->orderBy('id')->first();
            $unit = $section?->units()->orderBy('id')->first();

            if ($unit) {
                $unit->forceFill(['guidebook' => $blocks])->save();
            }
        }
    }

    private function english(): array
    {
        return [
            $this->block('Sapaan', [
                $this->row('hello', null, 'halo'),
                $this->row('good morning', null, 'selamat pagi'),
                $this->row('good evening', null, 'selamat malam'),
                $this->row('thank you', null, 'terima kasih'),
                $this->row('sorry', null, 'maaf'),
                $this->row('goodbye', null, 'selamat tinggal'),
                $this->row('How are you?', null, 'apa kabar?'),
            ]),
            $this->block('Makanan', [
                $this->row('rice', null, 'nasi'),
                $this->row('chicken', null, 'ayam'),
                $this->row('fish', null, 'ikan'),
                $this->row('bread', null, 'roti'),
                $this->row('egg', null, 'telur'),
                $this->row('banana', null, 'pisang'),
            ]),
            $this->block('Minuman', [
                $this->row('water', null, 'air'),
                $this->row('tea', null, 'teh'),
                $this->row('coffee', null, 'kopi'),
                $this->row('milk', null, 'susu'),
                $this->row('juice', null, 'jus'),
            ]),
            $this->block(
                'Pola kalimat',
                [
                    $this->row('I eat rice.', null, 'Saya makan nasi.'),
                    $this->row('I drink water.', null, 'Saya minum air.'),
                ],
                'Untuk mengatakan apa yang kamu makan atau minum, pakai pola I + eat atau drink + benda.'
            ),
            $this->block(
                'A dan an',
                [
                    $this->row('a banana', null, 'sebuah pisang'),
                    $this->row('an egg', null, 'sebuah telur'),
                ],
                'Pakai an sebelum kata yang diawali bunyi vokal, dan a sebelum bunyi lainnya.'
            ),
        ];
    }

    private function japanese(): array
    {
        return [
            $this->block('Sapaan', [
                $this->row('こんにちは', 'konnichiwa', 'halo'),
                $this->row('おはようございます', 'ohayou gozaimasu', 'selamat pagi'),
                $this->row('こんばんは', 'konbanwa', 'selamat malam'),
                $this->row('ありがとうございます', 'arigatou gozaimasu', 'terima kasih'),
                $this->row('すみません', 'sumimasen', 'maaf'),
                $this->row('さようなら', 'sayounara', 'selamat tinggal'),
                $this->row('おげんきですか', 'ogenki desu ka', 'apa kabar?'),
            ]),
            $this->block('Makanan', [
                $this->row('ごはん', 'gohan', 'nasi'),
                $this->row('とりにく', 'toriniku', 'ayam'),
                $this->row('さかな', 'sakana', 'ikan'),
                $this->row('パン', 'pan', 'roti'),
                $this->row('たまご', 'tamago', 'telur'),
                $this->row('バナナ', 'banana', 'pisang'),
            ]),
            $this->block('Minuman', [
                $this->row('みず', 'mizu', 'air'),
                $this->row('おちゃ', 'ocha', 'teh'),
                $this->row('コーヒー', 'koohii', 'kopi'),
                $this->row('ぎゅうにゅう', 'gyuunyuu', 'susu'),
                $this->row('ジュース', 'juusu', 'jus'),
            ]),
            $this->block('Kata kerja', [
                $this->row('たべます', 'tabemasu', 'makan'),
                $this->row('のみます', 'nomimasu', 'minum'),
            ]),
            $this->block(
                'Pola kalimat',
                [
                    $this->row('ごはんを たべます', 'gohan o tabemasu', 'Saya makan nasi.'),
                    $this->row('みずを のみます', 'mizu o nomimasu', 'Saya minum air.'),
                ],
                'Susunan kalimat Jepang: benda + を + kata kerja. Partikel を dibaca o dan menandai benda yang dimakan atau diminum. Kata kerja selalu di akhir kalimat.'
            ),
        ];
    }

    private function korean(): array
    {
        return [
            $this->block('Sapaan', [
                $this->row('안녕하세요', 'annyeonghaseyo', 'halo'),
                $this->row('감사합니다', 'gamsahamnida', 'terima kasih'),
                $this->row('죄송합니다', 'joesonghamnida', 'maaf'),
                $this->row('안녕히 가세요', 'annyeonghi gaseyo', 'selamat tinggal (untuk yang pergi)'),
                $this->row('안녕히 주무세요', 'annyeonghi jumuseyo', 'selamat tidur'),
                $this->row('잘 지내세요', 'jal jinaeseyo', 'apa kabar?'),
            ]),
            $this->block('Makanan', [
                $this->row('밥', 'bap', 'nasi'),
                $this->row('닭고기', 'dakgogi', 'ayam'),
                $this->row('생선', 'saengseon', 'ikan'),
                $this->row('빵', 'ppang', 'roti'),
                $this->row('계란', 'gyeran', 'telur'),
                $this->row('바나나', 'banana', 'pisang'),
            ]),
            $this->block('Minuman', [
                $this->row('물', 'mul', 'air'),
                $this->row('차', 'cha', 'teh'),
                $this->row('커피', 'keopi', 'kopi'),
                $this->row('우유', 'uyu', 'susu'),
                $this->row('주스', 'juseu', 'jus'),
            ]),
            $this->block('Kata kerja', [
                $this->row('먹어요', 'meogeoyo', 'makan'),
                $this->row('마셔요', 'masyeoyo', 'minum'),
            ]),
            $this->block(
                'Pola kalimat',
                [
                    $this->row('밥을 먹어요', 'babeul meogeoyo', 'Saya makan nasi.'),
                    $this->row('커피를 마셔요', 'keopireul masyeoyo', 'Saya minum kopi.'),
                ],
                'Susunan kalimat Korea: benda + 을 atau 를 + kata kerja. Pakai 을 setelah kata yang berakhir konsonan (밥을), dan 를 setelah kata yang berakhir vokal (커피를).'
            ),
        ];
    }

    private function row(string $text, ?string $romaji, string $meaning): array
    {
        return [
            'text' => $text,
            'romanization' => $romaji,
            'meaning' => $meaning,
        ];
    }

    private function block(string $title, array $items, ?string $body = null): array
    {
        return [
            'title' => $title,
            'body' => $body,
            'items' => $items,
        ];
    }
}