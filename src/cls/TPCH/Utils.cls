Class TPCH.Utils
{

ClassMethod Load(path As %String = "", useIDKey As %Boolean = 0, database As %String = "", schema As %String = "", verbose As %Boolean = 1) As %Status [ SqlName = Load, SqlProc ]
{
	set sc = $$$OK
	try {
		set separator = $s($$$isWINDOWS:"\",1:"/")
		set:$e(path,*)'=separator path = path_separator

		// create a new database if requested
		if (database'="") {
			set variables("database") = database
			do ..RunDDL(path_"src"_separator_"sql"_separator_"create-db.sql", .variables, 1, 1)
		}

		set t1 = $zh

		set variables("schema") = $s(schema="":"", 1:schema_".")
		do ..RunDDL(path_"src"_separator_"sql"_separator_"drop-tables.sql", .variables, 1, 0)

		set t2 = $zh, t($i(t)) = "Dropping existing tables: "_$fn(t2-t1,,2)_"s"

		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"create-tables"_$s(useIDKey:"-id",1:"")_".sql", .variables)
		quit:$$$ISERR(sc)
		
		set t3 = $zh, t($i(t)) = "Creating new tables: "_$fn(t3-t2,,2)_"s"

		set variables("data_dir") = path_"data"_separator
		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"load-tables.sql", .variables)
		quit:$$$ISERR(sc)
		
		set (t4,t5) = $zh, t($i(t)) = "Loading data: "_$fn(t4-t3,,2)_"s"

		if useIDKey {
			set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"swap-keys.sql", .variables)
			quit:$$$ISERR(sc)
			set t5 = $zh, t($i(t)) = "Transforming foreign keys: "_$fn(t5-t4,,2)_"s"
		}
		
		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"create-keys"_$s(useIDKey:"-id",1:"")_".sql", .variables)
		quit:$$$ISERR(sc)

		set sc = ..RunDDL(path_"src"_separator_"sql"_separator_"create-indices.sql", .variables)
		quit:$$$ISERR(sc)
		
		set t6 = $zh, t($i(t)) = "Building indices: "_$fn(t6-t5,,2)_"s"

		if verbose {
			w !!,"Total time spent: "_$fn(t6-t1,,2)_"s"
			for i = 1:1:t {
				w !,"  - ",t(i)
			}
		}

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
        
        write:verbose !,"Running SQL statements from file '",$piece(file,sep,*),"'"

        set stream = ##class(%Stream.FileCharacter).%New()
        set sc = stream.LinkToFile(file)
        quit:$$$ISERR(sc)

		set statement = ##class(%SQL.Statement).%New()
		set statement.%SelectMode = 1
        set sql = 1
        set sql(1) = ""
        

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
					set sql(1) = $replace(sql(1),"${"_str_"}",rep)
				}

				set sql(1) = $zstrip(sql(1),"<>WC"), ts = $zh

				write:verbose !!,"  Preparing statement:",!,sql(1)
				set sc = statement.%Prepare(.sql)
        		if ($System.Status.IsError(sc)) 
        		{
            		write $System.Status.GetErrorText(sc),!
            		write "Prepare failed. Exiting",!
            		Return 0
        		}

				write:verbose !!,"  Executing statement:",!,sql(1)
				set rs = statement.%Execute()
				write:verbose !,"    CODE 1: ",rs.%SQLCODE
				if (rs.%SQLCODE'=0) & (rs.%SQLCODE'=100) & (rs.%SQLCODE'=-30) {
					write:verbose !,"    FAILED: ",rs.%Message
					write:verbose !,"    CODE: 2 ",rs.%SQLCODE
					if 'ignoreErrors {
						set sc = $$$ERROR($$$GeneralError, "Error running statement: "_rs.%Message)
						Return 0
					}
				} else {
					write:verbose&&rs.%ROWCOUNT " - ",rs.%ROWCOUNT," rows affected"
					write:verbose !
				}
				do rs.%Display()
				write:verbose !,"    CODE 3: ",rs.%SQLCODE
				if (rs.%SQLCODE'=0) & (rs.%SQLCODE'=100) & (rs.%SQLCODE'=-30) {
					write:verbose !,"    FAILED: ",rs.%Message
					write:verbose !,"    CODE: 4 ",rs.%SQLCODE
					if 'ignoreErrors {
						set sc = $$$ERROR($$$GeneralError, "Error displaying statement: "_rs.%Message)
						Return 0
					}
				} else {
					write:verbose !,"    SUCCESS (",$normalize($zh-ts,3),"s)"
					write:verbose&&rs.%ROWCOUNT " - ",rs.%ROWCOUNT," rows affected"
					write:verbose !
				}

				set sql(1) = ""

			} else {
				; this is adding CR LF 
				set sql(1) = sql(1)_$c(13,10)_line
			}

        }

		if $zstrip(sql(1),"<>WC")'="" {
			write:verbose !!,"leftover statement not executed: ",!,sql(1)
		}
        
    } catch (ex) {
        set sc = ex.AsStatus()
        write:verbose !,"Unexpected error: ",$system.Status.GetOneErrorText(sc)
    }
	write:verbose !
    quit sc
}

ClassMethod Run(path As %String = "", database As %String = "", verbose As %Boolean = 1) As %Status
{
	set sc = $$$OK
	try {
		set separator = $s($$$isWINDOWS:"\",1:"/")
		set:$e(path,*)'=separator path = path_separator

		if (database'="") {
			set variables("database") = database
		}
		do ..RunDDL(path_"src"_separator_"sql"_separator_"use-db.sql", .variables, 1, 1)

		For queryid = "Q01","Q02","Q03","Q04","Q05","Q06","Q07","Q08","Q09","Q10","Q11","Q12","Q13","Q14","Q15","Q16","Q17","Q18","Q19","Q20","Q21","Q22" {
				set t1 = $zh
				set sc = ..RunDDL(path_"src"_separator_"sql"_separator_queryid_".sql")
				quit:$$$ISERR(sc)
				set t2 = $zh, t($i(t)) = queryid_" : "_$fn(t2-t1,,2)_"s"
        }

		if verbose {
			for i = 1:1:t {
				w !,"  - ",t(i)
			}
		}

	} catch (ex) {
		set sc = ex.AsStatus()
        write:verbose !,"Unexpected error: ",$system.Status.GetOneErrorText(sc)
	}
	write:verbose !
	quit sc
}

}
