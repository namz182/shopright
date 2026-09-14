<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::dropIfExists('product_suggestions');
    }

    public function down(): void
    {
        // The suggestion workflow was intentionally removed from the product model.
    }
};
