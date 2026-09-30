# CLAUDE.md — "Aqlli Do'stlar" loyihasi uchun qat'iy qoidalar

> Bu fayl Claude Code tomonidan har sessiya boshida avtomatik o'qiladi.
> Quyidagi qoidalar **boshqa barcha standart xatti-harakatlardan ustun turadi**.

---

## 0. ENG MUHIM QOIDA — RUXSATSIZ HECH NARSA QILINMAYDI

Claude quyidagi har qanday amaldan **OLDIN** menga reja ko'rsatadi va
**aniq "ha" / "ruxsat" / "davom et"** javobini kutadi:

| Amal | Ruxsat kerakmi? |
|---|---|
| Yangi fayl yaratish | ✅ HA |
| Mavjud faylni o'zgartirish | ✅ HA |
| Fayl yoki papkani o'chirish | ✅ HA (ikki marta so'ralsin) |
| Paket qo'shish / o'chirish (`pubspec.yaml`, `flutter pub add`) | ✅ HA |
| Terminal buyrug'i ishga tushirish (`flutter create`, `build`, `run`, skriptlar) | ✅ HA |
| `git commit`, `git push`, branch yaratish/o'chirish, `reset`, `rebase` | ✅ HA |
| Loyiha strukturasini / arxitekturani o'zgartirish | ✅ HA |
| TZ (`bolalar_oyini_TZ.md`) ni o'zgartirish | ✅ HA |
| Fayllarni o'qish, qidirish, tahlil qilish | ❌ Yo'q (faqat o'qish mumkin) |

### Ruxsat so'rash formati (har doim shunday):

```
📋 REJA:
1. Nima qilaman: ...
2. Qaysi fayllar: ... (yaratiladi / o'zgaradi / o'chiriladi)
3. Nima uchun: ...
4. Xavf / ta'sir: ...

❓ Davom etaymi? (ha / yo'q / o'zgartir)
```

### Qat'iy taqiqlar
- ❌ "Kichik o'zgarish" deb ruxsatsiz fayl tahrirlash
- ❌ Bir ruxsat bilan so'ralmagan qo'shimcha ishlarni qilish (scope creep)
- ❌ Bitta bosqichga berilgan ruxsatni keyingi bosqichga ham tatbiq etish
- ❌ Men so'ramagan refaktoring, qayta nomlash, formatlash
- ❌ Xato chiqsa, o'zboshimchalik bilan "tuzatib ketish" — avval xatoni tushuntirib, ruxsat so'ra
- ❌ `--force`, `rm -rf`, `git reset --hard` kabi qaytarib bo'lmaydigan buyruqlar (faqat men aniq yozsam)

---

## 1. Loyiha haqida qisqacha

- **Nomi:** "Aqlli Do'stlar" — 5-12 yosh bolalar uchun ta'limiy o'yin
- **Platforma:** Flutter (Android + iOS)
- **To'liq TZ:** [bolalar_oyini_TZ.md](bolalar_oyini_TZ.md) — har bir qarordan oldin shu faylga tayan
- **Modullar:** A (5-7 yosh), B (8-9 yosh), C (10-12 yosh)
- **Joriy bosqich:** 1-bosqich — Fundament *(bosqich o'zgarganda buni men yangilayman)*

## 2. Texnik stack (o'zgartirish faqat ruxsat bilan)

| Qatlam | Tanlov |
|---|---|
| State management | Riverpod |
| Navigatsiya | go_router |
| Lokal DB | Hive (sozlamalar uchun SharedPreferences) |
| Animatsiya | Flutter native + lottie/rive |
| Ovoz | audioplayers |
| Lokalizatsiya | flutter_localizations (MVP: faqat o'zbek) |

**Firebase / internet talab qiladigan paketlar ISHLATILMAYDI** — ilova to'liq offline (FR-9, NFR-3).

## 3. Bolalar xavfsizligi qoidalari (buzilmasin)

- Reklama, IAP, analytics, tracking SDK — **mutlaqo yo'q**
- Internet ruxsati (`INTERNET` permission) qo'shilmaydi
- Shaxsiy ma'lumot faqat qurilmada lokal saqlanadi
- Zo'ravonlik, qo'rqinchli kontent, jazolovchi xabarlar yo'q — xato = "Yana urinib ko'r! 💪"
- Katta tugmalar (min 64x64 dp), minimal matn, ko'p ikonka

## 4. Kod uslubi

- To'liq ishlaydigan kod yoz, snippet emas
- Har bir mini-o'yin mustaqil papkada: `lib/features/games/<oyin_nomi>/` (FR-3)
- Fayl nomlari: `snake_case.dart`; klasslar: `PascalCase`
- Barcha UI matnlari lokalizatsiya faylida, kod ichida qattiq yozilmaydi
- `flutter analyze` xatosiz bo'lishi kerak

## 5. Javob uslubi

- O'zbek tilida, qisqa va aniq
- Avval muammoni tushuntir → keyin yechim → keyin har qadamni izohla
- Bir vaqtda faqat **bitta** vazifa. Tugagach, to'xta va keyingisi uchun ruxsat so'ra
- Ishonching komil bo'lmasa — taxmin qilma, so'ra
