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
        Schema::create('comparisons', function (Blueprint $table) {
            $table->id();
            $table->string('reference', 16)->unique();
            $table->char('currency', 3)->default('ZMW');
            $table->decimal('budget', 10, 2)->nullable();
            $table->decimal('total_lowest', 10, 2);
            $table->decimal('total_cheapest_store', 10, 2);
            $table->decimal('total_savings', 10, 2)->default(0);
            $table->unsignedInteger('items_count');
            $table->timestamps();

            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comparisons');
    }
};
