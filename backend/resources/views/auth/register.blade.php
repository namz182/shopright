@extends('layouts.brand', ['title' => 'Register | Shop Right', 'showNav' => true])
@section('content')
<main class="form-page"><section class="card form-card">
    <a href="{{ url('/') }}" class="logo"><img class="logo-img" src="{{ asset('images/shop-right-icon.png') }}" alt=""><span>shop right</span></a>
    <h1>List your prices.</h1><p class="muted">Join Shop Right as a store partner. Your products stay connected to one shared catalog.</p>
    <form method="POST" action="{{ route('register.store') }}">@csrf
        <div class="field"><label for="shop_name">Shop name</label><input id="shop_name" name="shop_name" value="{{ old('shop_name') }}" placeholder="e.g. Shop Right Ndola" required>@error('shop_name')<div class="error">{{ $message }}</div>@enderror</div>
        <div class="field"><label for="name">Your name</label><input id="name" name="name" value="{{ old('name') }}" required>@error('name')<div class="error">{{ $message }}</div>@enderror</div>
        <div class="field"><label for="email">Email address</label><input id="email" name="email" type="email" value="{{ old('email') }}" required>@error('email')<div class="error">{{ $message }}</div>@enderror</div>
        <div class="field"><label for="province_id">Province</label><select id="province_id" name="province_id" required><option value="">Select a province</option>@foreach($provinces as $province)<option value="{{ $province->id }}" @selected(old('province_id') == $province->id)>{{ $province->name }}</option>@endforeach</select>@error('province_id')<div class="error">{{ $message }}</div>@enderror</div>
        <div class="field"><label for="district_id">District</label><select id="district_id" name="district_id" required disabled><option value="">Select a province first</option></select>@error('district_id')<div class="error">{{ $message }}</div>@enderror</div>
        <div class="field"><label for="password">Password</label><input id="password" name="password" type="password" required>@error('password')<div class="error">{{ $message }}</div>@enderror</div>
        <div class="field"><label for="password_confirmation">Confirm password</label><input id="password_confirmation" name="password_confirmation" type="password" required></div>
        <button class="button primary full" type="submit">Create partner account</button>
    </form><p class="muted" style="text-align:center;margin-bottom:0">Already registered? <a href="{{ route('login') }}" style="color:var(--deep);font-weight:700">Log in</a></p>
</section></main>
<script>
const locations = @json($provinces->mapWithKeys(fn ($province) => [$province->id => $province->districts->map(fn ($district) => ['id' => $district->id, 'name' => $district->name])->values()]));
const province = document.querySelector('#province_id');
const district = document.querySelector('#district_id');
const selectedDistrict = @json(old('district_id'));
function updateDistricts() {
    const options = locations[province.value] || [];
    district.innerHTML = '<option value="">Select a district</option>';
    options.forEach((item) => { const option = new Option(item.name, item.id); option.selected = String(item.id) === String(selectedDistrict); district.add(option); });
    district.disabled = options.length === 0;
}
province.addEventListener('change', updateDistricts);
updateDistricts();
</script>
@endsection
