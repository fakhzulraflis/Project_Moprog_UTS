<?php

namespace Database\Seeders;

use App\Models\Language;
use App\Models\Section;
use Illuminate\Database\Seeder;

class CurriculumSeeder extends Seeder
{
    public function run(): void
    {
        $english = Language::where('code', 'en')->firstOrFail();

        foreach ($this->curriculum() as $sectionIndex => $sectionData) {
            $section = $english->sections()->forceCreate([
                'title' => $sectionData['title'],
                'order' => $sectionIndex + 1,
            ]);

            foreach ($sectionData['units'] as $unitIndex => $unitData) {
                $unit = $section->units()->forceCreate([
                    'title' => $unitData['title'],
                    'order' => $unitIndex + 1,
                ]);

                foreach ($unitData['lessons'] as $lessonIndex => $lessonTitle) {
                    $unit->lessons()->forceCreate([
                        'title' => $lessonTitle,
                        'order' => $lessonIndex + 1,
                    ]);
                }
            }
        }
    }

    private function curriculum(): array
    {
        return [
            [
                'title' => 'Pemula',
                'units' => [
                    [
                        'title' => 'Dasar-dasar',
                        'lessons' => [
                            'Makanan Dasar',
                            'Minuman Dasar',
                            'Sapaan',
                            'Tantangan Dasar',
                        ],
                    ],
                    [
                        'title' => 'Perkenalan',
                        'lessons' => [
                            'Nama Saya',
                            'Asal Negara',
                            'Keluarga',
                            'Pekerjaan',
                            'Tantangan Perkenalan',
                        ],
                    ],
                    [
                        'title' => 'Memesan di Kafe',
                        'lessons' => [
                            'Membaca Menu',
                            'Memesan Minuman',
                            'Memesan Makanan',
                            'Membayar',
                            'Tantangan Kafe',
                        ],
                    ],
                ],
            ],

            [
                'title' => 'Sehari-hari',
                'units' => [
                    [
                        'title' => 'Angka dan Waktu',
                        'lessons' => [
                            'Angka 1-10',
                            'Angka 11-100',
                            'Hari dalam Seminggu',
                            'Bulan',
                            'Jam',
                            'Tantangan Waktu',
                        ],
                    ],
                    [
                        'title' => 'Berbelanja',
                        'lessons' => [
                            'Warna',
                            'Pakaian',
                            'Harga',
                            'Tantangan Belanja',
                        ],
                    ],
                    [
                        'title' => 'Di Rumah',
                        'lessons' => [
                            'Ruangan',
                            'Perabot',
                            'Kegiatan Harian',
                            'Tantangan Rumah',
                        ],
                    ],
                ],
            ],

            [
                'title' => 'Bepergian',
                'units' => [
                    [
                        'title' => 'Menanyakan Arah',
                        'lessons' => [
                            'Kiri dan Kanan',
                            'Tempat Umum',
                            'Bertanya Lokasi',
                            'Tantangan Arah',
                        ],
                    ],
                    [
                        'title' => 'Transportasi',
                        'lessons' => [
                            'Kendaraan',
                            'Membeli Tiket',
                            'Di Stasiun',
                            'Di Bandara',
                            'Tantangan Transportasi',
                        ],
                    ],
                    [
                        'title' => 'Penginapan',
                        'lessons' => [
                            'Memesan Kamar',
                            'Fasilitas',
                            'Tantangan Penginapan',
                        ],
                    ],
                ],
            ],
        ];
    }
}