# PROMPTLAR — "Aqlli Do'stlar" loyihasida Claude'ni boshqarish uchun

> **Qanday ishlatiladi:** kerakli promptni nusxalab, `[...]` joylarini to'ldirib, Claude'ga yuboring.
> Barcha promptlar **"ruxsatsiz bajarma"** tamoyiliga asoslangan — Claude avval reja beradi, siz tasdiqlaysiz.

---

## 🔐 0. BOSHQARUV PROMPTLARI (har doim ishlatiladi)

### 0.1 Sessiya boshida
```
CLAUDE.md va bolalar_oyini_TZ.md ni o'qi. Hech narsa yaratma yoki o'zgartirma.
Faqat menga ayt:
1. Loyiha hozir qaysi bosqichda
2. Keyingi qilinadigan 3 ta vazifa
3. Qaysi biridan boshlashni tavsiya qilasan va nima uchun
Keyin mening ruxsatimni kut.
```

### 0.2 Faqat reja (kod yozmasdan)
```
[vazifa] uchun FAQAT reja tuz. Hech qanday fayl yaratma, o'zgartirma, buyruq ishga tushirma.
Rejada: qaysi fayllar yaratiladi/o'zgaradi, qaysi paketlar kerak, qadamlar ketma-ketligi, xavflar.
Men "ha" demagunimcha kutib tur.
```

### 0.3 Ruxsat berish (aniq chegaralangan)
```
Ha, rejaning faqat [1-2]-qadamlarini bajar. Boshqa hech narsaga tegma.
Tugagach, nima o'zgarganini ko'rsat va to'xta.
```

### 0.4 Rad etish / o'zgartirish
```
Yo'q, bunday qilma. O'rniga [o'zgartirish]. Yangilangan rejani ko'rsat va yana ruxsat so'ra.
```

### 0.5 To'xtatish (favqulodda)
```
TO'XTA. Hozir boshqa hech narsa qilma. Oxirgi amalda nima o'zgargani ro'yxatini ber
(fayllar, buyruqlar). Keyin nima qilishni men aytaman.
```

### 0.6 O'zgarishlarni tekshirish
```
Hozirgacha qilgan barcha o'zgarishlaringni ko'rsat (git diff asosida). Hech narsani commit qilma.
Har bir o'zgarish nima uchun kerakligini qisqa izohla.
```

### 0.7 Commit (faqat men so'raganda)
```
O'zgarishlarni ko'rib chiqdim. Commit xabarini taklif qil, lekin commit QILMA.
Men tasdiqlagandan keyin commit qil. Push qilma.
```

---

## 🏗️ 1-BOSQICH: FUNDAMENT

### 1.1 Flutter loyihasini yaratish
```
Flutter loyihasini yaratish rejasini tuz (hali bajarma):
- Loyiha nomi: aqlli_dostlar, platformalar: android, ios
- Papka strukturasi: feature-first (lib/core, lib/features, lib/shared)
- Paketlar: flutter_riverpod, go_router, hive, hive_flutter, audioplayers, lottie, flutter_localizations
- INTERNET permission qo'shilmasin
Aniq buyruqlar va yaratiladigan papkalar ro'yxatini ko'rsat. Ruxsatimni kut.
```

### 1.2 Navigatsiya (go_router)
```
go_router bilan navigatsiya rejasini tuz. Ekranlar: splash, profil_tanlash, profil_yaratish,
bosh_menyu, oyin (parametrli), natija, ota_ona_pin, ota_ona_panel.
Qaysi fayllar yaratilishini ko'rsat. Kod yozishdan oldin ruxsat so'ra.
```

### 1.3 Profil tizimi (FR-1, FR-2)
```
TZ dagi FR-1 va FR-2 asosida profil tizimini loyihalashtir:
- Model: ism, yosh, avatar, yaratilgan sana
- Bir nechta profil (oila uchun)
- Yoshga qarab modul avtomatik tanlanishi: 5-7→A, 8-9→B, 10-12→C
Avval model va fayllar rejasini ko'rsat. Ruxsatdan keyin to'liq ishlaydigan kod yoz.
```

### 1.4 Lokal DB (FR-5)
```
Hive bilan progress va sozlamalarni saqlash qatlamini (repository) loyihalashtir.
Saqlanadigan ma'lumotlar: profillar, har o'yin bo'yicha yulduzchalar, ekran vaqti.
Faqat reja — kod yozishga ruxsat so'ra.
```

---

## 🧸 2-BOSQICH: MODUL A (5-7 yosh)

### 2.1 Xotira o'yini (Memory Match)
```
TZ dagi "Xotira o'yini" uchun reja tuz:
- 3 daraja: 4x4, 4x6, 6x6
- Hayvon/meva kartalari, aylanish animatsiyasi
- Natija: yulduzcha (1-3) + sarflangan vaqt (FR-4)
- Xato uchun jazo yo'q, faqat rag'batlantirish
- Mustaqil papka: lib/features/games/memory_match/ (FR-3)
Fayllar ro'yxati va o'yin mantiqini ko'rsat. Ruxsatimni kut.
```

### 2.2 Harf-Raqam bog'chasi
```
"Harf-Raqam bog'chasi" o'yini rejasini tuz: ovoz bilan harf/raqamni tartibda bosish.
O'zbek lotin alifbosi. Ovoz fayllari qayerda saqlanishini va audioplayers qanday ishlatilishini ko'rsat.
Kod yozma — avval reja.
```

### 2.3 Rang-Shakl sortiri
```
Draggable/DragTarget bilan "Rang-Shakl sortiri" rejasini tuz.
Tugmalar 5 yoshli bola uchun katta bo'lsin (min 64dp). Reja → ruxsat → kod.
```

---

## 👨‍👩‍👧 3-BOSQICH: OTA-ONA PANELI

### 3.1 PIN va panel (FR-6, FR-7)
```
Ota-ona paneli rejasini tuz:
- 4 xonali PIN (lokal, xavfsiz saqlash)
- Kunlik ekran vaqti chegarasi (15/30/45/60 daq)
- Chegaraga yetganda muloyim eslatma ekrani (qo'rqitmasdan)
- Progress hisobot: qaysi o'yin, nechta yulduz, qaysi ko'nikma
Faqat reja, ruxsatimni kut.
```

---

## 🧮 4-BOSQICH: MODUL B (8-9 yosh)

```
TZ dagi Modul B dan "[Matematik sarguzasht / So'z quramchisi / Labirint-kviz]" o'yini uchun reja tuz.
Mavjud Modul A arxitekturasiga mos bo'lsin (umumiy natija ekrani, yulduzcha tizimi qayta ishlatilsin).
Reja → ruxsat → kod.
```

---

## 🌱 5-BOSQICH: MODUL C (10-12 yosh)

```
TZ dagi Modul C dan "[Eko-shahar / Bilim kvizi / Blok-kodlash]" uchun reja tuz.
Bu eng murakkab qism — rejani kichik qismlarga bo'l, har qismni alohida ruxsat bilan bajaramiz.
```

---

## 🐞 XATO TUZATISH

### Xatoni tahlil qilish
```
Mana xato: [xato matni]
Hech narsani o'zgartirma. Avval:
1. Xato sababini tushuntir
2. Qaysi fayl/qator
3. 1-2 ta yechim variantini taklif qil
Men tanlagandan keyingina tuzat.
```

### Kod review
```
[fayl yoki papka] ni ko'rib chiq. Hech narsani o'zgartirma.
Tekshir: xatolar, TZ ga moslik, bolalar xavfsizligi qoidalari, 60 FPS uchun performance.
Topilganlarni ro'yxat qilib ber, men qaysi birini tuzatishni aytaman.
```

---

## ✅ BOSQICH YAKUNIDA

### Bosqich tekshiruvi
```
[N]-bosqich tugadi deb hisoblayapman. Hech narsani o'zgartirma. Tekshir:
1. TZ dagi shu bosqichga tegishli barcha talablar bajarildimi? (FR/NFR ro'yxati bilan)
2. flutter analyze natijasi (buyruqni ishga tushirishdan oldin ruxsat so'ra)
3. Nima qoldi yoki yaxshilash kerak
```

### Bosqichni yangilash
```
CLAUDE.md dagi "Joriy bosqich" qatorini "[N]-bosqich — [nomi]" ga o'zgartirish rejasini ko'rsat.
Faqat shu qatorni o'zgartir, ruxsatimdan keyin.
```

---

## 🛡️ XAVFSIZLIK TEKSHIRUVI (reliz oldidan)
```
Butun loyihani bolalar xavfsizligi bo'yicha tekshir, hech narsani o'zgartirma:
- pubspec.yaml da tracking/reklama/analytics paketlari bormi?
- AndroidManifest.xml va Info.plist da keraksiz ruxsatlar (INTERNET, joylashuv, kamera) bormi?
- Tashqi URL yoki tarmoq so'rovlari bormi?
- Qo'rqinchli/jazolovchi matnlar bormi?
Natijani jadval shaklida ber.
```
