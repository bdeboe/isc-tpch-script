SELECT S_NAME, S_ADDRESS FROM %PARALLEL SUPPLIER, NATION WHERE S_SUPPKEY IN ( SELECT PS_SUPPKEY FROM %PARALLEL PARTSUPP WHERE PS_PARTKEY in ( SELECT P_PARTKEY FROM %PARALLEL PART WHERE P_NAME like 'chiffon%%') AND PS_AVAILQTY > ( SELECT 0.5 * sum(L_QUANTITY) FROM %PARALLEL LINEITEM WHERE L_PARTKEY = PS_PARTKEY AND L_SUPPKEY = PS_SUPPKEY AND L_SHIPDATE >= '1993-01-01' AND L_SHIPDATE < dateadd(yy,1,cast('1993-01-01' as date)))) AND S_NATIONKEY = N_NATIONKEY AND N_NAME = 'KENYA' ORDER BY S_NAME 
;