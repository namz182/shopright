<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $table->foreignId('province_id')->nullable()->after('slug')->constrained()->nullOnDelete();
            $table->foreignId('district_id')->nullable()->after('province_id')->constrained()->nullOnDelete();
            $table->index(['province_id', 'district_id']);
        });
    }

    public function down(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $table->dropForeign(['district_id']);
            $table->dropForeign(['province_id']);
            $table->dropIndex(['province_id', 'district_id']);
            $table->dropColumn(['province_id', 'district_id']);
        });
    }
};
