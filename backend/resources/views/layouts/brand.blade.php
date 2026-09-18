<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title ?? 'Shop Right' }}</title>
    <style>
        :root{--brand:#84B179;--deep:#527B4A;--ink:#030712;--surface:#F9FAFB;--border:#E5E7EB}
        *{box-sizing:border-box}body{margin:0;background:#fff;color:var(--ink);font-family:Inter,ui-sans-serif,system-ui,-apple-system,sans-serif}a{text-decoration:none;color:inherit}.wrap{width:min(1120px,calc(100% - 40px));margin:auto}.nav{height:78px;display:flex;align-items:center;justify-content:space-between}.logo{display:flex;align-items:center;gap:10px;font-weight:800;letter-spacing:-.04em}.mark{width:36px;height:36px;border-radius:12px;background:var(--ink);color:var(--brand);display:grid;place-items:center;font-size:13px;font-weight:900}.logo-img{width:36px;height:36px}.actions{display:flex;align-items:center;gap:12px}.button{display:inline-flex;align-items:center;justify-content:center;border-radius:999px;padding:12px 20px;font-weight:700;font-size:14px;border:1px solid var(--border)}.primary{background:var(--brand);border-color:var(--brand);color:#fff}.ghost{background:#fff}.card{background:#fff;border:1px solid var(--border);border-radius:24px}.form-page{min-height:100vh;background:var(--surface);display:grid;place-items:center;padding:30px}.form-card{width:min(460px,100%);padding:36px}.form-card h1{margin:22px 0 8px;font-size:30px;letter-spacing:-.05em}.muted{color:#6B7280;line-height:1.6}.field{margin:18px 0}.field label{display:block;font-size:13px;font-weight:700;margin-bottom:8px}.field input,.field select{width:100%;padding:14px 15px;border:1px solid var(--border);border-radius:14px;font:inherit;background:#fff}.password-field{position:relative}.password-field input{padding-right:66px}.password-toggle{position:absolute;right:10px;bottom:8px;border:0;background:transparent;color:var(--deep);font:inherit;font-size:12px;font-weight:800;padding:7px 8px;cursor:pointer}.password-toggle:focus-visible{outline:2px solid var(--brand);outline-offset:2px;border-radius:7px}.error{color:#9F1239;font-size:13px;margin-top:7px}.full{width:100%;margin-top:8px}
    </style>
    <style>
        .form-page{min-height:calc(100vh - 78px);padding:24px 20px}.form-card{margin:auto}
        @media(max-width:600px){.nav{height:70px;width:calc(100% - 28px)}.nav .actions{gap:6px}.nav .button{padding:10px 13px;font-size:12px}.form-page{min-height:calc(100vh - 70px);padding:12px 14px 24px;align-items:start}.form-card{padding:25px 18px;border-radius:20px}.field{margin:15px 0}.form-card .full{margin-top:7px}}
    </style>
</head><body>
@if($showNav ?? false)
<header class="wrap nav"><a href="{{ url('/') }}" class="logo"><img class="logo-img" src="{{ asset('images/shop-right-icon.png') }}" alt=""><span>shop right</span></a><nav class="actions"><a class="button ghost" href="{{ route('login') }}">Log in</a><a class="button primary" href="{{ route('register') }}">Sign up</a></nav></header>
@endif
@yield('content')
<script>
document.querySelectorAll('[data-password-toggle]').forEach((toggle) => {
    toggle.addEventListener('click', () => {
        const input = document.getElementById(toggle.dataset.passwordToggle);
        if (!input) return;
        const visible = input.type === 'text';
        input.type = visible ? 'password' : 'text';
        toggle.textContent = visible ? 'Show' : 'Hide';
        toggle.setAttribute('aria-label', visible ? 'Show password' : 'Hide password');
    });
});
</script>
</body></html>
