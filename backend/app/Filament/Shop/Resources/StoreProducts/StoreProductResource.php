<?php

namespace App\Filament\Shop\Resources\StoreProducts;

use App\Filament\Shop\Resources\StoreProducts\Pages\CreateStoreProduct;
use App\Filament\Shop\Resources\StoreProducts\Pages\EditStoreProduct;
use App\Filament\Shop\Resources\StoreProducts\Pages\ListStoreProducts;
use App\Filament\Shop\Resources\StoreProducts\Schemas\StoreProductForm;
use App\Filament\Shop\Resources\StoreProducts\Tables\StoreProductsTable;
use App\Models\StoreProduct;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class StoreProductResource extends Resource
{
    protected static ?string $model = StoreProduct::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static \UnitEnum|string|null $navigationGroup = 'My store';

    public static function getEloquentQuery(): \Illuminate\Database\Eloquent\Builder
    {
        return parent::getEloquentQuery()->where('store_id', auth()->user()->store_id);
    }

    public static function form(Schema $schema): Schema
    {
        return StoreProductForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return StoreProductsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListStoreProducts::route('/'),
            'create' => CreateStoreProduct::route('/create'),
            'edit' => EditStoreProduct::route('/{record}/edit'),
        ];
    }
}
