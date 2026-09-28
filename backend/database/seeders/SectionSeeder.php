<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Section;

class SectionSeeder extends Seeder
{
    public function run(): void
    {
        Section::updateOrCreate(
            ['id' => 1],
            [
                'title' => 'Section 1',
                'order' => 1,
            ]
        );
    }
}