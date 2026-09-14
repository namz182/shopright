<?php

namespace App\Filament\Resources\Districts\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;

class DistrictForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('province_id')->relationship('province', 'name')->searchable()->preload()->required(),
                TextInput::make('name')->required()->maxLength(255),
                Toggle::make('active')->default(true),
            ]);
    }
}
