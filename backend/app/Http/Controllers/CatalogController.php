<?php

namespace App\Http\Controllers;

use App\Models\Product;
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
            'prices' => $product->storeProducts->map(fn ($listing) => [
                'store_id' => $listing->store_id,
                'store' => $listing->store?->name,
                'amount' => (float) $listing->price,
                'currency' => $listing->currency,
            ])->values(),
        ];
    }
}
