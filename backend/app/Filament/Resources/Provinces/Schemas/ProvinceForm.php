<?php

namespace App\Filament\Resources\Provinces\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;

class ProvinceForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')->required()->unique(ignoreRecord: true),
                TextInput::make('code')->required()->unique(ignoreRecord: true),
                Toggle::make('active')->default(true),
            ]);
    }
}
