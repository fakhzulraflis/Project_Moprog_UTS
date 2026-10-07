<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;


class Language extends Model
{
    protected $fillable = [
        'code',
        'name',
        'native_name',
        'tts_code',
        'flag',
        'uses_romanization',
        'is_active',
        'order',
    ];

    protected $casts = [
        'uses_romanization' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function sections(): HasMany
    {
        return $this->hasMany(Section::class);
    }

    // Section.php
    public function language(): BelongsTo { return $this->belongsTo(Language::class); }
    public function units(): HasMany { return $this->hasMany(Unit::class); }

    // Unit.php
    public function section(): BelongsTo { return $this->belongsTo(Section::class); }
    public function lessons(): HasMany { return $this->hasMany(Lesson::class); }

    // Lesson.php
    public function unit(): BelongsTo { return $this->belongsTo(Unit::class); }    
}