<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Unit;

class UnitSeeder extends Seeder
{
    public function run(): void
    {
        Unit::updateOrCreate(
            ['id' => 1],
            [
                'section_id' => 1,
                'title' => 'Dasar-dasar',
                'order' => 1,
            ]
        );
    }
}