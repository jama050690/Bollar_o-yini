# Konsol formalari uchun tayyor javoblar — "Aqlli Do'stlar"

Play Console'ning asosiy formalari (Data safety, IARC, Target audience va h.k.)
[listing_uz.md](listing_uz.md) ning 4-bo'limida. Bu fayl qolganlarini to'ldiradi:
**A** — Google Play yopiq test (12 tester × 14 kun), **B** — App Store Connect.

Umumiy ma'lumotlar:

| | Qiymat |
|---|---|
| Android package | `uz.aqllidostlar.aqlli_dostlar` |
| iOS Bundle ID | `uz.aqllidostlar.aqlliDostlar` |
| Versiya | `1.0.0 (1)` |
| Maxfiylik siyosati | https://jama050690.github.io/Bollar_o-yini/privacy-policy.html |
| Aloqa | `jbm050690@gmail.com` |

---

## A. Google Play — yopiq test (12 tester × 14 kun)

2023-yil 13-noyabrdan keyin ochilgan **shaxsiy** developer akkauntlarda Production'ga
chiqishdan oldin majburiy. 14 kun **uzluksiz** bo'lishi kerak: kimdir chiqib ketsa,
hisob qaytadan boshlanishi mumkin, shuning uchun **15–20 kishi** taklif qiling.

### A.1 Qadamlar

1. **Testing → Closed testing → Create track** (yoki tayyor "Alpha").
2. **Testers → Create email list** → "Aqlli Do'stlar testerlari" → 15–20 ta Gmail.
   Har bir tester Play Market'da o'sha Gmail bilan kirgan bo'lishi kerak.
3. **Feedback URL or email:** `jbm050690@gmail.com`
4. **Create new release** → `app-release.aab` → Release notes (pastda) → **Review and roll out**.
5. Google tasdiqlagach (odatda 1–3 kun) **Copy link** → testerlarga yuboring.
6. Har tester: havolani ochadi → **Become a tester** → Play Market'dan o'rnatadi.
7. 14 kun davomida testerlar ilovani **o'chirmasin**; kamida bir necha marta ochib o'ynasin.
8. 14 kundan keyin: **Dashboard → Apply for production** → savollarga javob (A.4).

### A.2 Release notes (yopiq test)
```
<uz-UZ>
Sinov versiyasi: 30 ta ta'limiy o'yin, ota-ona paneli, kunlik vaqt chegarasi, yutuqlar va sertifikat.
</uz-UZ>
<ru-RU>
Тестовая версия: 30 обучающих игр, родительская панель, дневной лимит времени, награды и сертификат.
</ru-RU>
<en-US>
Test build: 30 educational games, parent panel, daily time limit, achievements and certificate.
</en-US>
```

### A.3 Testerlarga taklif matni

**O'zbekcha:**
```
Assalomu alaykum! 🙂
Men bolalar uchun "Aqlli Do'stlar" ta'limiy o'yinini yaratdim (5–12 yosh, reklamasiz, internetsiz).
Google Play'ga chiqarish uchun 14 kunlik sinovda qatnashishingizni so'rayman:

1) Shu havolani telefoningizdagi Gmail bilan oching: <HAVOLA>
2) "Become a tester" tugmasini bosing
3) Play Market'dan ilovani o'rnating
4) 14 kun davomida o'chirmang, vaqti-vaqti bilan ochib ko'ring

Fikr va xatolarni shu yerga yozing: jbm050690@gmail.com
Rahmat! 🙏
```

**Русский:**
```
Здравствуйте! 🙂
Представляю обучающую игру для детей «Aqlli Do'stlar» (5–12 лет, без рекламы и интернета).
Для публикации в Google Play прошу поучаствовать в 14-дневном тестировании:

1) Откройте ссылку с Gmail, который на телефоне: <ССЫЛКА>
2) Нажмите «Стать тестировщиком»
3) Установите приложение из Play Маркета
4) Не удаляйте его 14 дней, иногда открывайте

Отзывы и ошибки: jbm050690@gmail.com
Спасибо! 🙏
```

### A.4 "Apply for production" savollariga javob namunalari

- **How did you recruit testers?**
  `Family members, friends and colleagues with children aged 5–12.`
- **How easy was it to recruit testers?** → *Neither easy nor difficult* (haqiqatga qarab)
- **Describe the engagement you received from testers:**
  `Testers played the games with their children over 14 days and reported layout and difficulty feedback by email.`
- **Summarize the feedback and how you used it:**
  *(haqiqiy fikrlarni yozing, masalan: "Increased button sizes, adjusted difficulty in counting games, fixed text on small screens.")*
- **Who is the intended audience?** `Children aged 5–12 and their parents in Uzbekistan.`
- **How does the app provide value?** `Free offline educational games in Uzbek: math, reading, logic and memory, with no ads or data collection.`
- **Expected installs in first year:** *0–10K*
- **What changes did you make based on testing?** *(haqiqiy o'zgarishlar)*
- **How did you decide the app is ready?** `All 30 games were completed by testers on several Android devices without crashes.`

> ⚠️ Javoblar **haqiqiy** bo'lsin: Google sun'iy/bir xil javoblarni rad etadi.
> Testerlardan kelgan fikrlarni 14 kun davomida yozib boring.

---

## B. App Store Connect

### B.1 App Information
| Maydon | Qiymat |
|---|---|
| Name | `Aqlli Do'stlar` |
| Subtitle (30 belgi) | `Bolalar uchun ta'limiy o'yinlar` |
| Primary category | **Education** |
| Secondary category | **Games → Educational** (ixtiyoriy) |
| Content Rights | **No**, it does not contain third-party content |
| Primary language | Uzbek (bo'lmasa English (U.S.)) |

> ⚠️ Qurilmadagi nom: iOS'da `Aqlli Dostlar` (apostrofsiz), Android'da `Aqlli Do'stlar`.
> Bu rad etish sababi emas, lekin keyinchalik birxillashtirish tavsiya etiladi.

### B.2 App Privacy (Data Collection)
- **Do you or your third-party partners collect data from this app?** → **No, we do not collect data from this app**
- Natija: ilova sahifasida **"Data Not Collected"** chiqadi.
- Privacy Policy URL: https://jama050690.github.io/Bollar_o-yini/privacy-policy.html
- Ilova ichidagi `PrivacyInfo.xcprivacy` shunga mos: tracking yo'q, ma'lumot yig'ilmaydi.

### B.3 Age Rating so'rovnomasi
Barcha kontent savollari → **None / No**:
- Cartoon or fantasy violence — None
- Realistic violence — None
- Profanity or crude humor — None
- Mature/suggestive themes — None
- Horror/fear themes — None
- Medical/treatment information — None
- Alcohol, tobacco, drugs — None
- Simulated gambling — None
- Sexual content / nudity — None
- Contests — None
- Unrestricted web access — **No**
- User-generated content / messaging / chat — **No**
- Advertising — **No**
- Parental controls — **Yes** (ota-ona paneli: kunlik vaqt chegarasi, PIN)
- Age assurance — **No**

**Kids Category:** ✅ **Made for Kids** → Age band: **6–8**
(Bitta band tanlanadi; asosiy kontent 5–9 yoshga mos. Kutilgan reyting: **4+**.)

Kids Category talablari va ilovaning holati:

| Apple talabi (1.3, 5.1.4) | Holati |
|---|---|
| Reklama, analytics, tracking SDK yo'q | ✅ Hech qanday SDK yo'q |
| Ilovadan tashqariga havola / xarid → parental gate ortida | ✅ Tashqi havola va xarid yo'q; ota-ona bo'limi darvoza ortida |
| Ma'lumot yig'ilmaydi | ✅ Faqat qurilmada (Hive) |
| Maxfiylik siyosati | ✅ Ilova ichida va onlayn |

### B.4 Pricing and Availability
- Price: **Free** (0)
- Availability: barcha mamlakatlar (yoki faqat Uzbekistan + qo'shnilar)
- **In-App Purchases:** yo'q

### B.5 App Review Information
- **Sign-in required:** ❌ (o'chiq)
- **Contact:** Jamshiddin Babajonov, `jbm050690@gmail.com`, telefon raqamingiz
- **Notes** (inglizcha, nusxalang):
```
Thank you for reviewing "Aqlli Do'stlar" (Smart Friends), a free offline educational app for children aged 5–12 in the Uzbek language.

- No account or login is needed. On first launch, create a child profile (any name, choose an age). Age 5–7, 8–9 or 10–12 opens the matching set of games.
- The app works fully offline. It has no ads, no in-app purchases, no analytics, no tracking and no third-party SDKs. All data (profiles, stars, settings) is stored only on the device.
- Parental gate: the parent area (lock icon 🔒 on the home screen) is protected. On first entry the parent taps "I'm a grown-up" and solves a two-digit multiplication question (e.g. 17 × 6), then sets a 4-digit PIN. The same gate protects "Forgot PIN".
- The parent area contains: daily time limit, sound settings, progress report, interface language (Uzbek / Russian / English), Privacy Policy and About. Game content is in Uzbek.
- There are no external links, web views or purchase flows in the app.
```

### B.6 Version Information
- **Screenshots:**
  - iPad 13": `store/screenshots/ipad/` (6 ta, 2064×2752) ✅
  - iPhone 6.9": hali olinmagan (iPhone 17 Pro Max simulyatorida xuddi shu test bilan olinadi).
- **Promotional text:** `Reklamasiz, internetsiz 30 ta ta'limiy o'yin — matematika, o'qish, mantiq va xotira!`
- **Keywords** (100 belgigacha, vergul bilan, bo'shliqsiz):
  `bolalar,o'yin,ta'lim,matematika,alifbo,harflar,sanash,xotira,mantiq,maktab,o'zbek,ingliz`
- **Support URL:** `https://github.com/jama050690/Bollar_o-yini` (yoki privacy sahifasi)
- **Copyright:** `2026 Jamshiddin Babajonov`
- **Description:** [listing_uz.md](listing_uz.md) 2-bo'limidagi "Full description".

### B.7 Build yuklash
1. Xcode → Runner → Signing & Capabilities → o'z Team'ingizni tanlang.
2. `flutter build ipa --release`
3. `build/ios/ipa/*.ipa` → **Transporter** ilovasi orqali yuklash (yoki Xcode → Organizer → Distribute).
4. Export Compliance savoli chiqmaydi (`ITSAppUsesNonExemptEncryption = NO` qo'yilgan).
5. TestFlight'da o'zingiz sinab ko'ring → **Add for Review** → **Submit**.
