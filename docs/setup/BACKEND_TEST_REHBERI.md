# 🔍 BACKEND TEST REHBERİ

## ⚠️ ÖNEMLİ: Backend Henüz Kurulmamış!

Şu anda backend'e bağlanmak için **Supabase projesi** ve **Config.plist** dosyası gerekiyor.

---

## 📋 ADIM 1: Supabase Projesi Oluştur

1. **https://supabase.com** adresine git
2. **Sign Up** veya **Sign In** yap
3. **New Project** butonuna tıkla
4. Proje bilgilerini gir:
   - **Name:** `poopypals` (veya istediğin isim)
   - **Database Password:** Güçlü bir şifre seç (kaydet!)
   - **Region:** En yakın bölgeyi seç (örn: `West Europe`)
5. **Create new project** tıkla
6. Proje hazır olana kadar bekle (~2 dakika)

---

## 📋 ADIM 2: API Bilgilerini Al

1. Supabase dashboard'da sol menüden **Settings** (⚙️) seç
2. **API** sekmesine git
3. Şu bilgileri kopyala:
   - **Project URL:** `https://xxxxx.supabase.co`
   - **anon public key:** `eyJhbGc...` (uzun bir string)

---

## 📋 ADIM 3: Config.plist Oluştur

1. Proje root'unda `Config.plist.example` dosyasını kopyala:
   ```bash
   cp Config.plist.example Config.plist
   ```

2. `Config.plist` dosyasını aç ve doldur:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>SupabaseURL</key>
       <string>https://xxxxx.supabase.co</string>  <!-- ADIM 2'den aldığın URL -->
       <key>SupabaseAnonKey</key>
       <string>eyJhbGc...</string>  <!-- ADIM 2'den aldığın anon key -->
   </dict>
   </plist>
   ```

3. Xcode'da projeye ekle:
   - **File > Add Files to "poopypals"...**
   - `Config.plist` dosyasını seç
   - ✅ **Copy items if needed** işaretle
   - ✅ **poopypals** target'ını seç
   - **Add** tıkla

---

## 📋 ADIM 4: Database Migration'ları Çalıştır

1. Supabase dashboard'da sol menüden **SQL Editor** seç
2. **New query** butonuna tıkla
3. `supabase/migrations/` klasöründeki dosyaları **sırayla** çalıştır:

### Migration 1: Devices Table
```sql
-- 01_create_devices_table.sql dosyasının içeriğini kopyala-yapıştır
```
**Run** butonuna tıkla ✅

### Migration 2: Poop Logs Table
```sql
-- 02_create_poop_logs_table.sql dosyasının içeriğini kopyala-yapıştır
```
**Run** butonuna tıkla ✅

### Migration 3: Avatar Tables
```sql
-- 03_create_avatar_tables.sql dosyasının içeriğini kopyala-yapıştır
```
**Run** butonuna tıkla ✅

### Migration 4: Achievements & Challenges
```sql
-- 04_create_achievements_challenges.sql dosyasının içeriğini kopyala-yapıştır
```
**Run** butonuna tıkla ✅

### Migration 5: Helper Functions
```sql
-- 05_helper_functions.sql dosyasının içeriğini kopyala-yapıştır
```
**Run** butonuna tıkla ✅

---

## 📋 ADIM 5: Backend'i Test Et

### Yöntem 1: Uygulamayı Çalıştır (Otomatik Test)

1. Xcode'da uygulamayı çalıştır (Cmd+R)
2. Xcode console'unda şu çıktıları görmelisin:

```
🔍 BACKEND CONNECTION TEST
==================================================

1️⃣ Checking Supabase Config...
   ✅ Project URL: https://xxxxx.supabase.co
   ✅ Anon Key: eyJhbGc...

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

### Yöntem 2: Manuel Test (Kod ile)

Swift kodunda:
```swift
Task {
    await BackendTester.shared.testConnection()
}
```

---

## 🐛 SORUN GİDERME

### ❌ "Supabase configuration missing" hatası
**Çözüm:**
- `Config.plist` dosyasının projeye eklendiğinden emin ol
- Xcode'da target membership kontrol et
- Dosya path'i doğru mu kontrol et

### ❌ "Connection failed" hatası
**Çözüm:**
- Supabase URL ve anon key'in doğru olduğunu kontrol et
- Supabase projesinin aktif olduğunu kontrol et (dashboard'da)
- Internet bağlantını kontrol et
- Supabase projesinin pause edilmediğinden emin ol

### ❌ "Table 'xxx' error" hatası
**Çözüm:**
- Migration'ları sırayla çalıştırdığından emin ol
- Her migration'dan sonra "Success" mesajını kontrol et
- SQL Editor'deki hata mesajını oku

### ❌ "Device registration failed" hatası
**Çözüm:**
- `devices` tablosunun oluşturulduğundan emin ol
- Migration 1'i tekrar çalıştır
- Supabase RLS policies'in doğru olduğunu kontrol et

---

## ✅ BAŞARILI TEST ÇIKTISI

Eğer her şey doğruysa, console'da şunu göreceksin:

```
✅ Supabase connected successfully
✅ Device registered: [UUID]
✅ Table 'devices' accessible
✅ Table 'poop_logs' accessible
✅ Table 'achievements' accessible
```

---

## 📊 BACKEND DURUMU KONTROL

Backend durumunu görmek için:

```swift
let status = BackendTester.shared.getStatus()
print(status)
```

Çıktı:
```
📊 BACKEND STATUS
==============================
✅ Config: Loaded
   URL: https://xxxxx.supabase.co
✅ Connection: Active
```

---

## 🎯 SONRAKI ADIMLAR

Backend bağlantısı başarılı olduktan sonra:

1. ✅ Uygulama verileri Supabase'e kaydedecek
2. ✅ Offline-first çalışacak (local cache)
3. ✅ Background sync çalışacak (5 dakikada bir)
4. ✅ Device-based authentication çalışacak

---

**Sorun mu var?** Console çıktılarını kontrol et ve hata mesajlarını oku!

