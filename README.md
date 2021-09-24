# IRIS TPC-H setup script

Scripts for loading TPC-H data into IRIS.

Presumes you have run the `dbgen` utility provided with TPC-H (available from the utilities section [here](http://tpc.org/tpc_documents_current_versions/current_specifications5.asp)) and copied the resulting `.tbl` files into a `data/` folder in this repository's file location.

```ObjectScript
do ##class(TPCH.Utils).Load("/path/to/isc-tpch-script/")
```

or from SQL:
```SQL
CALL TPCH.Load('/path/to/isc-tpch-script/')
```

By default, this will create the TPC-H tables in the current default schema (which is `SQLUser` if you didn't set anything) in the current namespace / database. You can override thes using the `schema` and `database` arguments respectively. Full signature of the `Load()` method:

```ObjectScript
ClassMethod Load(path As %String = "", useIDKey As %Boolean = 1, database As %String = "", schema As %String = "", verbose As %Boolean = 1) As %Status [ SqlProc, SqlName = Load ]
```
