<?php

namespace App\Filament\Shop\Resources\StoreProducts\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Actions\Action;
use App\Models\Product;

class StoreProductForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('product_id')
                    ->relationship('product', 'name')
                    ->searchable()
                    ->preload()
                    ->required()
                    ->noSearchResultsMessage('No product found.')
                    ->createOptionAction(fn (Action $action) => $action
                        ->label('Add product')
                        ->icon('heroicon-o-plus')
                        ->modalHeading('Add product to catalog'))
                    ->createOptionForm([
                        TextInput::make('name')->label('Product name')->required()->maxLength(255),
                        Select::make('category_id')->relationship('category', 'name')->searchable()->preload()->required(),
                    ])
                    ->createOptionUsing(fn (array $data): int => Product::create([
                        'name' => $data['name'],
                        'category_id' => $data['category_id'],
                        'active' => true,
                    ])->getKey()),
                TextInput::make('price')->numeric()->minValue(0)->prefix('ZMW')->required(),
                Toggle::make('available')->label('Availability status')->default(true),
            ]);
    }
}
