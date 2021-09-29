SELECT TOP 100 S_ACCTBAL, S_NAME, N_NAME, P_PARTKEY, P_MFGR, S_ADDRESS, S_PHONE, S_COMMENT FROM %PARALLEL PART, SUPPLIER, PARTSUPP, NATION, REGION WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY AND P_SIZE = 43 AND P_TYPE LIKE '%%NICKEL' AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND R_NAME = 'ASIA' AND PS_SUPPLYCOST = ( SELECT MIN(PS_SUPPLYCOST) FROM %PARALLEL PARTSUPP, SUPPLIER, NATION, REGION WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND R_NAME = 'ASIA') ORDER BY S_ACCTBAL DESC, N_NAME, S_NAME, P_PARTKEY
;
