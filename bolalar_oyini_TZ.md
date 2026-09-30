# "Aqlli Do'stlar" — Bolalar uchun Ta'limiy O'yin
## Mahsulot Rejasi va Texnik Topshiriq (TZ)

**Loyiha turi:** Shaxsiy/Portfolio loyiha
**Platforma:** Flutter (Android + iOS)
**Maqsadli auditoriya:** 5-12 yosh bolalar
**Sana:** 2026-yil, Avgust

---

## 1. LOYIHA HAQIDA UMUMIY MA'LUMOT

### 1.1 G'oya
"Aqlli Do'stlar" — bir nechta mini-o'yinlardan iborat, bolalarni yosh guruhiga qarab avtomatik moslashtiruvchi ta'limiy platforma. Bolalar bitta bosh menyudan turli mini-o'yinlarni tanlab o'ynaydi, har biri mantiq, til, matematika yoki ekologik ongni rivojlantiradi.

### 1.2 Muammo va yechim
| Muammo | Yechim |
|---|---|
| Ko'pchilik bolalar o'yinlari zararli reklama/IAP bilan to'la | 100% reklamasiz, ichki xariddan xoli |
| Bir yosh guruhiga mo'ljallangan o'yinlar tez zeriktiradi | 3 yosh bosqichi (5-7, 8-9, 10-12) uchun alohida modul |
| Ekranga vaqt sarflash foydasiz bo'lishi mumkin | Har bir o'yin aniq bir ko'nikmani rivojlantiradi |
| Ota-onalar nazoratsiz qoladi | Ota-ona paneli: vaqt chegarasi, progress hisobot |

### 1.3 Asosiy tamoyillar
- **Zararsizlik**: zo'ravonlik, qo'rqinchli kontent, reklama, IAP — yo'q
- **Moslashuvchanlik**: yosh bosqichiga qarab qiyinlik darajasi avtomatik sozlanadi
- **Ijobiy mustahkamlash**: xato — o'rganish imkoniyati, jazolash yo'q
- **Offline ishlash**: internetga bog'liq emas (asosiy funksiyalar)

---

## 2. MAHSULOT ARXITEKTURASI (Modullar)

### Modul A — "Kichkintoylar" (5-7 yosh)
1. **Xotira o'yini (Memory Match)** — hayvon/meva juftliklarini topish, 3 qiyinlik darajasi (4x4, 4x6, 6x6)
2. **Harf-Raqam bog'chasi** — tovush bilan harf/raqamlarni to'g'ri tartibda bosish
3. **Rang-Shakl sortiri** — drag & drop orqali obyektlarni rang/shakliga qarab saralash

### Modul B — "O'rta guruh" (8-9 yosh)
4. **Matematik sarguzasht** — qo'shish/ayirish masalalari, har to'g'ri javob personajni bir qadam oldinga olib boradi
5. **So'z quramchisi** — berilgan harflardan so'z yasash (o'zbek tilida, keyinchalik ingliz tili qo'shiladi)
6. **Labirint-kviz** — labirintdan chiqish yo'lida oddiy savollarga javob berish

### Modul C — "Kattalar" (10-12 yosh)
7. **Eko-shahar quruvchi** — daraxt ekish, chiqindi saralash, energiya tejash orqali shahar rivojlantirish (simulyatsiya)
8. **Bilim kvizi** — fizika, geografiya, tarixdan bosqichma-bosqich savollar, yutuq tizimi bilan
9. **Blok-kodlash asoslari** — Scratch uslubida oddiy buyruq bloklari bilan personajni harakatlantirish

### Umumiy tizimlar (barcha modullar uchun)
- **Avatar va profil** — bola o'z avatarini tanlaydi (bir nechta profil qo'llab-quvvatlanadi — oila uchun)
- **Yulduzcha/Medal tizimi** — har o'yin uchun yutuqlar, umumiy "yutuqlar javoni"
- **Ota-ona paneli** (PIN-kod bilan himoyalangan) — ekran vaqti chegarasi, bolaning progressi, qaysi ko'nikmalar rivojlanayotgani haqida hisobot

---

## 3. FOYDALANUVCHI OQIMI (User Flow)

```
Ilovani ochish
   → Profil tanlash/yaratish (bola yoshini kiritish)
   → Bosh menyu (yosh guruhiga mos modul avtomatik ochiladi,
      boshqa modullar "qulflangan, lekin ko'rinadi" holatda)
   → O'yin tanlash → O'yin ichida → Natija ekrani (yulduzcha)
   → Bosh menyuga qaytish yoki keyingi o'yin
```

Ota-ona paneli: Bosh menyu → pastdagi kichik "Ota-ona" tugmasi → PIN so'raladi → Panel

---

## 4. TEXNIK TOPSHIRIQ (TZ)

### 4.1 Texnologiyalar steki

| Qatlam | Texnologiya |
|---|---|
| Framework | Flutter (Dart), so'nggi barqaror versiya |
| State Management | Riverpod (yoki Provider — oddiyligi uchun) |
| Lokal ma'lumot bazasi | Hive yoki SharedPreferences (progress, sozlamalar) |
| Animatsiyalar | Flutter native animatsiyalar + `rive` yoki `lottie` (personaj animatsiyalari uchun) |
| Ovoz | `audioplayers` paketi |
| Drag & Drop | `Draggable` / `DragTarget` widgetlari |
| Ikonografiya/Grafika | Maxsus chizilgan (Figma/Illustrator) yoki ochiq litsenziyali asset paketlar |
| Til qo'llab-quvvatlash | `flutter_localizations` (o'zbek, rus, ingliz — kelajakda) |

### 4.2 Funksional talablar

**FR-1.** Ilova birinchi ochilishda profil yaratish oynasini ko'rsatishi kerak (ism, yosh, avatar)
**FR-2.** Yosh kiritilgandan so'ng tizim mos modulni (A/B/C) avtomatik tavsiya qilishi kerak
**FR-3.** Har bir mini-o'yin mustaqil modul sifatida ishlashi va boshqalarga bog'liq bo'lmasligi kerak
**FR-4.** Har bir o'yin tugagach, natija ekrani (yulduzcha soni, sarflangan vaqt) ko'rsatilishi kerak
**FR-5.** Progress lokal saqlanishi va ilova qayta ochilganda tiklanishi kerak
**FR-6.** Ota-ona paneli PIN-kod bilan himoyalangan bo'lishi kerak
**FR-7.** Ota-ona paneli orqali kunlik ekran vaqti chegarasi o'rnatilishi kerak (masalan, 30 daqiqa), chegaraga yetganda ilova muloyim tarzda yopilishi/eslatma berishi kerak
**FR-8.** Barcha matnlar va ovozli buyruqlar o'zbek tilida bo'lishi kerak (MVP uchun)
**FR-9.** Ilova to'liq offline rejimda ishlashi kerak (internet talab qilinmaydi)

### 4.3 Nofunksional talablar

**NFR-1.** Ilova 5 yoshli bola mustaqil foydalanishi mumkin bo'ladigan darajada sodda interfeysga ega bo'lishi kerak (katta tugmalar, minimal matn, ko'p ikonka/rasm)
**NFR-2.** Har bir ekran 3 soniyadan tez yuklanishi kerak
**NFR-3.** Ilovada hech qanday tashqi reklama, ichki xarid yoki uchinchi tomon tracking SDK bo'lmasligi kerak
**NFR-4.** Ilova past-o'rta darajali qurilmalarda ham silliq ishlashi kerak (60 FPS maqsad)
**NFR-5.** Barcha rangli sxema bolalarga mos, yorqin, lekin ko'zga zararli yaltiroq effektlarsiz bo'lishi kerak

### 4.4 Xavfsizlik va zararsizlik talablari
- COPPA/GDPR-K kabi bolalar maxfiyligi tamoyillariga mos (shaxsiy ma'lumot yig'ilmaydi, faqat lokal saqlanadi)
- Internetga ulanish talab qilinmagani uchun tashqi kontent xavfi yo'q
- Zo'ravonlik, qo'rqinchli obrazlar, yoshga nomos mavzular — butunlay istisno qilingan

---

## 5. DIZAYN YO'NALISHI

- **Uslub**: yumshoq, yorqin, "flat design" + engil 2D animatsiyalar
- **Personajlar**: 1 asosiy mascot (masalan, kichik robot yoki hayvon), barcha modullarda yo'lboshchi sifatida ishtirok etadi
- **Shrift**: yumaloq, o'qish oson bo'lgan bolalar shrifti (masalan, "Baloo 2" yoki shunga o'xshash)
- **Ranglar**: issiq va sovuq ranglar muvozanati, har modul uchun o'z rang palitrasi (A — pastel, B — yorqin, C — energiya beruvchi)

---

## 6. ISHLAB CHIQISH BOSQICHLARI (Roadmap)

| Bosqich | Davomiyligi (taxminiy) | Natija |
|---|---|---|
| **1-bosqich: Fundament** | 1-2 hafta | Loyiha strukturasi, navigatsiya, profil tizimi, lokal DB sozlash |
| **2-bosqich: MVP — Modul A** | 2-3 hafta | Xotira o'yini + Harf-Raqam bog'chasi to'liq ishlaydigan holatda |
| **3-bosqich: Ota-ona paneli** | 1 hafta | PIN himoyasi, vaqt chegarasi, progress hisobot |
| **4-bosqich: Modul B** | 2-3 hafta | Matematik sarguzasht + So'z quramchisi |
| **5-bosqich: Modul C** | 3-4 hafta | Eko-shahar quruvchi + Bilim kvizi (eng murakkab qism) |
| **6-bosqich: Sinov va sayqallash** | 1-2 hafta | Bug-fix, UX yaxshilash, bolalar bilan sinov (agar imkon bo'lsa) |
| **7-bosqich: Relizga tayyorlash** | 1 hafta | Ikonka, splash screen, store listing, APK/IPA build |

**Jami taxminiy vaqt: ~12-16 hafta** (bir kishi, part-time ishlaganda cho'zilishi mumkin)

> 💡 Portfolio loyiha uchun tavsiya: 6-9 o'yinning hammasini birdan qilishga urinmang. Modul A ni to'liq sifatli qiling, keyin GitHub/portfolioga qo'yib, bosqichma-bosqich B va C ni qo'shing — bu progress ko'rsatish uchun ham yaxshi.

---

## 7. KEYINGI QADAMLAR

1. Figma'da wireframe/UI mockup tayyorlash (bosh menyu, 1-modul ekranlari)
2. Flutter loyihasini boshlash: papka strukturasi, navigatsiya (go_router tavsiya etiladi)
3. Modul A dan boshlab, bittalab o'yinlarni ishlab chiqish
4. Har bir o'yin tugagach, kichik doiraga (oila, do'stlar) ko'rsatib fikr-mulohaza olish

---

*Ushbu hujjat dastlabki reja sifatida tuzilgan — ishlab chiqish jarayonida talablar o'zgarishi mumkin.*
