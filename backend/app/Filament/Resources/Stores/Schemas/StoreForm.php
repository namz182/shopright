<?php

namespace App\Filament\Resources\Stores\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\Select;
use Filament\Schemas\Components\Utilities\Get;
use App\Models\District;

class StoreForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')->required()->maxLength(255),
                TextInput::make('slug')->required()->unique(ignoreRecord: true),
                Select::make('province_id')->relationship('province', 'name')->searchable()->preload()->live()->required(),
                Select::make('district_id')
                    ->label('District')
                    ->options(fn (Get $get) => District::query()->where('province_id', $get('province_id'))->orderBy('name')->pluck('name', 'id'))
                    ->searchable()
                    ->required()
                    ->disabled(fn (Get $get) => blank($get('province_id'))),
                TextInput::make('location'),
                Toggle::make('active')->default(true),
            ]);
    }
}
