<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ComparisonItem extends Model
{
    protected $fillable = [
        'comparison_id',
        'product_id',
        'store_id',
        'quantity',
        'unit_price',
        'line_total',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'unit_price' => 'float',
        'line_total' => 'float',
    ];

    public function comparison(): BelongsTo
    {
        return $this->belongsTo(Comparison::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }
}
