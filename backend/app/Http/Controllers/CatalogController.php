<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Store;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    /**
     * List active products with their category and per-store prices.
     */
    public function products(Request $request): JsonResponse
    {
        $products = Product::query()
            ->with(['category', 'prices' => fn ($q) => $q->where('active', true)->with('store')])
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
        $product->load(['category', 'prices' => fn ($q) => $q->where('active', true)->with('store')]);

        return response()->json(['data' => $this->serializeProduct($product)]);
    }

    /**
     * List active stores ordered by distance.
     */
    public function stores(): JsonResponse
    {
        $stores = Store::query()->active()->orderBy('distance_km')->get();

        return response()->json([
            'data' => $stores->map(fn (Store $store) => [
                'id' => $store->id,
                'name' => $store->name,
                'location' => $store->location,
                'distance_km' => $store->distance_km,
            ]),
        ]);
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
            'prices' => $product->prices->map(fn ($price) => [
                'store_id' => $price->store_id,
                'store' => $price->store?->name,
                'amount' => (float) $price->amount,
                'currency' => $price->currency,
            ])->values(),
        ];
    }
}
