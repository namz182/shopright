<?php

namespace App\Filament\Shop\Resources\Users\Pages;

use App\Filament\Shop\Resources\Users\UserResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data['store_id'] = auth()->user()->store_id;
        $data['role'] = 'shop_owner';
        return $data;
    }

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
