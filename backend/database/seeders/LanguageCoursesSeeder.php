<?php

namespace Database\Seeders;

use App\Models\Language;
use Illuminate\Database\Seeder;

class LanguageCoursesSeeder extends Seeder
{
    public function run(): void
    {
        $english = Language::where('code', 'en')->firstOrFail();

        $sections = $english->sections()
            ->with([
                'units' => fn ($q) => $q->orderBy('id'),
                'units.lessons' => fn ($q) => $q->orderBy('id'),
            ])
            ->orderBy('id')
            ->get();

        foreach (['ja', 'ko'] as $code) {
            $language = Language::where('code', $code)->firstOrFail();

            if ($language->sections()->exists()) {
                continue;
            }

            foreach ($sections as $section) {
                $newSection = $language->sections()->save($section->replicate());

                foreach ($section->units as $unit) {
                    $newUnit = $newSection->units()->save($unit->replicate());

                    foreach ($unit->lessons as $lesson) {
                        $newUnit->lessons()->save($lesson->replicate());
                    }
                }
            }
        }
    }
}