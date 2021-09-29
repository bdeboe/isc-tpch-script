SELECT N_NAME, SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)) AS REVENUE FROM %PARALLEL CUSTOMER, ORDERS, LINEITEM, SUPPLIER, NATION, REGION WHERE C_CUSTKEY = O_CUSTKEY AND L_ORDERKEY = O_ORDERKEY AND L_SUPPKEY = S_SUPPKEY AND C_NATIONKEY = S_NATIONKEY AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND R_NAME = 'MIDDLE EAST' AND O_ORDERDATE >= '1993-01-01' AND O_ORDERDATE < DATEADD(YY, 1, cast ('1993-01-01'as date)) GROUP BY N_NAME ORDER BY REVENUE DESC
;
