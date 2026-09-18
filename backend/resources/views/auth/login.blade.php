@extends('layouts.brand', ['title' => 'Log in | Shop Right', 'showNav' => true])
@section('content')
<main class="form-page"><section class="card form-card">
    <form method="POST" action="{{ route('login.store') }}">@csrf
        <div class="field"><label for="email">Email address</label><input id="email" name="email" type="email" value="{{ old('email') }}" required autofocus>@error('email')<div class="error">{{ $message }}</div>@enderror</div>
        <div class="field"><label for="password">Password</label><div class="password-field"><input id="password" name="password" type="password" required><button class="password-toggle" type="button" data-password-toggle="password" aria-label="Show password">Show</button></div>@error('password')<div class="error">{{ $message }}</div>@enderror</div>
        <label class="muted"><input type="checkbox" name="remember"> Remember me</label>
        <button class="button primary full" type="submit">Log in</button>
    </form><p class="muted" style="text-align:center;margin-bottom:0">New store partner? <a href="{{ route('register') }}" style="color:var(--deep);font-weight:700">Create an account</a></p>
</section></main>
@endsection
