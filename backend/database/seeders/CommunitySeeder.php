<?php

namespace Database\Seeders;

use App\Models\Post;
use App\Models\User;
use Illuminate\Database\Seeder;

// Contoh user & postingan komunitas supaya "Complete your profile" bisa dicoba.
class CommunitySeeder extends Seeder
{
    public function run(): void
    {
        $people = [
            ['Aditya Pratama', 'aditya_q', 'English', 'Hari ini berhasil 7 hari streak! Semangat semua!'],
            ['Bunga Lestari', 'bunga_dev', 'Japanese', 'Akhirnya hafal hiragana. Next: katakana!'],
            ['Citra Dewi', 'citra_kr', 'Korean', 'Tips: dengarkan lagu K-pop sambil baca liriknya.'],
        ];

        foreach ($people as [$name, $username, $language, $body]) {
            $user = User::firstOrCreate(
                ['username' => $username],
                [
                    'name' => $name,
                    'email' => $username.'@example.com',
                    'password' => 'password123',
                    'learning_language' => $language,
                    'native_language' => 'Bahasa Indonesia',
                    'country' => 'Indonesia',
                    'avatar_path' => match ($language) {
                        'Japanese' => 'assets/app/japanese.gif',
                        'Korean' => 'assets/app/korean.gif',
                        default => 'assets/app/english.gif',
                    },
                ],
            );

            Post::firstOrCreate(['user_id' => $user->id, 'body' => $body]);
        }
    }
}
