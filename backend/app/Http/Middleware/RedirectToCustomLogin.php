<?php

namespace App\Http\Middleware;

use Illuminate\Http\Request;

class RedirectToCustomLogin extends \Filament\Http\Middleware\Authenticate
{
    protected function redirectTo($request): ?string
    {
        return route('login');
    }
}
