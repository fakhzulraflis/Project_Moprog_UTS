<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InventoryItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rule;

/**
 * Inventory milik user yang sedang login. Semua query selalu difilter
 * dengan user_id dari token, jadi user tidak bisa melihat atau memakai
 * barang milik user lain.
 */
class InventoryController extends Controller
{
    // GET /api/inventory
    public function index(Request $request): JsonResponse
    {
        return response()->json(['data' => $this->snapshot($request->user()->id)]);
    }

    // POST /api/inventory
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'item_key' => ['required', 'string', Rule::in(array_keys(InventoryItem::CATALOG))],
            'source' => ['nullable', 'string', Rule::in(InventoryItem::SOURCES)],
        ]);

        $item = InventoryItem::create([
            'user_id' => $request->user()->id,
            'item_key' => $validated['item_key'],
            'source' => $validated['source'] ?? null,
            'status' => InventoryItem::STATUS_UNUSED,
        ]);

        return response()->json(['data' => $item->toApi()], 201);
    }

    // POST /api/inventory/{id}/use
    public function use(Request $request, int $id): JsonResponse
    {
        $userId = $request->user()->id;

        $item = InventoryItem::where('user_id', $userId)->find($id);

        if (! $item) {
            return response()->json(['message' => 'Barang tidak ditemukan.'], 404);
        }

        if ($item->status !== InventoryItem::STATUS_UNUSED) {
            return response()->json(['message' => 'Barang ini sudah dipakai.'], 422);
        }

        // Kalau efek yang sama masih aktif, waktunya disambung dari akhir
        // efek tersebut (misalnya XP Ganda 15 menit dipakai 2x = 30 menit).
        $latestEnd = InventoryItem::where('user_id', $userId)
            ->where('status', InventoryItem::STATUS_ACTIVE)
            ->whereIn('item_key', $this->keysWithEffect($item->effect()))
            ->where('expires_at', '>', now())
            ->max('expires_at');

        $start = $latestEnd ? now()->max(Carbon::parse($latestEnd)) : now();

        $item->update([
            'status' => InventoryItem::STATUS_ACTIVE,
            'activated_at' => now(),
            'expires_at' => $start->copy()->addMinutes($item->minutes()),
        ]);

        return response()->json([
            'message' => 'Barang berhasil dipakai.',
            'data' => $this->snapshot($userId),
        ]);
    }

    /**
     * Isi inventory: barang yang belum dipakai dan efek yang sedang aktif.
     */
    private function snapshot(int $userId): array
    {
        $unused = InventoryItem::where('user_id', $userId)
            ->where('status', InventoryItem::STATUS_UNUSED)
            ->orderBy('created_at')
            ->get();

        $active = InventoryItem::where('user_id', $userId)
            ->where('status', InventoryItem::STATUS_ACTIVE)
            ->where('expires_at', '>', now())
            ->orderBy('expires_at')
            ->get();

        return [
            'items' => $unused->map->toApi()->values(),
            'active' => $active->map->toApi()->values(),
            'server_time' => now()->toIso8601String(),
        ];
    }

    private function keysWithEffect(string $effect): array
    {
        return array_keys(array_filter(
            InventoryItem::CATALOG,
            fn ($item) => $item['effect'] === $effect,
        ));
    }
}
