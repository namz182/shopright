<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Comparison extends Model
{
    protected $fillable = [
        'reference',
        'currency',
        'budget',
        'total_lowest',
        'total_cheapest_store',
        'total_savings',
        'items_count',
    ];

    protected $casts = [
        'budget' => 'float',
        'total_lowest' => 'float',
        'total_cheapest_store' => 'float',
        'total_savings' => 'float',
    ];

    public function items(): HasMany
    {
        return $this->hasMany(ComparisonItem::class);
    }
}
