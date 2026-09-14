<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title ?? 'Shop Right' }}</title>
    <style>
        :root{--brand:#84B179;--deep:#527B4A;--ink:#030712;--surface:#F9FAFB;--border:#E5E7EB}
        *{box-sizing:border-box}body{margin:0;background:#fff;color:var(--ink);font-family:Inter,ui-sans-serif,system-ui,-apple-system,sans-serif}a{text-decoration:none;color:inherit}.wrap{width:min(1120px,calc(100% - 40px));margin:auto}.nav{height:78px;display:flex;align-items:center;justify-content:space-between}.logo{display:flex;align-items:center;gap:10px;font-weight:800;letter-spacing:-.04em}.mark{width:36px;height:36px;border-radius:12px;background:var(--ink);color:var(--brand);display:grid;place-items:center;font-size:13px;font-weight:900}.logo-img{width:36px;height:36px}.actions{display:flex;align-items:center;gap:12px}.button{display:inline-flex;align-items:center;justify-content:center;border-radius:999px;padding:12px 20px;font-weight:700;font-size:14px;border:1px solid var(--border)}.primary{background:var(--brand);border-color:var(--brand);color:#fff}.ghost{background:#fff}.card{background:#fff;border:1px solid var(--border);border-radius:24px;box-shadow:0 20px 60px #0307120d}.form-page{min-height:100vh;background:var(--surface);display:grid;place-items:center;padding:30px}.form-card{width:min(460px,100%);padding:36px}.form-card h1{margin:22px 0 8px;font-size:30px;letter-spacing:-.05em}.muted{color:#6B7280;line-height:1.6}.field{margin:18px 0}.field label{display:block;font-size:13px;font-weight:700;margin-bottom:8px}.field input,.field select{width:100%;padding:14px 15px;border:1px solid var(--border);border-radius:14px;font:inherit;background:#fff}.error{color:#9F1239;font-size:13px;margin-top:7px}.full{width:100%;margin-top:8px}
    </style>
</head><body>
@if($showNav ?? false)
<header class="wrap nav"><a href="{{ url('/') }}" class="logo"><img class="logo-img" src="{{ asset('images/shop-right-mark.svg') }}" alt=""><span>shop right</span></a><nav class="actions"><a class="button ghost" href="{{ route('login') }}">Log in</a><a class="button primary" href="{{ route('register') }}">Sign up</a></nav></header>
@endif
@yield('content')</body></html>
