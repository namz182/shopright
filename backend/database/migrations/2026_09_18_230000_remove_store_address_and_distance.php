<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        $columns = array_values(array_filter(['address', 'distance_km'], fn (string $column) => Schema::hasColumn('stores', $column)));
        if ($columns !== []) {
            Schema::table('stores', function (Blueprint $table) use ($columns) {
                $table->dropColumn($columns);
            });
        }
    }

    public function down(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $table->string('address')->nullable();
            $table->decimal('distance_km', 5, 2)->nullable();
        });
    }
};
