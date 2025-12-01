# 📊 XCODE LOG REHBERİ - Backend Olayları

## ✅ EVET! Xcode Console'da Tüm Backend Olaylarını Görebilirsin!

Uygulamayı çalıştırdığında Xcode console'unda şunları göreceksin:

---

## 🔍 GÖRECEĞİN LOGLAR

### 1. App Başlangıcı (Otomatik Test)

```
🔍 BACKEND CONNECTION TEST
==================================================

1️⃣ Checking Supabase Config...
   ✅ Project URL: https://anonrgyqhgfursmhxrqo.supabase.co
   ✅ Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6Ik...

2️⃣ Testing Device Registration...
   ✅ Device ID: [UUID]
   ✅ Device Registered: [UUID]

3️⃣ Testing Supabase Connection...
   ✅ Connected to Supabase!

4️⃣ Testing Database Tables...
   ✅ Table 'devices' accessible
   ✅ Table 'poop_logs' accessible
   ✅ Table 'achievements' accessible

==================================================
✅ TEST COMPLETE
```

### 2. Supabase İstekleri (Her API Call)

```
🌐 [14:30:15.123] REQUEST → GET poop_logs [fetchLogs]
✅ [14:30:15.456] RESPONSE ← poop_logs (5 items)

🌐 [14:30:20.789] REQUEST → POST poop_logs [createLog]
✅ [14:30:21.012] RESPONSE ← poop_logs (1 items)
```

### 3. Hatalar (Network, Decoding, vs.)

```
❌ [14:30:25.345] ERROR [fetchLogs]: Network error: Connection timeout
❌ [14:30:26.678] ERROR [createLog]: Failed to decode data: Invalid JSON
```

### 4. Sync İşlemleri

```
🔄 [14:35:00.000] Starting sync...
📤 Uploading local changes...
🔄 [14:35:00.123] SYNC create → poop_logs
📥 Downloading remote changes...
💾 Last sync date updated
✅ Sync completed
```

### 5. Device İşlemleri

```
📱 [14:30:10.000] DEVICE REGISTERED: [UUID]
📱 [14:30:15.000] DEVICE UPDATED: [UUID]
```

### 6. Cache İşlemleri

```
💾 [14:30:20.000] CACHE save → poop_logs (10 items)
💾 [14:30:25.000] CACHE load → achievements (5 items)
```

---

## 📱 XCODE'DA NASIL GÖRÜRSÜN?

### Adım 1: Uygulamayı Çalıştır
- **Cmd+R** veya **Run** butonuna tıkla

### Adım 2: Console'u Aç
- Xcode alt kısmında **Console** sekmesine tıkla
- Veya **View > Debug Area > Activate Console** (Shift+Cmd+Y)

### Adım 3: Logları Filtrele (Opsiyonel)
- Console'da sağ üstteki **filter** kutusuna yaz:
  - `🌐` - Sadece network istekleri
  - `❌` - Sadece hatalar
  - `🔄` - Sadece sync işlemleri
  - `📱` - Sadece device işlemleri

---

## 🔍 LOG TİPLERİ

| Icon | Anlam | Ne Zaman Görünür |
|------|-------|------------------|
| 🌐 | Network Request | Her Supabase API çağrısında |
| ✅ | Başarılı Response | İstek başarılı olduğunda |
| ❌ | Hata | Network, decoding, vs. hatalarında |
| 🔄 | Sync İşlemi | Background sync başladığında |
| 📱 | Device İşlemi | Device register/update olduğunda |
| 💾 | Cache İşlemi | Local storage'a yazma/okuma |
| ℹ️ | Bilgi | Genel bilgilendirme mesajları |

---

## 🎯 ÖRNEK SENARYO: Quick Log

Kullanıcı "Quick Log" butonuna tıkladığında console'da:

```
🌐 [14:30:15.123] REQUEST → POST poop_logs [createLog]
📱 [14:30:15.200] DEVICE REGISTERED: [UUID]
💾 [14:30:15.250] CACHE save → poop_logs (1 items)
✅ [14:30:15.456] RESPONSE ← poop_logs (1 items)
🔄 [14:30:15.500] SYNC create → poop_logs
ℹ️ [14:30:15.600] Log created successfully
```

---

## 🐛 DEBUG MODU

Debug modunda ekstra detaylar:

```
🔵 [14:30:15.123] SUPABASE → POST poop_logs
   URL: https://anonrgyqhgfursmhxrqo.supabase.co/rest/v1/poop_logs
✅ [14:30:15.456] SUPABASE ← poop_logs [200] (1 items)
```

---

## ⚙️ LOGGING'İ KAPATMAK İÇİN

Eğer loglar çok fazla geliyorsa:

```swift
BackendLogger.shared.disable()
```

Tekrar açmak için:

```swift
BackendLogger.shared.enable()
```

---

## 📊 SUPABASE DASHBOARD LOGLARI

Supabase'in kendi loglarını görmek için:

1. **Supabase Dashboard** → Projeni aç
2. **Logs** sekmesine git
3. **API Logs** veya **Database Logs** seç
4. Tüm istekleri ve SQL query'leri görürsün

---

## ✅ ÖZET

**EVET!** Xcode console'unda:
- ✅ Tüm Supabase istekleri
- ✅ Tüm network hataları
- ✅ Tüm sync işlemleri
- ✅ Tüm cache işlemleri
- ✅ Device işlemleri
- ✅ Detaylı hata mesajları

**HEPSİNİ GÖREBİLİRSİN!** 🎉

---

**Not:** Production'da logları kapatmak için `BackendLogger.shared.disable()` çağır.

