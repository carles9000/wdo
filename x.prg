//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o, oRs, a
	
	
	//	Parametrizacón para todos los objetos que crearemos. CLASSDATA
	
		o := WDO():Rdbms( 'MYSQL' )

		? o:ClassName()
		
		IF !empty( hRes := o:Query( 'select * from users' ) )
		
			? 'Oks'
			? 'Count(): ', o:Count( hRes )
			? 'Fields: ',  o:FCount( hRes )
			
			//a := o:Fetch( hRes )
			
			
			for n := 1 to len( o:aFields )			
				? o:aFields[n][1], o:aFields[n][2]
			next
			
			
			//while ( !empty( a := o:Fetch( hRes ) ) )
			//	? valtochar( a )
			//end
			
			while ( !empty( a := o:Fetch_Assoc( hRes ) ) )
				? valtochar( a )
			end			
		
		ELSE
		
			? 'Eror'
		
		ENDIF
		
RETU NIL
