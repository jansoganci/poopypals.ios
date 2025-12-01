# 🚀 Backend Quick Start

Backend'i ayağa kaldırmak için **5 dakikada** yapılacaklar:

## ✅ Hazır Olanlar

- ✅ SupabaseConfig.swift - Config yönetimi
- ✅ SupabaseService.swift - Ana Supabase servisi
- ✅ Migration dosyaları hazır
- ✅ Config.plist.example template

## 📝 Yapılacaklar (Sırayla!)

### 1️⃣ Supabase Projesi Oluştur (2 dk)
- [supabase.com](https://supabase.com) → New Project
- Proje adı: `poopypals`
- Region seç
- Database password kaydet!

### 2️⃣ API Bilgilerini Al (1 dk)
- Settings → API
- **Project URL** kopyala
- **anon public key** kopyala

### 3️⃣ Database Migration'ları Çalıştır (2 dk)
- SQL Editor → New query
- `supabase/migrations/` klasöründeki 5 dosyayı **sırayla** çalıştır:
  1. `01_create_devices_table.sql`
  2. `02_create_poop_logs_table.sql`
  3. `03_create_avatar_tables.sql`
  4. `04_create_achievements_challenges.sql`
  5. `05_helper_functions.sql`

### 4️⃣ Xcode'da Supabase SDK Ekle (1 dk)
- File → Add Package Dependencies
- URL: `https://github.com/supabase/supabase-swift`
- Version: `2.0.0`

### 5️⃣ Config.plist Oluştur (1 dk)
```bash
cp Config.plist.example Config.plist
```
- Xcode'da `Config.plist` dosyasını aç
- Supabase URL ve anon key'i yapıştır
- Xcode'da projeye ekle (File → Add Files)

## 🎉 Test Et

Uygulamayı çalıştır (Cmd+R). Console'da görmelisin:
```
✅ Supabase connected successfully
✅ Device registered: [UUID]
```

## 📚 Detaylı Rehber

Tam detaylar için: `docs/BACKEND_SETUP.md`

---

**Sorun mu var?** Hata mesajını kontrol et ve `docs/BACKEND_SETUP.md` dosyasındaki "Sorun Giderme" bölümüne bak!

