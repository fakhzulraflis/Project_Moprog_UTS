<?php

use App\Models\Question;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    private const OLD = 'assets/foods/';

    private const NEW = 'assets/lesson/';

    /**
     * Gambar soal dipindah dari assets/foods/ ke assets/lesson/, tetapi soal
     * yang sudah tersimpan di database masih menunjuk ke folder lama, sehingga
     * kuis menampilkan ikon "gambar rusak". Migrasi ini memperbaiki jalur
     * gambar di soal yang sudah ada. Aman dijalankan berulang.
     */
    public function up(): void
    {
        $this->rewrite(self::OLD, self::NEW);
    }

    public function down(): void
    {
        $this->rewrite(self::NEW, self::OLD);
    }

    private function rewrite(string $from, string $to): void
    {
        Question::query()->where('type', 'image_choice')->each(function (Question $question) use ($from, $to) {
            $options = $question->options;

            if (! is_array($options)) {
                return;
            }

            $changed = false;

            foreach ($options as $i => $option) {
                if (is_array($option) && isset($option['image']) && str_starts_with($option['image'], $from)) {
                    $options[$i]['image'] = $to.substr($option['image'], strlen($from));
                    $changed = true;
                }
            }

            if ($changed) {
                $question->options = $options;
                $question->save();
            }
        });
    }
};
