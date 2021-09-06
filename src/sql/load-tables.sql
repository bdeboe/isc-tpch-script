LOAD DATA FROM FILE '${data_dir}nation.tbl'
	INTO ${schema}NATION
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;

LOAD DATA FROM FILE '${data_dir}region.tbl'
	INTO ${schema}REGION
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;

LOAD DATA FROM FILE '${data_dir}part.tbl'
	INTO ${schema}PART
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;

LOAD DATA FROM FILE '${data_dir}supplier.tbl'
	INTO ${schema}SUPPLIER
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;

LOAD DATA FROM FILE '${data_dir}partsupp.tbl'
	INTO ${schema}PARTSUPP
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;

LOAD DATA FROM FILE '${data_dir}customer.tbl'
	INTO ${schema}CUSTOMER
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;

LOAD DATA FROM FILE '${data_dir}orders.tbl'
	INTO ${schema}ORDERS
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;

LOAD DATA FROM FILE '${data_dir}lineitem.tbl'
	INTO ${schema}LINEITEM
	USING '{ "from": {"file": {"columnseparator":"|"} } }'
;