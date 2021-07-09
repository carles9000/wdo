//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}							//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}	//	Usuarios Xampp
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o, hRes, cTag

	
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )		
	
		
		IF ! o:lConnect		
			? 'Error : ', o:cError
			RETU NIL
		ENDIF
		
		cTag := ltrim(str(hb_milliseconds()))
		
		? "<h3>Insert 3 Registers with first = " + cTag + "</h3>"		
		
		o:Query( "INSERT INTO customer (first, age) VALUES ('" + cTag + "', '80')" ) 						
		o:Query( "INSERT INTO customer (first, age) VALUES ('" + cTag + "', '84')" ) 
		o:Query( "INSERT INTO customer (first, age) VALUES ('" + cTag + "', '83')" ) 
		
		IF !empty( hRes := o:Query( "select * from customer where first = '" + cTag + "' " ) )
		
			aData := o:FetchAll( hRes )

			o:View( o:DbStruct(),	aData )
		
		ENDIF	
	
		
		? "<h3>Delete first = '" + cTag + "' </h3>"
		
		o:Query( "delete FROM `customer` WHERE first = '" + cTag + "' " ) 
		
		IF !empty( hRes := o:Query( "select * from customer where first = '" + cTag + "' " ) )
		
			aData := o:FetchAll( hRes )

			o:View( o:DbStruct(),	aData )
		
		ENDIF						
		
		
RETU NIL

