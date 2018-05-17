CREATE TABLE stocks (
   symbol VARCHAR(10) not null,
   price_date DATE not NULL,
   open_price NUMERIC(12, 6) not NULL,
   high_price NUMERIC(12, 6) not NULL,
   low_price NUMERIC(12, 6) not NULL,
   close_price NUMERIC(12, 6) not NULL,
   adjusted_close NUMERIC(12, 6) not NULL,
   volume BIGINT not null
);