//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o, oRs
	
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )		

		
		IF ! o:lConnect		
			? 'Error : ', o:cError
			RETU NIL
		ENDIF

		
		IF !empty( hRes := o:Query( 'select * from sellers' ) )
		
			aData := o:FetchAll( hRes )
			
			o:View( o:DbStruct(),	aData )
		
		ENDIF			

RETU NIL