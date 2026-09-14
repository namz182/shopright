<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StoreProduct extends Model
{
    protected $fillable = [
        'store_id', 'product_id', 'store_display_name', 'store_sku',
        'price', 'currency', 'available', 'price_updated_at',
    ];

    protected $casts = [
        'price' => 'float',
        'available' => 'boolean',
        'price_updated_at' => 'datetime',
    ];

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
