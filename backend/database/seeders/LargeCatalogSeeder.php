<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\District;
use App\Models\Price;
use App\Models\Product;
use App\Models\Province;
use App\Models\Store;
use App\Models\StoreProduct;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

/**
 * Adds a realistic-sized catalog for local development and demonstrations.
 *
 * The data is deterministic and safe to run repeatedly. Existing prices from
 * CatalogSeeder are preserved while missing product/store listings are added.
 */
class LargeCatalogSeeder extends Seeder
{
    private const CATEGORIES = [
        'Essential Staples',
        'Cooking Goods',
        'Pantry Items',
        'Bakery',
        'Dairy',
        'Fresh Produce',
        'Beverages',
        'Household',
    ];

    private const ICONS = [
        'Essential Staples' => 'wheat',
        'Cooking Goods' => 'oil',
        'Pantry Items' => 'basket',
        'Bakery' => 'bread',
        'Dairy' => 'milk',
        'Fresh Produce' => 'produce',
        'Beverages' => 'drink',
        'Household' => 'home',
    ];

    public function run(): void
    {
        $categories = Category::query()->whereIn('name', self::CATEGORIES)->get()->keyBy('name');
        $this->products($categories);
        $stores = $this->stores();
        $this->assignPrices($stores);
    }

    /**
     * @param  \Illuminate\Support\Collection<string, Category>  $categories
     */
    private function products($categories): void
    {
        $names = [
            'Maize Meal', 'White Rice', 'Brown Rice', 'Cooking Salt',
            'Tomato Sauce', 'Mayonnaise', 'Peanut Butter', 'Baked Beans',
            'Green Beans', 'Red Kidney Beans', 'Lentils', 'Chickpeas',
            'Oats', 'Corn Flakes', 'Tea Bags', 'Instant Coffee',
            'Cocoa Powder', 'Custard Powder', 'Jelly', 'Pancake Mix',
            'Wheat Flour', 'Cake Flour', 'Baking Powder', 'Stock Cubes',
            'Vinegar', 'Soy Sauce', 'Tomato Paste', 'Cereal Bars',
            'Biscuits', 'Crackers',
        ];
        $variants = ['Original', 'Premium', 'Classic', 'Value Pack', 'Family Pack'];
        $brands = ['Everyday', 'SunFresh', 'Mosi', 'Golden', 'Value'];
        $packs = [
            '100 g', '250 g', '400 g', '500 g', '750 g', '1 kg', '1.5 kg',
            '2 kg', '3 kg', '5 kg', '10 kg', '250 ml', '500 ml', '1 L',
        ];
        $familyCount = count($names);
        $variantCount = count($variants);

        // 30 families x 5 variants x 14 pack sizes = 2,100 products.
        for ($index = 0; $index < $familyCount * $variantCount * count($packs); $index++) {
            $categoryName = self::CATEGORIES[$index % count(self::CATEGORIES)];
            $category = $categories->get($categoryName);
            if (!$category) {
                continue;
            }

            $familyIndex = $index % $familyCount;
            $variantIndex = intdiv($index, $familyCount) % $variantCount;
            $pack = $packs[intdiv($index, $familyCount * $variantCount)];
            $brand = $brands[($familyIndex + $variantIndex) % count($brands)];
            $name = "$brand {$names[$familyIndex]} {$variants[$variantIndex]} $pack";

            Product::updateOrCreate(
                ['name' => $name],
                [
                    'category_id' => $category->id,
                    'unit' => $pack,
                    'icon' => self::ICONS[$categoryName],
                    'active' => true,
                ],
            );
        }
    }

    /**
     * Ensure the five comparison stores are all assigned to Ndola district.
     * Existing demo store names are preserved and updated idempotently.
     *
     * @return array<int, Store>
     */
    private function stores(): array
    {
        $province = Province::query()->where('name', 'Copperbelt')->firstOrFail();
        $district = District::query()
            ->where('province_id', $province->id)
            ->where('name', 'Ndola')
            ->firstOrFail();
        $rows = [
            'Shoprite Ndola',
            'Pick n Pay Ndola',
            'Spar Ndola',
            'Choppies Ndola',
            'Kwasinya Supermarket',
        ];
        $stores = [];

        foreach ($rows as $name) {
            $stores[] = Store::updateOrCreate(
                ['slug' => Str::slug($name)],
                [
                    'name' => $name,
                    'province_id' => $province->id,
                    'district_id' => $district->id,
                    'location' => "Ndola, {$province->name}",
                    'active' => true,
                ],
            );
        }

        // Retire legacy demo names if this seeder is run on an older database.
        Store::query()
            ->where('district_id', $district->id)
            ->whereIn('slug', ['local-market-chifubu', 'pick-n-pay-copperbelt', 'melissa-supermarket'])
            ->update(['active' => false]);

        return $stores;
    }

    /**
     * Assign every active product to every requested Ndola store using bulk upserts.
     * Existing prices remain unchanged so the original demo comparison keeps
     * its known values.
     *
     * @param  array<int, Store>  $stores
     */
    private function assignPrices(array $stores): void
    {
        $products = Product::query()->active()->orderBy('id')->get();
        $existingPrices = Price::query()->get(['product_id', 'store_id', 'amount'])->keyBy(
            fn (Price $price): string => $this->key($price->product_id, $price->store_id),
        );
        $existingListings = StoreProduct::query()->get(['product_id', 'store_id', 'price'])->keyBy(
            fn (StoreProduct $listing): string => $this->key($listing->product_id, $listing->store_id),
        );
        $timestamp = now();
        $priceRows = [];
        $listingRows = [];

        foreach ($products as $product) {
            $base = 8 + (($product->id * 17) % 850) / 10;

            foreach ($stores as $store) {
                $key = $this->key($product->id, $store->id);
                $existingPrice = $existingPrices->get($key);
                $existingListing = $existingListings->get($key);
                $amount = $existingPrice?->amount ?? $existingListing?->price;
                $isKwasinya = $store->name === 'Kwasinya Supermarket';
                $hasSpecialDeal = !$isKwasinya && (($product->id * 13 + $store->id) % 9 < 2);
                $amount = $isKwasinya || $hasSpecialDeal
                    ? round(max(2, $base * ($isKwasinya
                        ? $this->priceMultiplier($product->id, $store->name, $store->id)
                        : $this->specialDealMultiplier($product->id, $store->id))), 2)
                    : ($amount !== null
                    ? (float) $amount
                    : round(max(2, $base * $this->priceMultiplier($product->id, $store->name, $store->id)), 2));

                $priceRows[] = [
                    'product_id' => $product->id,
                    'store_id' => $store->id,
                    'amount' => $amount,
                    'currency' => 'ZMW',
                    'recorded_at' => $timestamp,
                    'active' => true,
                    'created_at' => $timestamp,
                    'updated_at' => $timestamp,
                ];
                $listingRows[] = [
                    'store_id' => $store->id,
                    'product_id' => $product->id,
                    'store_display_name' => $store->name,
                    'store_sku' => Str::upper(Str::substr($store->slug, 0, 8)).'-'.$product->id,
                    'price' => $amount,
                    'currency' => 'ZMW',
                    'available' => true,
                    'price_updated_at' => $timestamp,
                    'created_at' => $timestamp,
                    'updated_at' => $timestamp,
                ];

                if (count($priceRows) >= 500) {
                    $this->upsertBatch($priceRows, $listingRows);
                    $priceRows = [];
                    $listingRows = [];
                }
            }
        }

        $this->upsertBatch($priceRows, $listingRows);
    }

    private function upsertBatch(array $priceRows, array $listingRows): void
    {
        if ($priceRows === []) {
            return;
        }

        Price::upsert(
            $priceRows,
            ['product_id', 'store_id'],
            ['amount', 'currency', 'recorded_at', 'active', 'updated_at'],
        );
        StoreProduct::upsert(
            $listingRows,
            ['store_id', 'product_id'],
            ['store_display_name', 'store_sku', 'price', 'currency', 'available', 'price_updated_at', 'updated_at'],
        );
    }

    private function key(int $productId, int $storeId): string
    {
        return "$productId:$storeId";
    }

    private function priceMultiplier(int $productId, string $storeName, int $storeId): float
    {
        if ($storeName === 'Kwasinya Supermarket') {
            return 0.65 + (($productId + $storeId) % 16) / 100;
        }

        return 0.90 + (($productId + ($storeId * 7)) % 21) / 100;
    }

    private function specialDealMultiplier(int $productId, int $storeId): float
    {
        return 0.72 + (($productId + $storeId) % 17) / 100;
    }
}
