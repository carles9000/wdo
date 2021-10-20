//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	
	
	//	Parametrizacón para todos los objetos que crearemos. CLASSDATA
	
		o := WDO():Dbf()
			o:cDefaultPath 	:= hb_getenv( 'PRGPATH' ) + '/data'
			
			?? '<b>Version WDO</b>', o:ClassName(), o:Version(), '<hr>'
		
		
	//	Uso de tabla Dbf...
		
		o := WDO():Dbf( 'customer.dbf', 'customer.cdx' )		
		
			IF o:Append()			

				o:Fieldput( 'First', 'Test_Append' )
				o:Fieldput( 'Last' , dtos( date()) + ' ' + time() )
				
				? o:Recno(), o:FieldGet( 'first' ), o:FieldGet( 'last' )
				
			ELSE
				? 'Error Append()'
			ENDIF							
		
RETU NIL

