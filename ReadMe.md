# Laboratory Work: Supply System

## 3NF Model Implementation

```sql
-- Таблица киосков
CREATE TABLE kiosks (
    kiosk_id SERIAL PRIMARY KEY,
    kiosk_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    manager_name VARCHAR(100),
    phone_number VARCHAR(20)
);
```

## Data Vault Model Implementation

```sql
-- Хабы
CREATE TABLE hub_kiosk (
    kiosk_id_hash VARCHAR(64) PRIMARY KEY,
    kiosk_id INTEGER NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);
```