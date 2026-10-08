<?php

namespace Tests\Feature;

use App\Models\Lesson;
use App\Models\Question;
use Database\Seeders\CurriculumSeeder;
use Database\Seeders\EnglishQuestionSeeder;
use Database\Seeders\JapaneseQuestionSeeder;
use Database\Seeders\KoreanQuestionSeeder;
use Database\Seeders\LanguageCoursesSeeder;
use Database\Seeders\LanguageSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class QuestionImagesTest extends TestCase
{
    use RefreshDatabase;

    private function seedQuestions(): void
    {
        $this->seed([
            LanguageSeeder::class,
            CurriculumSeeder::class,
            EnglishQuestionSeeder::class,
            LanguageCoursesSeeder::class,
            JapaneseQuestionSeeder::class,
            KoreanQuestionSeeder::class,
        ]);
    }

    // Gambar soal adalah asset aplikasi. Kalau folder asset dipindah tetapi
    // soal masih menunjuk ke jalur lama, kuis menampilkan ikon gambar rusak.
    public function test_every_question_image_exists_in_the_app_assets(): void
    {
        $this->seedQuestions();

        $images = Question::where('type', 'image_choice')->get()
            ->flatMap(fn (Question $q) => collect($q->options)->pluck('image'))
            ->filter()
            ->unique();

        $this->assertNotEmpty($images, 'Harus ada soal bergambar');

        foreach ($images as $image) {
            $this->assertFileExists(base_path('../'.$image), "Gambar soal tidak ditemukan di assets: $image");
        }
    }

    public function test_old_image_paths_are_repaired_by_the_migration(): void
    {
        $this->seed([LanguageSeeder::class, CurriculumSeeder::class]);

        $lesson = Lesson::firstOrFail();

        $question = Question::forceCreate([
            'lesson_id' => $lesson->id,
            'type' => 'image_choice',
            'prompt' => 'Chicken',
            'correct_answer' => 'ayam',
            'options' => [
                ['label' => 'ayam', 'image' => 'assets/foods/chicken.png'],
                ['label' => 'ikan', 'image' => 'assets/lesson/fish.png'],
            ],
            'order' => 1,
        ]);

        $migration = require database_path('migrations/2026_10_11_010000_fix_lesson_image_paths.php');
        $migration->up();
        $migration->up(); // aman dijalankan berulang

        $this->assertSame(
            ['assets/lesson/chicken.png', 'assets/lesson/fish.png'],
            collect($question->fresh()->options)->pluck('image')->all(),
        );
    }
}
