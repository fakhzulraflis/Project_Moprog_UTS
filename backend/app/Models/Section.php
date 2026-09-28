<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Section extends Model
{
    protected $fillable = [
        'title',
        'order',
    ];

    public function units(): HasMany
    {
        return $this->hasMany(Unit::class);
    }
}