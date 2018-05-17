CREATE TABLE stocks (
   symbol VARCHAR(10) not null,
   price_date DATE not NULL,
   open_price DOUBLE not NULL,
   high_price DOUBLE not NULL,
   low_price DOUBLE not NULL,
   close_price DOUBLE not NULL,
   adjusted_close DOUBLE not NULL,
   volume BIGINT not null
);