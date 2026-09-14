<?php

namespace App\Filament\Shop\Resources\StoreProducts\Pages;

use App\Filament\Shop\Resources\StoreProducts\StoreProductResource;
use Filament\Resources\Pages\CreateRecord;

class CreateStoreProduct extends CreateRecord
{
    protected static string $resource = StoreProductResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['store_id'] = auth()->user()->store_id;
        $data['price_updated_at'] = now();
        return $data;
    }
}
