<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('store_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->string('store_display_name')->nullable();
            $table->string('store_sku')->nullable();
            $table->decimal('price', 10, 2)->nullable();
            $table->char('currency', 3)->default('ZMW');
            $table->boolean('available')->default(true);
            $table->timestamp('price_updated_at')->nullable();
            $table->timestamps();
            $table->unique(['store_id', 'product_id']);
            $table->index('available');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('store_products');
    }
};
