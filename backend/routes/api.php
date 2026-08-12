<?php

use App\Http\Controllers\CatalogController;
use Illuminate\Support\Facades\Route;

Route::get('/products', [CatalogController::class, 'products']);
Route::get('/products/{product}', [CatalogController::class, 'show']);
Route::get('/stores', [CatalogController::class, 'stores']);
