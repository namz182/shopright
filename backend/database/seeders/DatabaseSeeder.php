<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Store;
use App\Models\User;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            ProvinceDistrictSeeder::class,
            CatalogSeeder::class,
        ]);

        User::updateOrCreate(
            ['email' => 'admin@gmail.com'],
            ['name' => 'Shop Right Admin', 'password' => 'password', 'role' => 'admin'],
        );

        foreach (Store::query()->orderBy('id')->get() as $store) {
            $email = $store->id === 1
                ? 'owner@gmail.com'
                : 'owner-'.$store->slug.'@gmail.com';

            User::updateOrCreate(
                ['email' => $email],
                [
                    'name' => $store->name.' Owner',
                    'password' => 'password',
                    'role' => 'shop_owner',
                    'store_id' => $store->id,
                    'active' => true,
                ],
            );
        }
    }
}
