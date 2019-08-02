//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------


FUNCTION Main()

	LOCAL oUsers := TUsers():New()
	LOCAL hReg, aRows

	? valtochar( oUsers:Row() )
	
	IF  oUsers:getId( 5 )		
		? '<br>Found !'		
	ELSE	
		? 'Not found'		
	ENDIF
	
	hReg := oUsers:Row()
	
	? '<br><b>Row =></b>', valtoChar( hReg )	
	
	? '<br>Name: ' , hReg[ 'name' ]
	
	? '<hr>'
	
	? '<br><b>List Dpt == TIC</b></br>'
	
	aRows := oUsers:GetDpt( 'TIC' ) 	
	
	FOR nI := 1 TO Len( aRows )
		? valtochar( aRows[nI] )
	NEXT			
	
RETU NIL

{% memoread( HB_GETENV( 'PRGPATH' ) + "/src/model/tusers.prg" ) %} 
