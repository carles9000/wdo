//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}							//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}	//	Usuarios Xampp
//	--------------------------------------------------------------


function Main()

	local hParam, cSql

    if AP_Method() != "POST"
		? "This example is used to review POST sent values from sql7 example"
		return nil
	endif
	
	hParam := AP_PostPairs()
	
	? '<b>Parameters</b>', hParam
	
	
	o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )		
	//o:Query( "SET @@sql_mode=CONCAT_WS(',', @@sql_mode, 'NO_BACKSLASH_ESCAPES');" )
	//o:Query( "SET sql_mode=NO_BACKSLASH_ESCAPES;" )
		
	IF ! o:lConnect		
		RETU NIL
	ENDIF
	
	cSql := "select * from users where user = '" + hParam[ 'user' ] + "' and psw = '" + hParam[ 'psw' ] + "' " 
	//cSql := 'select * from users where user = "' + hParam[ 'user' ] + '" and psw = "' + hParam[ 'psw' ] + '" ' 
	
	? '<b>Sql: </b>' + cSql
	
	hRes := o:Query( cSql ) 

	if o:Count( hRes ) > 0
	
		oRs := o:Fetch( hRes ) 
		
		? '<h3>User exist => ', oRs
		
	else 
	
		? "<h3>User don't exist"

	endif
	

return nil
