//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o
		local c := 	dtos(date())+ltrim(str(seconds()))	//HB_DateTime()
		local d := hb_base64Encode( c )
		
		? 'A->', c
		? 'B->', d
		? 'C->', hb_Md5(d)
		
		retu nil
	
	
	
	//	Parametrizacón para todos los objetos que crearemos. CLASSDATA
	
		o := WDO():Dbf()
			o:cPath 	:= hb_getenv( 'PRGPATH' ) + '/data'
			
			?? '<b>Version WDO</b>', o:ClassName(), o:Version(), '<hr>'
		
		
	//	Uso de tabla Dbf...
		
		o := WDO():Dbf( 'custo.dbf', 'custo.cdx' )		
		/*
			IF o:Append()			

				o:Fieldput( 'First', 'Test_Append' )
				o:Fieldput( 'Last' , dtos( date()) + ' ' + time() )
				
				? o:Recno(), o:FieldGet( 'first' ), o:FieldGet( 'last' )
				
			ELSE
				? 'Error Append()'
			ENDIF							
		*/
RETU NIL

