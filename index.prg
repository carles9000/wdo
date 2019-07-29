//	------------------------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 09/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}				//	Loading WDO lib
//	------------------------------------------------------------------------------

FUNCTION Main()

	LOCAL o

	? time()
	
	//o 	:= WDO_MySql():New()			
	
	
	o 	:= WDO():Rdd( 'customer.dbf', 'customer.cdx' )
	
	o:Connect()	
	
	? o:Version()

	
RETU NIL