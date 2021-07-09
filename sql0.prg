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
		
		//o := WDO():Rdbms( 'MYSQL', "localhost", "root", "", "dummy", 3306 )
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )
		
		IF o:lConnect
		
			? 'Connected !', '<b>Version RDBMS MySql', o:Version()
			
		ENDIF

RETU NIL
