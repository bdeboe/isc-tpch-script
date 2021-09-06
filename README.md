# IRIS TPC-H setup script

Scripts for loading TPC-H data into IRIS.

Presumes you have run the `dbgen` utility provided with TPC-H and copied the resulting `.tbl` files into a `data/` folder in this reposotories file location.

```ObjectScript
do ##class(TPCH.Utils).Load("/path/to/isc-tpch-script/")
```