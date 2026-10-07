<?php

namespace Database\Seeders;

use App\Models\Language;
use App\Models\Section;
use Illuminate\Database\Seeder;

class LanguageSeeder extends Seeder
{
    public function run(): void
    {
        $languages = [
            [
                'code' => 'en',
                'name' => 'English',
                'native_name' => 'English',
                'tts_code' => 'en-US',
                'flag' => 'assets/flags/inggris.png',
                'uses_romanization' => false,
                'order' => 1,
            ],
            [
                'code' => 'ja',
                'name' => 'Japanese',
                'native_name' => '日本語',
                'tts_code' => 'ja-JP',
                'flag' => 'assets/flags/japan.png',
                'uses_romanization' => true,
                'order' => 2,
            ],
            [
                'code' => 'ko',
                'name' => 'Korean',
                'native_name' => '한국어',
                'tts_code' => 'ko-KR',
                'flag' => 'assets/flags/korea.png',
                'uses_romanization' => true,
                'order' => 3,
            ],
        ];

        foreach ($languages as $data) {
            Language::updateOrCreate(['code' => $data['code']], $data);
        }

        $english = Language::where('code', 'en')->first();

        Section::whereNull('language_id')->update(['language_id' => $english->id]);
    }
}