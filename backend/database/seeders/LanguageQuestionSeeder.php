<?php

namespace Database\Seeders;

use App\Models\Language;
use App\Models\Question;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;

abstract class LanguageQuestionSeeder extends Seeder
{
    abstract protected function languageCode(): string;

    abstract protected function lessons(): array;

    public function run(): void
    {
        $language = Language::where('code', $this->languageCode())->firstOrFail();

        $lessons = $this->lessonsOf($language);

        foreach ($this->lessons() as $lessonTitle => $questions) {
            $lesson = $lessons->firstWhere('title', $lessonTitle);

            if (! $lesson) {
                $this->command?->warn(
                    "Lesson '{$lessonTitle}' belum ada untuk {$language->name}."
                );
                continue;
            }

            Question::where('lesson_id', $lesson->id)->delete();

            foreach ($questions as $question) {
                Question::create([
                    'lesson_id' => $lesson->id,
                ] + $question);
            }
        }
    }

    protected function lessonsOf(Language $language): Collection
    {
        $sections = $language->sections()
            ->with([
                'units' => fn ($q) => $q->orderBy('id'),
                'units.lessons' => fn ($q) => $q->orderBy('id'),
            ])
            ->orderBy('id')
            ->get();

        return $sections->flatMap->units->flatMap->lessons->values();
    }

    protected function q(
        int $order,
        string $type,
        string $prompt,
        string $answer,
        ?array $options = null,
        ?string $audio = null,
        ?string $romaji = null,
        ?string $meaning = null
    ): array {
        return [
            'order' => $order,
            'type' => $type,
            'prompt' => $prompt,
            'correct_answer' => $answer,
            'options' => $options,
            'audio_text' => $audio,
            'romanization' => $romaji,
            'meaning' => $meaning,
        ];
    }

    protected function o(string $text, string $romaji): array
    {
        return ['text' => $text, 'romanization' => $romaji];
    }

    protected function pic(string $label, string $file): array
    {
        return ['label' => $label, 'image' => "assets/lesson/{$file}.png"];
    }
}