//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO - ADO
//	Date.......: 17/09/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}		//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	
		?? "<b>==> Test Error de conexion...</b><br><hr>"
		
		
		o := WDO():ADO()		
		
		? 'Version ', o:Version()
		? 'Open: ', o:Open()
		
		IF o:lConnect
		
			? 'Connected !'
			
		ELSE
		
			? 'Error: ', o:cError 
			
		ENDIF

RETU NIL
