# ⚡ Config.plist Xcode'a Ekleme (30 SANİYE)

## 🚨 SORUN
Config.plist dosyası var ama Xcode bundle'ına eklenmemiş.

## ✅ HIZLI ÇÖZÜM (Xcode'da)

### Adım 1: Xcode'u Aç
- `poopypals.xcodeproj` dosyasını aç

### Adım 2: Config.plist'i Ekle
1. **Sol panelde** `poopypals` projesine **sağ tık**
2. **Add Files to "poopypals"...**
3. **Config.plist** dosyasını seç
4. ✅ **Copy items if needed** işaretle
5. ✅ **poopypals** target'ını seç
6. **Add** tıkla

### Adım 3: Kontrol Et
- Sol panelde `Config.plist` görünmeli
- Target membership'te `poopypals` işaretli olmalı

### Adım 4: Build & Run
- **Cmd+R** ile çalıştır
- ✅ Artık çalışacak!

---

## 🔄 ALTERNATİF: Fallback Path (Geçici)

Eğer Xcode'da eklemek istemiyorsan, kod zaten fallback path'i deniyor. Ama **önerilen çözüm Xcode'a eklemek**.

---

**Not:** Config.plist `.gitignore`'da olduğu için git'e commit edilmeyecek (güvenlik için).

