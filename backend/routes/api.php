<?php

use App\Http\Controllers\CatalogController;
use Illuminate\Support\Facades\Route;

Route::get('/products', [CatalogController::class, 'products']);
Route::get('/products/{product}', [CatalogController::class, 'show']);
Route::get('/stores', [CatalogController::class, 'stores']);
Route::get('/locations/provinces', [CatalogController::class, 'provinces']);
Route::get('/locations/provinces/{province}/districts', [CatalogController::class, 'districts']);
Route::post('/compare', [CatalogController::class, 'compare']);
