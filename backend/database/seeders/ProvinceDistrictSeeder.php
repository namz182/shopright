<?php

namespace Database\Seeders;

use App\Models\District;
use App\Models\Province;
use Illuminate\Database\Seeder;

class ProvinceDistrictSeeder extends Seeder
{
    public function run(): void
    {
        $locations = [
            'Central' => ['Chibombo', 'Chisamba', 'Chitambo', 'Itezhi-Tezhi', 'Kabwe', 'Kapiri Mposhi', 'Luano', 'Mkushi', 'Mumbwa', 'Ngabwe', 'Serenje', 'Shibuyunji'],
            'Copperbelt' => ['Chililabombwe', 'Chingola', 'Kalulushi', 'Kitwe', 'Lufwanyama', 'Luanshya', 'Masaiti', 'Mpongwe', 'Mufulira', 'Ndola'],
            'Eastern' => ['Chadiza', 'Chama', 'Chasefu', 'Chipangali', 'Chipata', 'Katete', 'Lumezi', 'Lundazi', 'Mambwe', 'Nyimba', 'Petauke', 'Sinda', 'Vubwi', 'Kasenengwa', 'Lusangazi'],
            'Luapula' => ['Chembe', 'Chiengi', 'Chifunabuli', 'Chipili', 'Kawambwa', 'Lunga', 'Mansa', 'Milenge', 'Mwansabombwe', 'Mwense', 'Nchelenge', 'Samfya'],
            'Lusaka' => ['Chilanga', 'Chongwe', 'Kafue', 'Luangwa', 'Lusaka', 'Rufunsa'],
            'Muchinga' => ['Chinsali', 'Isoka', 'Kanchibiya', 'Lavushimanda', 'Mafinga', 'Mpika', 'Nakonde', "Shiwang'andu"],
            'Northern' => ['Chilubi', 'Kaputa', 'Kasama', 'Lunte', 'Lupososhi', 'Luwingu', 'Mbala', 'Mporokoso', 'Mpulungu', 'Mungwi', 'Nsama', 'Senga Hill'],
            'North-Western' => ['Chavuma', 'Ikelenge', 'Kabompo', 'Kalumbila', 'Kasempa', 'Manyinga', 'Mufumbwe', 'Mushindamo', 'Mwinilunga', 'Solwezi', 'Zambezi'],
            'Southern' => ['Chikankata', 'Chirundu', 'Choma', 'Gwembe', 'Kalomo', 'Kazungula', 'Livingstone', 'Mazabuka', 'Monze', 'Namwala', 'Pemba', 'Siavonga', 'Sinazongwe', 'Zimba'],
            'Western' => ['Kalabo', 'Kaoma', 'Limulunga', 'Luampa', 'Lukulu', 'Mongu', 'Mulobezi', 'Mwandi', 'Nalolo', 'Nkeyema', 'Senanga', 'Sesheke', 'Shangombo', 'Sikongo', 'Sioma', 'Mitete'],
        ];

        foreach ($locations as $provinceName => $districts) {
            $province = Province::updateOrCreate(
                ['name' => $provinceName],
                ['code' => str($provinceName)->upper()->replace('-', '_')->slug('_'), 'active' => true],
            );

            foreach ($districts as $districtName) {
                District::updateOrCreate(
                    ['province_id' => $province->id, 'name' => $districtName],
                    ['active' => true],
                );
            }
        }
    }
}
