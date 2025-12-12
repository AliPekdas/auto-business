# Auto Business

**Auto Business**; araç satış, stok takibi, finansal raporlama ve müşteri yönetimini tek bir platformda toplayan web tabanlı bir otomasyon sistemidir. Bu proje, işletmenin veritabanı ile etkileşime girerek satış işlemlerini hızlandırır ve dinamik veri yönetimini (CRUD) kolaylaştırır.

## Özellikler

Uygulama aşağıdaki temel modülleri içermektedir:

* **Hızlı Satış Ekranı:** Müşteri ve Ürün ID girerek satış yapma, stoğu otomatik düşme ve işlem kaydı oluşturma.
* **Stok Yönetimi:**
    * **Manuel Stok Ekleme:** Faturasız stok girişleri veya sayım farkları için manuel güncelleme.
    * **Fiyat Güncelleme:** Belirli bir ürüne yüzde bazında zam veya indirim uygulama.
* **Araç & Müşteri Hizmetleri:**
    * **Garaj Sorgulama:** Müşteri ismine göre kayıtlı araçları, plakayı ve model yılını listeleme.
    * **Eski Araç Temizliği:** Belirlenen bir yıldan eski araç kayıtlarını veritabanından toplu olarak silme.
* **Finansal Raporlama:** İki tarih arasındaki toplam geliri (ciroyu) hesaplama ve görüntüleme.
* **Veri Yönetimi (CRUD):** Müşteri ve Ürün gibi tablolar için dinamik ekleme, silme, güncelleme ve listeleme arayüzü.
* **Kurumsal Bilgiler:** Şirket bilgilerini (Adres, Vergi No vb.) veritabanından dinamik olarak çekme.

## Kullanılan Teknolojiler

* **Frontend:** HTML5, CSS3, Vanilla JavaScript (ES6+).
* **Backend:** Node.js, Express.js.
* **Veritabanı:** Microsoft SQL Server (MSSQL).
* **Kütüphaneler:** `express`, `cors`, `mssql`.
