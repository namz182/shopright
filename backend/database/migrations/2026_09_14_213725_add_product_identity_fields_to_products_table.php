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
        Schema::table('products', function (Blueprint $table) {
            $table->string('brand')->nullable()->after('name');
            $table->decimal('quantity', 10, 3)->nullable()->after('brand');
            $table->string('quantity_unit')->nullable()->after('quantity');
            $table->string('barcode')->nullable()->unique()->after('quantity_unit');
            $table->text('description')->nullable()->after('barcode');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropUnique(['barcode']);
            $table->dropColumn(['brand', 'quantity', 'quantity_unit', 'barcode', 'description']);
        });
    }
};
