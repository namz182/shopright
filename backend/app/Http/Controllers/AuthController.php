<?php

namespace App\Http\Controllers;

use App\Models\Store;
use App\Models\District;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AuthController extends Controller
{
    public function showLogin(): View
    {
        return view('auth.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate(['email' => ['required', 'email'], 'password' => ['required']]);

        if (! Auth::attempt([...$credentials, 'active' => true], $request->boolean('remember'))) {
            return back()->withErrors(['email' => 'Those credentials do not match our records.'])->onlyInput('email');
        }

        $request->session()->regenerate();

        if (! Auth::user()->isAdmin() && ! Auth::user()->isShopOwner()) {
            Auth::logout();

            return redirect()->route('login')->withErrors([
                'email' => 'This account does not have dashboard access.',
            ]);
        }

        return redirect()->route('dashboard');
    }

    public function showRegister(): View
    {
        return view('auth.register', [
            'provinces' => \App\Models\Province::active()->with(['districts' => fn ($query) => $query->where('active', true)->orderBy('name')])->orderBy('name')->get(),
        ]);
    }

    public function register(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'confirmed', 'min:8'],
            'shop_name' => ['required', 'string', 'max:255', 'unique:stores,name'],
            'province_id' => ['required', 'exists:provinces,id'],
            'district_id' => ['required', 'exists:districts,id'],
        ]);
        abort_unless(
            District::whereKey($data['district_id'])->where('province_id', $data['province_id'])->exists(),
            422,
            'The selected district does not belong to that province.',
        );

        $user = DB::transaction(function () use ($data): User {
            $store = Store::create([
                'name' => $data['shop_name'],
                'slug' => Str::slug($data['shop_name']),
                'province_id' => $data['province_id'],
                'district_id' => $data['district_id'],
                'active' => true,
            ]);

            return User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => $data['password'],
                'role' => 'shop_owner',
                'store_id' => $store->id,
            ]);
        });
        Auth::login($user);
        $request->session()->regenerate();

        return redirect('/shop');
    }

    public function dashboard(Request $request): RedirectResponse
    {
        if ($request->user()->isAdmin()) {
            return redirect('/admin');
        }

        if ($request->user()->isShopOwner()) {
            return redirect('/shop');
        }

        abort(403, 'This account does not have dashboard access.');
    }

    public function logout(Request $request): RedirectResponse
    {
        if ($adminId = $request->session()->pull('impersonating_admin_id')) {
            Auth::loginUsingId($adminId);
            $admin = User::find($adminId);
            if ($admin) {
                $request->session()->put('password_hash_web', $admin->getAuthPassword());
            }
            return redirect('/admin');
        }

        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/');
    }
}
