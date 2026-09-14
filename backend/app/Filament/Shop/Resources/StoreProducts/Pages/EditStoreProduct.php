<?php

namespace App\Filament\Shop\Resources\StoreProducts\Pages;

use App\Filament\Shop\Resources\StoreProducts\StoreProductResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditStoreProduct extends EditRecord
{
    protected static string $resource = StoreProductResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data['store_id'] = auth()->user()->store_id;
        $data['price_updated_at'] = now();
        return $data;
    }

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
