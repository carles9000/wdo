//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	
		? "<b>==> Test Error de conexion...</b><br>"
		
		
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "db_zzz", 3306 )

		
		IF o:lConnect
		
			? 'Connected !'
			
		ELSE
		
			? o:cError 
			
		ENDIF

RETU NIL
