<?php

namespace App\Filament\Resources\Stores\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\ActionGroup;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Actions\Action;
use App\Models\Store;
use Filament\Facades\Filament;

class StoresTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')->searchable()->sortable(),
                TextColumn::make('province.name')->label('Province')->sortable(),
                TextColumn::make('district.name')->label('District')->sortable(),
                TextColumn::make('distance_km')->suffix(' km')->sortable(),
                IconColumn::make('active')->boolean(),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                ActionGroup::make([
                    EditAction::make(),
                    DeleteAction::make(),
                    Action::make('impersonate')
                        ->label('Open dashboard')
                        ->icon('heroicon-o-arrow-top-right-on-square')
                        ->requiresConfirmation()
                        ->action(function (Store $record) {
                            $owner = $record->owners()
                                ->where('role', 'shop_owner')
                                ->where('active', true)
                                ->firstOrFail();

                            session()->put('impersonating_admin_id', Filament::auth()->id());
                            Filament::auth()->login($owner);
                            // AuthenticateSession binds the session to a password hash.
                            // Replace the admin hash when changing users in-place.
                            session()->put('password_hash_web', $owner->getAuthPassword());

                            return redirect('/shop');
                        })
                        ->visible(fn (Store $record) => $record->owners()->where('role', 'shop_owner')->where('active', true)->exists()),
                ]),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
