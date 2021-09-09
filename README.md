# IRIS TPC-H setup script

Scripts for loading TPC-H data into IRIS.

Presumes you have run the `dbgen` utility provided with TPC-H (available [here](https://github.com/dragansah/tpch-dbgen)) and copied the resulting `.tbl` files into a `data/` folder in this repository's file location.

```ObjectScript
do ##class(TPCH.Utils).Load("/path/to/isc-tpch-script/")
```
