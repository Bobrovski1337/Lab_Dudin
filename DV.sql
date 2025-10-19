-- Создание схемы для Data Vault модели
CREATE SCHEMA supply_dv;
SET search_path TO supply_dv;

-- 1. ХАБЫ (Hubs)
CREATE TABLE hub_kiosk (
    kiosk_id_hash VARCHAR(64) PRIMARY KEY,
    kiosk_id INTEGER NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

COMMENT ON TABLE hub_kiosk IS 'Хаб киосков - уникальные бизнес-ключи торговых точек';
COMMENT ON COLUMN hub_kiosk.kiosk_id_hash IS 'Хэш от бизнес-ключа киоска (технический PK)';
COMMENT ON COLUMN hub_kiosk.kiosk_id IS 'Оригинальный идентификатор киоска (бизнес-ключ)';

CREATE TABLE hub_supplier (
    supplier_id_hash VARCHAR(64) PRIMARY KEY,
    supplier_id INTEGER NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

COMMENT ON TABLE hub_supplier IS 'Хаб поставщиков - уникальные бизнес-ключи поставщиков';

CREATE TABLE hub_product (
    product_id_hash VARCHAR(64) PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

COMMENT ON TABLE hub_product IS 'Хаб товаров - уникальные бизнес-ключи товаров';

CREATE TABLE hub_delivery (
    delivery_id_hash VARCHAR(64) PRIMARY KEY,
    delivery_id INTEGER NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

COMMENT ON TABLE hub_delivery IS 'Хаб поставок - уникальные бизнес-ключи поставок';

-- 2. СВЯЗИ (Links)
CREATE TABLE link_delivery (
    delivery_hash VARCHAR(64) PRIMARY KEY,
    delivery_id_hash VARCHAR(64) NOT NULL,
    supplier_id_hash VARCHAR(64) NOT NULL,
    kiosk_id_hash VARCHAR(64) NOT NULL,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL,
    
    CONSTRAINT fk_link_delivery_hub_delivery 
        FOREIGN KEY (delivery_id_hash) REFERENCES hub_delivery(delivery_id_hash),
    CONSTRAINT fk_link_delivery_hub_supplier 
        FOREIGN KEY (supplier_id_hash) REFERENCES hub_supplier(supplier_id_hash),
    CONSTRAINT fk_link_delivery_hub_kiosk 
        FOREIGN KEY (kiosk_id_hash) REFERENCES hub_kiosk(kiosk_id_hash)
);

COMMENT ON TABLE link_delivery IS 'Связь между поставкой, поставщиком и киоском';
COMMENT ON COLUMN link_delivery.delivery_hash IS 'Уникальный хэш связи (delivery_id_hash + supplier_id_hash + kiosk_id_hash)';

CREATE TABLE link_delivery_item (
    delivery_item_hash VARCHAR(64) PRIMARY KEY,
    delivery_id_hash VARCHAR(64) NOT NULL,
    product_id_hash VARCHAR(64) NOT NULL,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL,
    
    CONSTRAINT fk_link_delivery_item_hub_delivery 
        FOREIGN KEY (delivery_id_hash) REFERENCES hub_delivery(delivery_id_hash),
    CONSTRAINT fk_link_delivery_item_hub_product 
        FOREIGN KEY (product_id_hash) REFERENCES hub_product(product_id_hash)
);

COMMENT ON TABLE link_delivery_item IS 'Связь между поставкой и товаром';

-- 3. СПУТНИКИ (Satellites)
CREATE TABLE sat_kiosk_details (
    kiosk_id_hash VARCHAR(64) NOT NULL,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    kiosk_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    manager_name VARCHAR(100),
    phone_number VARCHAR(20),
    record_source VARCHAR(50) NOT NULL,
    
    PRIMARY KEY (kiosk_id_hash, load_dts),
    CONSTRAINT fk_sat_kiosk_hub_kiosk 
        FOREIGN KEY (kiosk_id_hash) REFERENCES hub_kiosk(kiosk_id_hash)
);

COMMENT ON TABLE sat_kiosk_details IS 'Спутник с детальной информацией о киоске (историчность)';

CREATE TABLE sat_supplier_details (
    supplier_id_hash VARCHAR(64) NOT NULL,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    supplier_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    record_source VARCHAR(50) NOT NULL,
    
    PRIMARY KEY (supplier_id_hash, load_dts),
    CONSTRAINT fk_sat_supplier_hub_supplier 
        FOREIGN KEY (supplier_id_hash) REFERENCES hub_supplier(supplier_id_hash)
);

COMMENT ON TABLE sat_supplier_details IS 'Спутник с детальной информацией о поставщике (историчность)';

CREATE TABLE sat_product_details (
    product_id_hash VARCHAR(64) NOT NULL,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    
    PRIMARY KEY (product_id_hash, load_dts),
    CONSTRAINT fk_sat_product_hub_product 
        FOREIGN KEY (product_id_hash) REFERENCES hub_product(product_id_hash)
);

COMMENT ON TABLE sat_product_details IS 'Спутник с детальной информацией о товаре (историчность)';

CREATE TABLE sat_delivery_details (
    delivery_id_hash VARCHAR(64) NOT NULL,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_date DATE NOT NULL,
    delivery_status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    
    PRIMARY KEY (delivery_id_hash, load_dts),
    CONSTRAINT fk_sat_delivery_hub_delivery 
        FOREIGN KEY (delivery_id_hash) REFERENCES hub_delivery(delivery_id_hash)
);

COMMENT ON TABLE sat_delivery_details IS 'Спутник с детальной информацией о поставке (историчность)';

CREATE TABLE sat_delivery_item_details (
    delivery_item_hash VARCHAR(64) NOT NULL,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quantity INTEGER NOT NULL,
    unit_cost NUMERIC(10,2) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    
    PRIMARY KEY (delivery_item_hash, load_dts),
    CONSTRAINT fk_sat_delivery_item_link_delivery_item 
        FOREIGN KEY (delivery_item_hash) REFERENCES link_delivery_item(delivery_item_hash)
);

COMMENT ON TABLE sat_delivery_item_details IS 'Спутник с количественными показателями позиции поставки';