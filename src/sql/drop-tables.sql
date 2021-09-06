DROP TABLE ${schema}NATION
;

DROP TABLE ${schema}REGION
;

DROP TABLE ${schema}PART
;

DROP TABLE ${schema}SUPPLIER
;

DROP TABLE ${schema}PARTSUPP
;

DROP TABLE ${schema}CUSTOMER
;

DROP TABLE ${schema}ORDERS
;

DROP TABLE ${schema}LINEITEM
;


-- purge SQL Loader logs

DELETE FROM %SQL_Diag.Message
;

DELETE FROM %SQL_Diag.Result
;