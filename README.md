# IoT Factory Management System

Web tabanlı IoT Fabrika Yönetim ve İzleme Sistemi.

## 📌 Proje Hakkında

Bu proje, fabrikalarda bulunan makineler ve bu makinelerden
veri toplayan sensörlerin merkezi bir sistem üzerinden
yönetilmesini ve izlenmesini amaçlamaktadır.

Sistem sayesinde;

- Fabrikalar ve üretim hatları yönetilebilecek,

- Makineler takip edilebilecek,

- Makinelere bağlı sensörler yönetilebilecek,

- Sensörlerden gelen ölçüm verileri saklanabilecek,

- Anormal ölçümler tespit edilebilecek,

- Alarmlar görüntülenebilecek,

- Makine bakım kayıtları tutulabilecek,

- Ölçüm ve makine verileri analiz edilebilecek,

- Veriler web arayüzü üzerinden kullanıcıya sunulabilecektir.

## 🎯 Projenin Amacı

IoT cihazlarından elde edilen endüstriyel verilerin
ilişkisel bir veritabanında saklanması, yönetilmesi ve
web arayüzü üzerinden kullanıcıya sunulması.

## 🗄️ Veritabanı

Projede en az 8 ilişkili tablo kullanılacaktır.

Planlanan tablolar:

- Factories
- Production Lines
- Machines
- Machine Types
- Sensors
- Sensor Types
- Measurements
- Maintenance Records
- Maintenance Types
- Alerts
- Users

## 📊 Gerçek Veri

Projede rastgele oluşturulmuş örnek veriler yerine,
gerçek bir IoT/endüstriyel veri seti kullanılacaktır.

Kullanılacak veri seti ve kaynağı proje geliştirme
sürecinde README dosyasına eklenecektir.

## 🌐 Teknolojiler

### Backend
- Python 

### Frontend
- HTML
- CSS

### Database
- Microsoft SQL Server

### Version Control
- Git
- GitHub

## 📁 Proje Yapısı

```text
iot-factory-management-system/
│
├── backend/        # Python backend
├── frontend/       # Web arayüzü
├── database/       # SQL Server dosyaları
├── docs/           # Proje dokümantasyonu
│
├── .gitignore
└── README.md
```