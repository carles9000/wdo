//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% AAdd( getList, hb_milliseconds()  ) %}	//	Ocupará el 1 elemento del array
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

//	Test Speed...

FUNCTION Main()

	LOCAL o, oRs
	LOCAL n, j			
	
		o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )		
		
		IF ! o:lConnect		
			? 'Error : ', o:cError
			RETU NIL
		ENDIF
		
		
		? "<hr><b>==> Fetch  Query( 'select * from users' )</b>"
		
		IF !empty( hRes := o:Query( 'select * from sellers limit 10' ) )
		
			WHILE ( !empty( hRs := o:Fetch_Assoc( hRes ) ) )
				? hRs[ 'code' ], hRs[ 'first' ], hRs[ 'address1' ], hRs[ 'zipcode' ], hRs[ 'email' ]
			END
		
		ENDIF						
		
RETU NIL

exit procedure e

	LOCAl nLap 	:= ( hb_milliseconds() - M->getList[ 1 ] )
	LOCAL cHtml 
	
	cHtml 	:= '<div style="position:fixed;bottom:0px;background-color: #98cfff;">&nbsp;Lapsus milliseconds: ' 
	cHtml  	+= '<b>' + ltrim(str( nLap )) + '</b>&nbsp;'
	cHtml  	+= '</div>'
	
	? cHtml

retu 