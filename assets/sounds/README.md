# Ovoz fayllari

Ilova bu fayllar bo'lmasa ham ishlaydi. Fayllar qo'shilgach, avtomatik ijro etiladi —
kodni o'zgartirish shart emas, faqat ilovani qayta yig'ish kerak.

## effects/
| Fayl | Qachon |
|---|---|
| `correct.wav` | To'g'ri javob |
| `try_again.wav` | Xato (muloyim, qo'rqitmaydigan ovoz) |
| `win.wav` | O'yin tugadi |

## uz/words/ — odam ovozida o'zbekcha so'zlar

Ko'p telefonlarda o'zbek tili ovoz dvigateli yo'q. Shu papkadagi fayl bo'lsa,
"Alifbolar", "Sanash" va "Harf-Raqam bog'chasi" o'yinlari uni chaladi;
bo'lmasa telefonning ovoz dvigateli bilan o'qiydi (u ham bo'lmasa — jim).

### Qanday yozib olish
1. Tinch xonada, telefon diktofonida yozing. Har so'z — alohida fayl.
2. Ovoz aniq, quvnoq va biroz sekin bo'lsin. Boshida va oxirida jimlik qisqa bo'lsin (≈0.2 s).
3. Formati: `.mp3` (yoki `.m4a` dan `.mp3` ga o'giring), mono, 1–2 soniya.
4. Fayl nomi aynan jadvaldagidek bo'lsin: kichik harf, `ʻ` o'rniga `_`, bo'sh joy o'rniga `_`.
5. Fayllarni `assets/sounds/uz/words/` papkasiga tashlang va ilovani qayta yig'ing.

Fayl nomi qoidasi: aytiladigan matn → kichik harf, `ʻ`/`'` → `_`, bo'sh joy → `_`, oxiriga `.mp3`.
Masalan: `toʻrt` → `to_rt.mp3`, `oʻn bir` → `o_n_bir.mp3`.

### 1-navbat: harflar (29 ta)
| Harf | Aytiladi | Fayl |
|---|---|---|
| A | a | `a.mp3` |
| B | be | `be.mp3` |
| D | de | `de.mp3` |
| E | e | `e.mp3` |
| F | ef | `ef.mp3` |
| G | ge | `ge.mp3` |
| H | he | `he.mp3` |
| I | i | `i.mp3` |
| J | je | `je.mp3` |
| K | ke | `ke.mp3` |
| L | el | `el.mp3` |
| M | em | `em.mp3` |
| N | en | `en.mp3` |
| O | o | `o.mp3` |
| P | pe | `pe.mp3` |
| Q | qe | `qe.mp3` |
| R | er | `er.mp3` |
| S | es | `es.mp3` |
| T | te | `te.mp3` |
| U | u | `u.mp3` |
| V | ve | `ve.mp3` |
| X | xe | `xe.mp3` |
| Y | ye | `ye.mp3` |
| Z | ze | `ze.mp3` |
| Oʻ | oʻ | `o_.mp3` |
| Gʻ | gʻe | `g_e.mp3` |
| Sh | sha | `sha.mp3` |
| Ch | che | `che.mp3` |
| Ng | nge | `nge.mp3` |

### 2-navbat: sonlar 1–20
| Son | Aytiladi | Fayl |
|---|---|---|
| 1 | bir | `bir.mp3` |
| 2 | ikki | `ikki.mp3` |
| 3 | uch | `uch.mp3` |
| 4 | toʻrt | `to_rt.mp3` |
| 5 | besh | `besh.mp3` |
| 6 | olti | `olti.mp3` |
| 7 | yetti | `yetti.mp3` |
| 8 | sakkiz | `sakkiz.mp3` |
| 9 | toʻqqiz | `to_qqiz.mp3` |
| 10 | oʻn | `o_n.mp3` |
| 11 | oʻn bir | `o_n_bir.mp3` |
| 12 | oʻn ikki | `o_n_ikki.mp3` |
| 13 | oʻn uch | `o_n_uch.mp3` |
| 14 | oʻn toʻrt | `o_n_to_rt.mp3` |
| 15 | oʻn besh | `o_n_besh.mp3` |
| 16 | oʻn olti | `o_n_olti.mp3` |
| 17 | oʻn yetti | `o_n_yetti.mp3` |
| 18 | oʻn sakkiz | `o_n_sakkiz.mp3` |
| 19 | oʻn toʻqqiz | `o_n_to_qqiz.mp3` |
| 20 | yigirma | `yigirma.mp3` |

### 3-navbat: sonlar 21–100 (Sanash o'yinining "100 gacha" darajasi)
| Son | Aytiladi | Fayl |
|---|---|---|
| 21 | yigirma bir | `yigirma_bir.mp3` |
| 22 | yigirma ikki | `yigirma_ikki.mp3` |
| 23 | yigirma uch | `yigirma_uch.mp3` |
| 24 | yigirma toʻrt | `yigirma_to_rt.mp3` |
| 25 | yigirma besh | `yigirma_besh.mp3` |
| 26 | yigirma olti | `yigirma_olti.mp3` |
| 27 | yigirma yetti | `yigirma_yetti.mp3` |
| 28 | yigirma sakkiz | `yigirma_sakkiz.mp3` |
| 29 | yigirma toʻqqiz | `yigirma_to_qqiz.mp3` |
| 30 | oʻttiz | `o_ttiz.mp3` |
| 31 | oʻttiz bir | `o_ttiz_bir.mp3` |
| 32 | oʻttiz ikki | `o_ttiz_ikki.mp3` |
| 33 | oʻttiz uch | `o_ttiz_uch.mp3` |
| 34 | oʻttiz toʻrt | `o_ttiz_to_rt.mp3` |
| 35 | oʻttiz besh | `o_ttiz_besh.mp3` |
| 36 | oʻttiz olti | `o_ttiz_olti.mp3` |
| 37 | oʻttiz yetti | `o_ttiz_yetti.mp3` |
| 38 | oʻttiz sakkiz | `o_ttiz_sakkiz.mp3` |
| 39 | oʻttiz toʻqqiz | `o_ttiz_to_qqiz.mp3` |
| 40 | qirq | `qirq.mp3` |
| 41 | qirq bir | `qirq_bir.mp3` |
| 42 | qirq ikki | `qirq_ikki.mp3` |
| 43 | qirq uch | `qirq_uch.mp3` |
| 44 | qirq toʻrt | `qirq_to_rt.mp3` |
| 45 | qirq besh | `qirq_besh.mp3` |
| 46 | qirq olti | `qirq_olti.mp3` |
| 47 | qirq yetti | `qirq_yetti.mp3` |
| 48 | qirq sakkiz | `qirq_sakkiz.mp3` |
| 49 | qirq toʻqqiz | `qirq_to_qqiz.mp3` |
| 50 | ellik | `ellik.mp3` |
| 51 | ellik bir | `ellik_bir.mp3` |
| 52 | ellik ikki | `ellik_ikki.mp3` |
| 53 | ellik uch | `ellik_uch.mp3` |
| 54 | ellik toʻrt | `ellik_to_rt.mp3` |
| 55 | ellik besh | `ellik_besh.mp3` |
| 56 | ellik olti | `ellik_olti.mp3` |
| 57 | ellik yetti | `ellik_yetti.mp3` |
| 58 | ellik sakkiz | `ellik_sakkiz.mp3` |
| 59 | ellik toʻqqiz | `ellik_to_qqiz.mp3` |
| 60 | oltmish | `oltmish.mp3` |
| 61 | oltmish bir | `oltmish_bir.mp3` |
| 62 | oltmish ikki | `oltmish_ikki.mp3` |
| 63 | oltmish uch | `oltmish_uch.mp3` |
| 64 | oltmish toʻrt | `oltmish_to_rt.mp3` |
| 65 | oltmish besh | `oltmish_besh.mp3` |
| 66 | oltmish olti | `oltmish_olti.mp3` |
| 67 | oltmish yetti | `oltmish_yetti.mp3` |
| 68 | oltmish sakkiz | `oltmish_sakkiz.mp3` |
| 69 | oltmish toʻqqiz | `oltmish_to_qqiz.mp3` |
| 70 | yetmish | `yetmish.mp3` |
| 71 | yetmish bir | `yetmish_bir.mp3` |
| 72 | yetmish ikki | `yetmish_ikki.mp3` |
| 73 | yetmish uch | `yetmish_uch.mp3` |
| 74 | yetmish toʻrt | `yetmish_to_rt.mp3` |
| 75 | yetmish besh | `yetmish_besh.mp3` |
| 76 | yetmish olti | `yetmish_olti.mp3` |
| 77 | yetmish yetti | `yetmish_yetti.mp3` |
| 78 | yetmish sakkiz | `yetmish_sakkiz.mp3` |
| 79 | yetmish toʻqqiz | `yetmish_to_qqiz.mp3` |
| 80 | sakson | `sakson.mp3` |
| 81 | sakson bir | `sakson_bir.mp3` |
| 82 | sakson ikki | `sakson_ikki.mp3` |
| 83 | sakson uch | `sakson_uch.mp3` |
| 84 | sakson toʻrt | `sakson_to_rt.mp3` |
| 85 | sakson besh | `sakson_besh.mp3` |
| 86 | sakson olti | `sakson_olti.mp3` |
| 87 | sakson yetti | `sakson_yetti.mp3` |
| 88 | sakson sakkiz | `sakson_sakkiz.mp3` |
| 89 | sakson toʻqqiz | `sakson_to_qqiz.mp3` |
| 90 | toʻqson | `to_qson.mp3` |
| 91 | toʻqson bir | `to_qson_bir.mp3` |
| 92 | toʻqson ikki | `to_qson_ikki.mp3` |
| 93 | toʻqson uch | `to_qson_uch.mp3` |
| 94 | toʻqson toʻrt | `to_qson_to_rt.mp3` |
| 95 | toʻqson besh | `to_qson_besh.mp3` |
| 96 | toʻqson olti | `to_qson_olti.mp3` |
| 97 | toʻqson yetti | `to_qson_yetti.mp3` |
| 98 | toʻqson sakkiz | `to_qson_sakkiz.mp3` |
| 99 | toʻqson toʻqqiz | `to_qson_to_qqiz.mp3` |
| 100 | yuz | `yuz.mp3` |

## uz/letters/, uz/numbers/
Eski papkalar — endi ishlatilmaydi. Yangi yozuvlarni `uz/words/` ga qo'shing.
