//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO - ADO
//	Date.......: 17/09/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}		//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL hCfg 	:= Config_ADO()
	LOCAL o, oRs
	LOCAL n
	
		o := WDO():ADO( hCfg, .T. )
		
		o:Version()
		
		oRs := o:Query( 'SELECT * FROM CUSTOMER' ) 
		
		? 'Count: ' , oRs:Count()
		? '<hr>'
		
		for n = 1 to oRs:FCount()
			? oRs:FieldName( n ), oRs:FieldGet( n )
		next
		
		? '<hr>'
		oRs:Next() 
		
		for n = 1 to oRs:FCount()
			? oRs:FieldName( n ), oRs:FieldGet( n )
		next 
		
		? '<hr>'
		oRs:Next()
		
		? valtochar( oRs:Row() )
		
RETU NIL


{% memoread( HB_GETENV( 'PRGPATH' ) + "/cfg_ado.prg" ) %} 
