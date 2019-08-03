//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}					//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}	//	Usuarios Xampp
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o, oRs
	LOCAL n, j
	
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )		
		
		IF ! o:lConnect		
			? 'Error : ', o:cError
			RETU NIL
		ENDIF
		
		
		? "<hr><b>==> Fetch  Query( 'select * from users' )</b>"
		
		IF !empty( hRes := o:Query( 'select * from users' ) )
		
			WHILE ( !empty( oRs := o:Fetch( hRes ) ) )
				? valtochar( oRs )
			END
		
		ENDIF			
		
		? "<hr><b>==> Fetch_Assoc  Query( 'select * from users' )</b>"
		
		IF !empty( hRes := o:Query( 'select * from users' ) )
		
			WHILE ( !empty( oRs := o:Fetch_Assoc( hRes ) ) )
				? valtochar( oRs )
			END
		
		ENDIF		
		
		
		? "<hr><b>==> DbStruct()</b>"
		
			aSt := o:DbStruct()
			
			for n := 1 TO len( aSt )
				? aSt[n][1], valtochar(aSt[n][2])
			next		
		
		
		? "<hr><b>==> Error  Query( 'select * from ZZZ' )</b>"
		
		IF empty( hRes := o:Query( 'select * from ZZZ' ) )

			? '<h3>' + o:cError + '</h3>'
			
		ENDIF				
		
		

		? "<hr><b>==> FetchAll Query( 'select * from users' )</b>"
		
		IF !empty( hRes := o:Query( 'select * from users' ) )
		
			aData := o:FetchAll( hRes )
			

			for n := 1 to len( aData )
			
				? 'Reg: ' + ltrim(str(n))
			
				for j := 1 to len( aData[n] )
					?? valtochar(aData[n][j])
				next			
			
			next
			
			//	Nice print...
			
			o:View( aSt, aData )
		
		ENDIF			
		
		
RETU NIL
