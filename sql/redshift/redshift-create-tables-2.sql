CREATE TABLE region
(
	R_REGIONKEY BIGINT NOT NULL,
	R_NAME VARCHAR(25) NOT NULL,
	R_COMMENT VARCHAR(152),
	PRIMARY KEY (R_REGIONKEY)
);


CREATE TABLE nation
(
	N_NATIONKEY BIGINT NOT NULL,
	N_NAME VARCHAR(25) NOT NULL,
	N_REGIONKEY BIGINT NOT NULL,
	N_COMMENT VARCHAR(152),
	PRIMARY KEY (N_NATIONKEY),
	FOREIGN KEY (N_REGIONKEY) REFERENCES region(R_REGIONKEY)
);

CREATE TABLE part
(
	P_PARTKEY BIGINT NOT NULL,
	P_NAME VARCHAR(55) NOT NULL,
	P_MFGR VARCHAR(25) NOT NULL,
	P_BRAND VARCHAR(10) NOT NULL,
	P_TYPE VARCHAR(25) NOT NULL,
	P_SIZE INTEGER NOT NULL,
	P_CONTAINER VARCHAR(10) NOT NULL,
	P_RETAILPRICE NUMERIC(12, 2) NOT NULL,
	P_COMMENT VARCHAR(23),
	PRIMARY KEY (P_PARTKEY)
);

CREATE TABLE supplier
(
	S_SUPPKEY BIGINT NOT NULL,
	S_NAME VARCHAR(25) NOT NULL,
	S_ADDRESS VARCHAR(40) NOT NULL,
	S_NATIONKEY BIGINT NOT NULL,
	S_PHONE VARCHAR(15) NOT NULL,
	S_ACCTBAL NUMERIC(12, 2) NOT NULL,
	S_COMMENT VARCHAR(101),
	PRIMARY KEY (S_SUPPKEY),
	FOREIGN KEY (S_NATIONKEY) REFERENCES nation(N_NATIONKEY)
);

CREATE TABLE customer
(
	C_CUSTKEY BIGINT NOT NULL,
	C_NAME VARCHAR(25) NOT NULL,
	C_ADDRESS VARCHAR(40) NOT NULL,
	C_NATIONKEY BIGINT NOT NULL,
	C_PHONE VARCHAR(15) NOT NULL,
	C_ACCTBAL NUMERIC(12, 2) NOT NULL,
	C_MKTSEGMENT VARCHAR(10) NOT NULL,
	C_COMMENT VARCHAR(117),
	PRIMARY KEY (C_CUSTKEY),
	FOREIGN KEY (C_NATIONKEY) REFERENCES nation(N_NATIONKEY)
);

CREATE TABLE partsupp
(
	PS_PARTKEY BIGINT NOT NULL,
	PS_SUPPKEY BIGINT NOT NULL,
	PS_AVAILQTY INTEGER NOT NULL,
	PS_SUPPLYCOST NUMERIC(12, 2) NOT NULL,
	PS_COMMENT VARCHAR(199),
	PRIMARY KEY (PS_PARTKEY, PS_SUPPKEY),
	FOREIGN KEY (PS_PARTKEY) REFERENCES part(P_PARTKEY),
	FOREIGN KEY (PS_SUPPKEY) REFERENCES supplier(S_SUPPKEY)
);

CREATE TABLE orders
(
	o_orderkey BIGINT NOT NULL,
	o_custkey BIGINT NOT NULL,
	o_orderstatus VARCHAR(1) NOT NULL,
	o_totalprice NUMERIC(12, 2) NOT NULL,
	o_orderdate DATE NOT NULL SORTKEY,
	o_orderpriority VARCHAR(15) NOT NULL,
	o_clerk VARCHAR(15) NOT NULL,
	o_shippriority INTEGER NOT NULL,
	o_comment VARCHAR(79),
	PRIMARY KEY (o_orderkey),
	FOREIGN KEY (o_custkey) REFERENCES customer(C_CUSTKEY)
);


CREATE TABLE lineitem
(
	l_orderkey BIGINT NOT NULL,
	l_partkey BIGINT NOT NULL,
	l_suppkey INTEGER NOT NULL,
	l_linenumber INTEGER NOT NULL,
	l_quantity NUMERIC(12, 2) NOT NULL,
	l_extendedprice NUMERIC(12, 2) NOT NULL,
	l_discount NUMERIC(12, 2) NOT NULL,
	l_tax NUMERIC(12, 2) NOT NULL,
	l_returnflag VARCHAR(1) NOT NULL,
	l_linestatus VARCHAR(1) NOT NULL,
	l_shipdate DATE NOT NULL SORTKEY,
	l_commitdate DATE NOT NULL,
	l_receiptdate DATE NOT NULL,
	l_shipinstruct VARCHAR(25) NOT NULL,
	l_shipmode VARCHAR(10) NOT NULL,
	l_comment VARCHAR(44),
	PRIMARY KEY (l_orderkey, l_linenumber),
	FOREIGN KEY (l_orderkey) REFERENCES orders(o_orderkey),
	FOREIGN KEY (l_partkey) REFERENCES part(P_PARTKEY),
	FOREIGN KEY (l_suppkey) REFERENCES supplier(S_SUPPKEY)
);
