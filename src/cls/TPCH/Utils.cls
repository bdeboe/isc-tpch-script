Class TPCH.Utils
{

ClassMethod Load(path As %String = "", useIDKey As %Boolean = 1, schema As %String = "", verbose As %Boolean = 1) As %Status
{
	set sc = $$$OK
	try {
		set separator = $s($$$isWINDOWS:"\",1:"/")
		set:$e(path,*)'=separator path = path_separator

		set variables("schema") = $s(schema="":"", 1:schema_".")
		do ..RunDDL(path_"src"_separator_"sql"_separator_"drop-tables.sql", .variables, 1, 0)

		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"create-tables"_$s(useIDKey:"-id",1:"")_".sql", .variables)
		quit:$$$ISERR(sc)

		set variables("data_dir") = path_"data"_separator
		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"load-tables.sql", .variables)
		quit:$$$ISERR(sc)

		if useIDKey {
			set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"swap-keys.sql", .variables)
			quit:$$$ISERR(sc)
		}
		
		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"create-keys"_$s(useIDKey:"-id",1:"")_".sql", .variables)
		quit:$$$ISERR(sc)

		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"build-indices.sql", .variables)
		quit:$$$ISERR(sc)

	} catch (ex) {
		set sc = ex.AsStatus()
        write:verbose !,"Unexpected error: ",$system.Status.GetOneErrorText(sc)
	}
	write:verbose !
	quit sc
}

ClassMethod RunDDL(file As %String, ByRef replace As %String, ignoreErrors As %Boolean = 0, verbose As %Boolean = 1) As %Status
{
    set sc = $$$OK
    try {
        set sep = $s($$$isWINDOWS:"\",1:"/")
        
        write:verbose !,"Running DDL statements from file '",$piece(file,sep,*),"'"

        set stream = ##class(%Stream.FileCharacter).%New()
        set sc = stream.LinkToFile(file)
        quit:$$$ISERR(sc)

		set sql = ""

        while 'stream.AtEnd {
            set line = $zstrip(stream.ReadLine(),">WC")
            continue:line=""
            continue:$e(line,1,2)="--" // skip comment lines

			// somewhat blunt comment section skipping
			if $zstrip(line,"<WC") = "/*" {
				while 'stream.AtEnd {
					set line = $zstrip(stream.ReadLine(),"<>WC")
					quit:line="*/"
				}
				continue
			}

			// somewhat blunt statement termination
			if $zstrip(line,"<WC") = ";" {

				// replace constants
				set str = ""
				for {
					set str = $order(replace(str),1,rep)
					quit:str=""
					set sql = $replace(sql,"${"_str_"}",rep)
				}

				set sql = $zstrip(sql,"<>WC"), ts = $zh

				write:verbose !!,"  Executing statement:",!,sql
				set rs = ##class(%SQL.Statement).%ExecDirect(,sql)
				set sql = ""
				if rs.%SQLCODE {
					write:verbose !,"    FAILED: ",rs.%Message
					if 'ignoreErrors {
						set sc = $$$ERROR($$$GeneralError, "Error running statement: "_rs.%Message)
						quit
					}
				} else {
					write:verbose !,"    SUCCESS (",$normalize($zh-ts,3),"s)"
					write:verbose&&rs.%ROWCOUNT " - ",rs.%ROWCOUNT," rows affected"
				}
			} else {
				set sql = sql_$c(13,10)_line
			}

        }

		if $zstrip(sql,"<>WC")'="" {
			write:verbose !!,"leftover statement not executed: ",!,sql
		}
        
    } catch (ex) {
        set sc = ex.AsStatus()
        write:verbose !,"Unexpected error: ",$system.Status.GetOneErrorText(sc)
    }
	write:verbose !
    quit sc
}

}
