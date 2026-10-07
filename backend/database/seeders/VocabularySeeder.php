<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Vocabulary;

class VocabularySeeder extends Seeder
{
    public function run(): void
    {
        $vocabularies = [
            [
                'indonesian' => 'nasi',
                'english' => 'rice',
                'japanese' => 'ご飯',
                'korean' => '밥',
            ],
            [
                'indonesian' => 'ayam',
                'english' => 'chicken',
                'japanese' => '鶏肉',
                'korean' => '닭고기',
            ],
            [
                'indonesian' => 'ikan',
                'english' => 'fish',
                'japanese' => '魚',
                'korean' => '생선',
            ],
            [
                'indonesian' => 'roti',
                'english' => 'bread',
                'japanese' => 'パン',
                'korean' => '빵',
            ],
            [
                'indonesian' => 'telur',
                'english' => 'egg',
                'japanese' => '卵',
                'korean' => '달걀',
            ],
            [
                'indonesian' => 'apel',
                'english' => 'apple',
                'japanese' => 'りんご',
                'korean' => '사과',
            ],
            [
                'indonesian' => 'pisang',
                'english' => 'banana',
                'japanese' => 'バナナ',
                'korean' => '바나나',
            ],
            [
                'indonesian' => 'sup',
                'english' => 'soup',
                'japanese' => 'スープ',
                'korean' => '수프',
            ],
            [
                'indonesian' => 'sayur',
                'english' => 'vegetable',
                'japanese' => '野菜',
                'korean' => '채소',
            ],
            [
                'indonesian' => 'daging',
                'english' => 'meat',
                'japanese' => '肉',
                'korean' => '고기',
            ],
            [
                'indonesian' => 'air',
                'english' => 'water',
                'japanese' => '水',
                'korean' => '물',
            ],
            [
                'indonesian' => 'kopi',
                'english' => 'coffee',
                'japanese' => 'コーヒー',
                'korean' => '커피',
            ],
            [
                'indonesian' => 'teh',
                'english' => 'tea',
                'japanese' => 'お茶',
                'korean' => '차',
            ],
            [
                'indonesian' => 'susu',
                'english' => 'milk',
                'japanese' => '牛乳',
                'korean' => '우유',
            ],
            [
                'indonesian' => 'jus',
                'english' => 'juice',
                'japanese' => 'ジュース',
                'korean' => '주스',
            ],
        ];

        foreach ($vocabularies as $vocabulary) {
            Vocabulary::updateOrCreate(
                [
                    'indonesian' => $vocabulary['indonesian'],
                ],
                $vocabulary
            );
        }
    }
}


