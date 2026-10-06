# Play Console uchun tayyor materiallar — "Aqlli Do'stlar"

Har bir bo'lim Play Console'dagi qaysi joyga kiritilishi bilan berilgan.
Matnlarni shu yerdan nusxalab qo'ying.

---

## 1. Asosiy ma'lumotlar (Create app)

| Maydon | Qiymat |
|---|---|
| App name | `Aqlli Do'stlar` |
| Default language | Uzbek – uz |
| App or game | **Game** |
| Free or paid | **Free** |
| Package name | `uz.aqllidostlar.aqlli_dostlar` (o'zgartirib bo'lmaydi) |

---

## 2. Main store listing

**App name** (30 belgigacha):
```
Aqlli Do'stlar
```

**Short description** (80 belgigacha):
```
5–12 yoshli bolalar uchun 30 ta ta'limiy o'yin. Reklamasiz va internetsiz!
```

**Full description** (4000 belgigacha):
```
🧠 Aqlli Do'stlar — 5 yoshdan 12 yoshgacha bo'lgan bolalar uchun o'zbek tilidagi ta'limiy o'yinlar to'plami.

Bola yoshini kiritadi va ilova unga mos o'yinlarni ochib beradi. Har bir o'yinda 3 xil qiyinlik darajasi bor, natijalar yulduzlar bilan baholanadi.

🐣 KICHKINTOYLAR (5–7 yosh)
• Xotira — juft kartalarni top
• Harf-Raqam — harf va raqamlarni o'rgan
• Rang-Shakl — ranglar va shakllarni sarala
• Sanash, Alifbolar, Karra jadvali
• Shakldan buyum, Rasm bo'yash
• Juftini top, Naqsh

🚀 O'RTA GURUH (8–9 yosh)
• Matematik sarguzasht, Arifmetika, Kasrlar
• So'z quramchisi, Mini-krossvord, Tarjimon
• Labirint-kviz, Mini-Sudoku
• Soat — vaqtni aniqlash
• Do'kon — pul va qaytim hisoblash

🏆 KATTALAR (10–12 yosh)
• Tenglamalar, Ketma-ketlik, Foizlar, Tez hisob
• Geometriya — perimetr va yuz
• Geografiya — davlatlar va poytaxtlar
• Tabiat — hayvonlar, o'simliklar, Yer va osmon
• Anagramma, Tarjimon+, Sudoku

👨‍👩‍👧 OTA-ONALAR UCHUN
• Bir nechta bola uchun alohida profillar
• PIN kod bilan himoyalangan ota-ona paneli
• Kunlik o'yin vaqti chegarasi (15 / 30 / 45 / 60 daqiqa)
• Har bir bola bo'yicha hisobot: o'ynagan vaqti, yulduzlari, sevimli o'yinlari

🛡️ XAVFSIZ VA TINCH
• Reklama yo'q
• Ilova ichida xarid yo'q
• Internet kerak emas — to'liq oflayn ishlaydi
• Hech qanday ma'lumot yig'ilmaydi, hammasi faqat telefonda saqlanadi
• Xato qilganda jazo yo'q — faqat "Yana urinib ko'r! 💪"
```

**Grafikalar** (`store/` papkasida):

| Maydon | Fayl | O'lcham |
|---|---|---|
| App icon | `store/icon_512.png` | 512×512 PNG |
| Feature graphic | `store/feature_graphic.png` | 1024×500 PNG |
| Phone screenshots | `store/screenshots/` | kamida 2 ta, 16:9 yoki 9:16 |

---

## 3. Store settings

| Maydon | Qiymat |
|---|---|
| App category | **Educational** (Game → Educational) |
| Tags | Educational, Puzzle, Math, Kids |
| Email | `jbm050690@gmail.com` |
| Website | bo'sh qoldirish mumkin |
| Phone | majburiy emas |

---

## 4. App content (Policy → App content)

### 4.1 Privacy policy
```
https://jama050690.github.io/Bollar_o-yini/privacy-policy.html
```
(GitHub Pages yoqilgandan keyin ishlaydi. Settings → Pages → Branch: `main`, Folder: `/docs`.)

### 4.2 App access
- ✅ **All functionality is available without special access**
- Izoh: ota-ona paneli PIN kodini foydalanuvchi birinchi kirishda o'zi o'rnatadi, oldindan berilgan login yo'q.

### 4.3 Ads
- ✅ **No, my app does not contain ads**

### 4.4 Content rating (IARC so'rovnomasi)
- Email: `jbm050690@gmail.com`
- Category: **All Other App Types** (yoki "Game" bo'lsa: *Puzzle / Educational*)
- Barcha savollarga javob: **No**
  - Violence — No
  - Sexuality — No
  - Language (so'kinish) — No
  - Controlled substances — No
  - Gambling / simulated gambling — No
  - User-generated content / users can interact — No
  - Shares user location — No
  - Allows purchases of digital goods — No
- Kutilgan natija: **3+ / Everyone**

### 4.5 Target audience and content
- Target age groups: ✅ **5 and under**, ✅ **6–8**, ✅ **9–12**
  (13+ belgilanmaydi)
- "Appeal to children" — **Yes**
- Natijada ilova **Families Policy** talablariga bo'ysunadi — ilova bularga mos:
  reklama yo'q, SDK yo'q, shaxsiy ma'lumot yig'ilmaydi.

### 4.6 News app
- **No**

### 4.7 Data safety
- Does your app collect or share any of the required user data types? → **No**
- Is all of the user data collected by your app encrypted in transit? → savol chiqmaydi (yig'ilmaydi)
- Do you provide a way for users to request that their data is deleted? → **No** yoki savol chiqmaydi
- Izoh (agar so'ralsa): *Ma'lumotlar faqat qurilmada saqlanadi va qurilmadan tashqariga chiqmaydi.
  Google ta'rifiga ko'ra bu "collection" hisoblanmaydi.*

### 4.8 Government apps
- **No**

### 4.9 Financial features
- **My app doesn't provide any financial features**

### 4.10 Health apps
- **My app does not have any health features**

### 4.11 Advertising ID
- **No** (ilova reklama ID ishlatmaydi)

---

## 5. Release

1. **Testing → Internal testing → Create new release**
2. Play App Signing: **Use Google-generated key** (tavsiya etiladi)
3. Fayl: `build/app/outputs/bundle/release/app-release.aab`
4. Release name: `1.0.0 (1)`
5. Release notes:
```
<uz-UZ>
Birinchi versiya: 30 ta ta'limiy o'yin, ota-ona paneli va kunlik vaqt chegarasi.
</uz-UZ>
```

> Yangi shaxsiy developer akkaunt bo'lsa: Production'dan oldin **Closed testing** da
> kamida **12 ta tester** **14 kun** davomida ilovani sinashi shart.

### Keyingi versiyalar
Har yangi yuklashda `pubspec.yaml` dagi `version: 1.0.0+1` dagi `+` dan keyingi raqam
oshirilishi shart (masalan `1.0.1+2`), aks holda Play faylni qabul qilmaydi.
