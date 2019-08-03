//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}					//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}	//	Usuarios Xampp
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o, hRes

	
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )		
		
		
		IF ! o:lConnect		
			? 'Error : ', o:cError
			RETU NIL
		ENDIF

		
		? "<h3>Insert 3 Registers</h3>"		
		
		o:Query( "INSERT INTO users (name, age) VALUES ('Maria "   + time() + "', '80')" ) 
		o:Query( "INSERT INTO users (name, age) VALUES ('Josefa "  + time() + "', '84')" ) 
		o:Query( "INSERT INTO users (name, age) VALUES ('Marilyn " + time() + "', '83')" ) 
		
		IF !empty( hRes := o:Query( 'select * from users' ) )
		
			aData := o:FetchAll( hRes )

			o:View( o:DbStruct(),	aData )
		
		ENDIF
		
		
		
		? "<h3>Delete age >= 80</h3>"
		
		o:Query( "delete FROM `users` WHERE age >= 80" ) 
		
		IF !empty( hRes := o:Query( 'select * from users' ) )
		
			aData := o:FetchAll( hRes )

			o:View( o:DbStruct(),	aData )
		
		ENDIF						
		
		
RETU NIL

