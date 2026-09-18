<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Price;
use App\Models\Product;
use App\Models\Store;
use App\Models\StoreProduct;
use App\Models\Province;
use App\Models\District;
use Illuminate\Database\Seeder;

class CatalogSeeder extends Seeder
{
    public function run(): void
    {
        $categories = $this->categories();
        $products = $this->products($categories);
        $stores = $this->stores();
        $this->prices($products, $stores);
    }

    /**
     * @return array<string, Category>
     */
    private function categories(): array
    {
        $names = [
            'Essential Staples' => 'essential-staples',
            'Cooking Goods' => 'cooking-goods',
            'Pantry Items' => 'pantry-items',
            'Bakery' => 'bakery',
            'Dairy' => 'dairy',
            'Fresh Produce' => 'fresh-produce',
            'Beverages' => 'beverages',
            'Household' => 'household',
        ];

        $categories = [];
        foreach ($names as $name => $slug) {
            $categories[$name] = Category::updateOrCreate(
                ['slug' => $slug],
                ['name' => $name],
            );
        }

        return $categories;
    }

    /**
     * @param  array<string, Category>  $categories
     * @return array<string, Product>
     */
    private function products(array $categories): array
    {
        $rows = [
            ['name' => 'Breakfast Meal 25kg', 'unit' => '25 kg', 'icon' => 'wheat', 'category' => 'Essential Staples'],
            ['name' => 'Roller Meal 10kg', 'unit' => '10 kg', 'icon' => 'wheat', 'category' => 'Essential Staples'],
            ['name' => 'Cooking Oil 2.5L', 'unit' => '2.5 L', 'icon' => 'oil', 'category' => 'Cooking Goods'],
            ['name' => 'Vegetable Oil 1L', 'unit' => '1 L', 'icon' => 'oil', 'category' => 'Cooking Goods'],
            ['name' => 'White Sugar 2kg', 'unit' => '2 kg', 'icon' => 'sugar', 'category' => 'Pantry Items'],
            ['name' => 'Brown Sugar 1kg', 'unit' => '1 kg', 'icon' => 'sugar', 'category' => 'Pantry Items'],
            ['name' => 'Brown Bread', 'unit' => 'loaf', 'icon' => 'bread', 'category' => 'Bakery'],
            ['name' => 'White Bread Loaf', 'unit' => 'loaf', 'icon' => 'bread', 'category' => 'Bakery'],
            ['name' => 'Fresh Milk 1L', 'unit' => '1 L', 'icon' => 'milk', 'category' => 'Dairy'],
            ['name' => 'Powdered Milk 500g', 'unit' => '500 g', 'icon' => 'milk', 'category' => 'Dairy'],
            ['name' => 'Salt 1kg', 'unit' => '1 kg', 'icon' => 'salt', 'category' => 'Cooking Goods'],
            ['name' => 'Chicken Stock Cubes', 'unit' => 'pack', 'icon' => 'cube', 'category' => 'Cooking Goods'],
            ['name' => 'Tomatoes 1kg', 'unit' => '1 kg', 'icon' => 'tomato', 'category' => 'Fresh Produce'],
            ['name' => 'Onions 1kg', 'unit' => '1 kg', 'icon' => 'onion', 'category' => 'Fresh Produce'],
            ['name' => 'Potatoes 5kg', 'unit' => '5 kg', 'icon' => 'potato', 'category' => 'Fresh Produce'],
            ['name' => 'Carrots 1kg', 'unit' => '1 kg', 'icon' => 'carrot', 'category' => 'Fresh Produce'],
            ['name' => 'Rice 5kg', 'unit' => '5 kg', 'icon' => 'rice', 'category' => 'Pantry Items'],
            ['name' => 'Spaghetti Pasta', 'unit' => '500 g', 'icon' => 'pasta', 'category' => 'Pantry Items'],
            ['name' => 'Mango Juice 2L', 'unit' => '2 L', 'icon' => 'juice', 'category' => 'Beverages'],
            ['name' => 'Toilet Paper 12 Pack', 'unit' => '12 pk', 'icon' => 'toilet', 'category' => 'Household'],
        ];

        $products = [];
        foreach ($rows as $row) {
            $products[$row['name']] = Product::updateOrCreate(
                ['name' => $row['name']],
                [
                    'unit' => $row['unit'],
                    'icon' => $row['icon'],
                    'category_id' => $categories[$row['category']]->id,
                ],
            );
        }

        return $products;
    }

    /**
     * @return array<string, Store>
     */
    private function stores(): array
    {
        $rows = [
            ['name' => 'Shoprite Ndola', 'location' => 'Ndola, Copperbelt', 'province' => 'Copperbelt', 'district' => 'Ndola'],
            ['name' => 'Pick n Pay Ndola', 'location' => 'Ndola, Copperbelt', 'province' => 'Copperbelt', 'district' => 'Ndola'],
            ['name' => 'Spar Ndola', 'location' => 'Ndola, Copperbelt', 'province' => 'Copperbelt', 'district' => 'Ndola'],
            ['name' => 'Choppies Ndola', 'location' => 'Ndola, Copperbelt', 'province' => 'Copperbelt', 'district' => 'Ndola'],
            ['name' => 'Kwasinya Supermarket', 'location' => 'Ndola, Copperbelt', 'province' => 'Copperbelt', 'district' => 'Ndola'],
        ];

        $stores = [];
        foreach ($rows as $row) {
            $stores[$row['name']] = Store::updateOrCreate(
                ['slug' => str($row['name'])->slug()],
                [
                    'name' => $row['name'],
                    'province_id' => Province::where('name', $row['province'])->value('id'),
                    'district_id' => District::where('name', $row['district'])->whereHas('province', fn ($query) => $query->where('name', $row['province']))->value('id'),
                    'location' => $row['location'],
                ],
            );
        }

        return $stores;
    }

    /**
     * Price matrix from the mobile results screen (ZMW).
     *
     * @param  array<string, Product>  $products
     * @param  array<string, Store>  $stores
     */
    private function prices(array $products, array $stores): void
    {
        $matrix = [
            'Breakfast Meal 25kg' => ['Shoprite Ndola' => 670.00, 'Pick n Pay Ndola' => 720.00, 'Spar Ndola' => 710.00, 'Choppies Ndola' => 690.00, 'Kwasinya Supermarket' => 620.00],
            'Cooking Oil 2.5L' => ['Shoprite Ndola' => 142.00, 'Pick n Pay Ndola' => 149.00, 'Spar Ndola' => 145.00, 'Choppies Ndola' => 135.00, 'Kwasinya Supermarket' => 125.00],
            'White Sugar 2kg' => ['Shoprite Ndola' => 59.00, 'Pick n Pay Ndola' => 55.00, 'Spar Ndola' => 63.00, 'Choppies Ndola' => 60.00, 'Kwasinya Supermarket' => 50.00],
        ];

        foreach ($matrix as $productName => $storePrices) {
            foreach ($storePrices as $storeName => $amount) {
                Price::updateOrCreate(
                    ['product_id' => $products[$productName]->id, 'store_id' => $stores[$storeName]->id],
                    ['amount' => $amount, 'currency' => 'ZMW', 'recorded_at' => now(), 'active' => true],
                );
                StoreProduct::updateOrCreate(
                    ['product_id' => $products[$productName]->id, 'store_id' => $stores[$storeName]->id],
                    ['price' => $amount, 'currency' => 'ZMW', 'available' => true, 'price_updated_at' => now()],
                );
            }
        }
    }
}
