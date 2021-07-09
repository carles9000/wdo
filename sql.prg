//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}					//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}	//	Usuarios Xampp
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	
		? "<b>==> Test Error de conexion...</b><br>"
		
		
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "db_zzz", 3306 )

		
		IF o:lConnect
		
			? 'Connected !', '<b>Versión RDBMS MySql', o:Version()
			
		ELSE
		
			? o:cError 
			
		ENDIF

RETU NIL
