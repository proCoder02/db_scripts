
CREATE TABLE IF NOT EXISTS currencies (
    code CHAR(3) NOT NULL PRIMARY KEY,
    name VARCHAR(320) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(320) NOT NULL,
    phone VARCHAR(32) NOT NULL,
    email VARCHAR(320) NOT NULL,
    currency CHAR(3) NOT NULL,
    address1 VARCHAR(255) NOT NULL,
    address2 VARCHAR(255),
    city VARCHAR(255) NOT NULL,
    postal_code VARCHAR(12) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (currency) REFERENCES currencies (id) ON DELETE RESTRICT
);



CREATE TABLE IF NOT EXISTS products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products_pricing (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    price INT NOT NULL,
    currency CHAR(3) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (currency) REFERENCES currencies (code),
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    CONSTRAINT unique_price_in_interval UNIQUE (product_id, currency, from_date, to_date, deleted_at)
);





CREATE TABLE IF NOT EXISTS products_pricing ( 
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
product_id BIGINT NOT NULL, 
from_date DATE NOT NULL, 
to_date DATE NOT NULL, 
price INT NOT NULL, 
currency CHAR(3) NOT NULL, 
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
deleted_at TIMESTAMP );



CREATE TABLE IF NOT EXISTS plans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    billing_interval INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS invoices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    status ENUM('draft', 'unpaid', 'paid') NOT NULL DEFAULT 'unpaid',
    invoice_number INT NOT NULL AUTO_INCREMENT,
    customer_id BIGINT NOT NULL,
    email VARCHAR(320) NOT NULL,
    name VARCHAR(320) NOT NULL,
    country CHAR(2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    address1 VARCHAR(255) NOT NULL,
    address2 VARCHAR(255),
    city VARCHAR(255) NOT NULL,
    postal_code VARCHAR(12) NOT NULL,
    phone VARCHAR(24),
    invoice_date TIMESTAMP NOT NULL,
    due_date TIMESTAMP NOT NULL,
    paid_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE (invoice_number),
    FOREIGN KEY (currency) REFERENCES currencies (code),
    FOREIGN KEY (customer_id) REFERENCES customers (id)
);

CREATE TABLE IF NOT EXISTS invoice_line_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    product_id BIGINT NOT NULL,
    line_amount INT NOT NULL DEFAULT 0,
    vat_amount INT NOT NULL DEFAULT 0,
    vat_percentage INT NOT NULL DEFAULT 0,
    unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
    quantity DECIMAL(12,2) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,\
    FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    status ENUM('inactive', 'active', 'upgraded') NOT NULL,
    customer_id BIGINT NOT NULL,
    plan_id BIGINT NOT NULL,
    invoice_id BIGINT NOT NULL,
    starts_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ends_at TIMESTAMP,
    renewed_at TIMESTAMP,
    renewed_subscription_id BIGINT,
    downgraded_at TIMESTAMP,
    downgraded_to_plan_id BIGINT,
    upgraded_at TIMESTAMP,
    upgraded_to_plan_id BIGINT,
    cancelled_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (downgraded_to_plan_id) REFERENCES plans (id),
    FOREIGN KEY (invoice_id) REFERENCES invoices (id),
    FOREIGN KEY (customer_id) REFERENCES customers (id),
    FOREIGN KEY (plan_id) REFERENCES plans (id),
    FOREIGN KEY (renewed_subscription_id) REFERENCES subscriptions (id),
    FOREIGN KEY (upgraded_to_plan_id) REFERENCES plans (id),
    UNIQUE INDEX unique_subscription_in_interval (customer_id, starts_at, ends_at) WHERE (deleted_at IS NULL AND status = 'active')
);

