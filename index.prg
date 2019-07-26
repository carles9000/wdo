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
	o 	:= WDO():New( 'MYSQL', "localhost", "harbour", "password", "dbHarbour", 3306 )
	
	o:Connect()	
	
	? o:Version()

	
RETU NIL