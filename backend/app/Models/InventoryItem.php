<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InventoryItem extends Model
{
    public const STATUS_UNUSED = 'unused';

    public const STATUS_ACTIVE = 'active';

    /**
     * Daftar barang yang boleh masuk inventory.
     * effect  = efek yang aktif waktu barang dipakai
     * minutes = lama efeknya
     */
    public const CATALOG = [
        'xp_boost_15' => ['effect' => 'xp_boost', 'minutes' => 15],
        'xp_boost_30' => ['effect' => 'xp_boost', 'minutes' => 30],
        'xp_boost_60' => ['effect' => 'xp_boost', 'minutes' => 60],
        'unlimited_hearts_30' => ['effect' => 'unlimited_hearts', 'minutes' => 30],
        'unlimited_hearts_60' => ['effect' => 'unlimited_hearts', 'minutes' => 60],
    ];

    public const SOURCES = ['shop', 'chest', 'spin', 'quest'];

    protected $fillable = [
        'user_id',
        'item_key',
        'source',
        'status',
        'activated_at',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'activated_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function effect(): string
    {
        return self::CATALOG[$this->item_key]['effect'];
    }

    public function minutes(): int
    {
        return self::CATALOG[$this->item_key]['minutes'];
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'item_key' => $this->item_key,
            'effect' => $this->effect(),
            'minutes' => $this->minutes(),
            'source' => $this->source,
            'status' => $this->status,
            'activated_at' => $this->activated_at?->toIso8601String(),
            'expires_at' => $this->expires_at?->toIso8601String(),
        ];
    }
}
