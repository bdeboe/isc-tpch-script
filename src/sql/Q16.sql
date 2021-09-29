SELECT P_BRAND, P_TYPE, P_SIZE, COUNT(DISTINCT PS_SUPPKEY) AS SUPPLIER_CNT FROM %PARALLEL PARTSUPP, PART WHERE P_PARTKEY = PS_PARTKEY AND P_BRAND <> 'Brand#43' AND P_TYPE NOT LIKE 'STANDARD PLATED%%' AND P_SIZE IN (42, 8, 34, 29, 48, 9, 15, 21) AND PS_SUPPKEY NOT IN ( SELECT S_SUPPKEY FROM %PARALLEL SUPPLIER WHERE S_COMMENT LIKE '%%Customer%%Complaints%%') GROUP BY P_BRAND, P_TYPE, P_SIZE ORDER BY SUPPLIER_CNT DESC, P_BRAND, P_TYPE, P_SIZE
;
