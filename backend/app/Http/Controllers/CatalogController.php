<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Province;
use App\Models\Store;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    /**
     * List active products with their category and current store listings.
     */
    public function products(Request $request): JsonResponse
    {
        $products = Product::query()
            ->with(['category', 'storeProducts' => fn ($q) => $q->where('available', true)->whereNotNull('price')->with('store')])
            ->active()
            ->search($request->query('search'))
            ->orderBy('name')
            ->get();

        return response()->json([
            'data' => $products->map(fn (Product $product) => $this->serializeProduct($product)),
        ]);
    }

    /**
     * Show a single active product with its prices.
     */
    public function show(Request $request, Product $product): JsonResponse
    {
        $product->load(['category', 'storeProducts' => fn ($q) => $q->where('available', true)->whereNotNull('price')->with('store')]);

        return response()->json(['data' => $this->serializeProduct($product)]);
    }

    /**
     * List active stores ordered by name.
     */
    public function stores(Request $request): JsonResponse
    {
        $stores = Store::query()->active()->when($this->storeFilter($request), fn ($q, $filter) => $q->where($filter))->orderBy('name')->get();

        return response()->json([
            'data' => $stores->map(fn (Store $store) => [
                'id' => $store->id,
                'name' => $store->name,
                'location' => $store->location,
                'province_id' => $store->province_id,
                'district_id' => $store->district_id,
            ]),
        ]);
    }

    public function provinces(): JsonResponse
    {
        return response()->json(['data' => Province::active()->withCount('districts')->orderBy('name')->get(['id', 'name', 'code'])]);
    }

    public function districts(Province $province): JsonResponse
    {
        return response()->json(['data' => $province->districts()->where('active', true)->orderBy('name')->get(['id', 'province_id', 'name'])]);
    }

    public function compare(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'budget' => ['nullable', 'numeric', 'min:0'],
            'province_id' => ['nullable', 'integer', 'exists:provinces,id'],
            'district_id' => ['nullable', 'integer', 'exists:districts,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
        ]);

        $stores = Store::active()->when($this->storeFilter($request), fn ($q, $filter) => $q->where($filter))->get();
        $products = Product::active()->whereIn('id', collect($payload['items'])->pluck('product_id'))
            ->with(['category', 'storeProducts' => fn ($q) => $q->where('available', true)->whereNotNull('price')->whereIn('store_id', $stores->pluck('id'))->with('store')])->get()->keyBy('id');

        $items = [];
        $storeTotals = $stores->map(fn ($store) => ['store_id' => $store->id, 'store' => $store->name, 'total' => 0.0, 'covered_items' => 0])->values();
        foreach ($payload['items'] as $requested) {
            $product = $products->get($requested['product_id']);
            if (!$product || $product->storeProducts->isEmpty()) continue;
            $prices = $product->storeProducts->sortBy('price')->values();
            $lowest = $prices->first();
            $quantity = $requested['quantity'];
            $items[] = ['product_id' => $product->id, 'product_name' => $product->name, 'product_unit' => $product->unit, 'quantity' => $quantity, 'store_id' => $lowest->store_id, 'store' => $lowest->store?->name, 'unit_price' => (float) $lowest->price, 'line_total' => (float) $lowest->price * $quantity, 'prices' => $prices->map(fn ($price) => ['store_id' => $price->store_id, 'store' => $price->store?->name, 'amount' => (float) $price->price, 'currency' => $price->currency])->values()];
            foreach ($prices as $price) {
                $storeTotals = $storeTotals->map(function ($total) use ($price, $quantity) { if ($total['store_id'] === $price->store_id) { $total['total'] += (float) $price->price * $quantity; $total['covered_items']++; } return $total; });
            }
        }
        $storeTotals = $storeTotals->filter(fn ($total) => $total['covered_items'] > 0)->sortBy('total')->values();
        $lowestTotal = collect($items)->sum('line_total');
        $cheapest = (float) ($storeTotals->first()['total'] ?? 0);

        return response()->json(['data' => ['reference' => 'CMP-'.random_int(100, 999).'-ZM'.random_int(10, 99), 'currency' => 'ZMW', 'budget' => (float) ($payload['budget'] ?? 0), 'total_lowest' => $lowestTotal, 'total_cheapest_store' => $cheapest, 'total_savings' => max(0, $cheapest - $lowestTotal), 'items_count' => count($items), 'items' => $items, 'store_totals' => $storeTotals]]);
    }

    private function storeFilter(Request $request): ?\Closure
    {
        $province = $request->integer('province_id') ?: null;
        $district = $request->integer('district_id') ?: null;
        if (!$province && !$district) return null;
        return function ($query) use ($province, $district) { $query->when($province, fn ($q) => $q->where('province_id', $province))->when($district, fn ($q) => $q->where('district_id', $district)); };
    }

    private function serializeProduct(Product $product): array
    {
        return [
            'id' => $product->id,
            'name' => $product->name,
            'unit' => $product->unit,
            'icon' => $product->icon,
            'category_id' => $product->category_id,
            'category' => $product->category?->name,
            'prices' => $product->storeProducts->map(fn ($listing) => [
                'store_id' => $listing->store_id,
                'store' => $listing->store?->name,
                'amount' => (float) $listing->price,
                'currency' => $listing->currency,
            ])->values(),
        ];
    }
}
