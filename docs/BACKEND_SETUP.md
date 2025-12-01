# 🚀 Backend Setup Rehberi - Supabase

Bu rehber PoopyPals backend'ini ayağa kaldırmak için adım adım talimatlar içerir.

## 📋 Adımlar

### 1. Supabase Projesi Oluştur

1. [supabase.com](https://supabase.com) adresine git
2. **Sign Up** veya **Sign In** yap
3. **New Project** butonuna tıkla
4. Proje bilgilerini gir:
   - **Name:** `poopypals` (veya istediğin isim)
   - **Database Password:** Güçlü bir şifre seç (kaydet!)
   - **Region:** En yakın bölgeyi seç
5. **Create new project** butonuna tıkla
6. Proje hazır olana kadar bekle (~2 dakika)

### 2. Supabase API Bilgilerini Al

1. Proje açıldıktan sonra sol menüden **Settings** (⚙️) seç
2. **API** sekmesine git
3. Şu bilgileri kopyala:
   - **Project URL:** `https://xxxxx.supabase.co`
   - **anon public key:** `eyJhbGc...` (uzun bir string)

### 3. Database Migration'ları Çalıştır

1. Supabase dashboard'da sol menüden **SQL Editor** seç
2. **New query** butonuna tıkla
3. `supabase/migrations/` klasöründeki dosyaları **sırayla** çalıştır:

#### Migration 1: Devices Table
```sql
-- 01_create_devices_table.sql dosyasının içeriğini kopyala-yapıştır
```
**Çalıştır** butonuna tıkla ✅

#### Migration 2: Poop Logs Table
```sql
-- 02_create_poop_logs_table.sql dosyasının içeriğini kopyala-yapıştır
```
**Çalıştır** butonuna tıkla ✅

#### Migration 3: Avatar Tables
```sql
-- 03_create_avatar_tables.sql dosyasının içeriğini kopyala-yapıştır
```
**Çalıştır** butonuna tıkla ✅

#### Migration 4: Achievements & Challenges
```sql
-- 04_create_achievements_challenges.sql dosyasının içeriğini kopyala-yapıştır
```
**Çalıştır** butonuna tıkla ✅

#### Migration 5: Helper Functions
```sql
-- 05_helper_functions.sql dosyasının içeriğini kopyala-yapıştır
```
**Çalıştır** butonuna tıkla ✅

### 4. iOS Projesine Supabase SDK Ekle

#### Xcode'da:

1. Xcode'da projeyi aç
2. **File > Add Package Dependencies...**
3. URL'yi gir: `https://github.com/supabase/supabase-swift`
4. **Add Package** tıkla
5. Versiyon seç: **Up to Next Major Version** → `2.0.0`
6. **Add Package** tıkla
7. **Supabase** paketini seç ve **Add Package** tıkla

### 5. Config.plist Oluştur

1. Proje root'unda `Config.plist.example` dosyasını kopyala
2. `Config.plist` olarak yeniden adlandır
3. İçeriğini düzenle:
   ```xml
   <key>SupabaseURL</key>
   <string>https://xxxxx.supabase.co</string>  <!-- Adım 2'den aldığın URL -->
   <key>SupabaseAnonKey</key>
   <string>eyJhbGc...</string>  <!-- Adım 2'den aldığın anon key -->
   ```
4. Xcode'da projeye ekle:
   - **File > Add Files to "poopypals"...**
   - `Config.plist` dosyasını seç
   - ✅ **Copy items if needed** işaretle
   - ✅ **poopypals** target'ını seç
   - **Add** tıkla

### 6. Test Et

1. Uygulamayı çalıştır (Cmd+R)
2. Console'da şu mesajları görmelisin:
   - `✅ Supabase connected successfully`
   - `✅ Device registered: [UUID]`

## ✅ Kontrol Listesi

- [ ] Supabase projesi oluşturuldu
- [ ] API bilgileri alındı (URL + anon key)
- [ ] 5 migration dosyası çalıştırıldı
- [ ] Supabase Swift SDK eklendi
- [ ] Config.plist oluşturuldu ve dolduruldu
- [ ] Uygulama başarıyla bağlandı

## 🐛 Sorun Giderme

### "Supabase configuration missing" hatası
- `Config.plist` dosyasının projeye eklendiğinden emin ol
- Xcode'da target membership kontrol et

### "Connection failed" hatası
- Supabase URL ve anon key'in doğru olduğunu kontrol et
- Supabase projesinin aktif olduğunu kontrol et
- Internet bağlantını kontrol et

### Migration hataları
- Migration'ları sırayla çalıştırdığından emin ol
- Her migration'dan sonra "Success" mesajını kontrol et
- Hata varsa, SQL Editor'deki hata mesajını oku

## 📚 Sonraki Adımlar

Backend hazır olduktan sonra:
1. Repository implementasyonlarını tamamla
2. Sync servisini implement et
3. Offline-first cache ekle

---

**Sorun mu var?** GitHub Issues'da soru sor veya dokümantasyona bak!

