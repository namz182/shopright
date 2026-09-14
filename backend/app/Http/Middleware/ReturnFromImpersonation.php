<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Symfony\Component\HttpFoundation\Response;

class ReturnFromImpersonation
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->isMethod('post') && $request->is('shop/logout')) {
            if ($adminId = $request->session()->pull('impersonating_admin_id')) {
                Auth::loginUsingId($adminId);
                $admin = User::find($adminId);
                if ($admin) {
                    $request->session()->put('password_hash_web', $admin->getAuthPassword());
                }
                return redirect('/admin');
            }
        }

        return $next($request);
    }
}
