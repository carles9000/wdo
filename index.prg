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
	//? o:Version()
	
	//	Config Sistema...
	
		o := RDBMS_Dbf()
		
		//	Parametrizacón para todos los objetos que crearemos
			o:cPath := hb_getenv( 'PRGPATH' ) + '/data'
		
		
			? 'Version', o:Version()
		
	//	Open DBF
	
		o := RDBMS_Dbf():New( 'customer.dbf', 'customer.cdx' )
		
		? '<hr>'
		? o:first(), o:FieldGet( 1 )
		? o:Recno(), o:FieldGet( 1 ), o:FieldGet( 2 ), o:FieldGet( 3 )
		? o:FieldGet( 1 )
		? o:FieldGet( 'first' )
		? o:Count()
		? o:FieldName( 1 )
		? o:next( 5 ), o:FieldGet( 1 )
		? o:prev( 2 ), o:Recno(), o:FieldGet( 1 )
		? o:last(), o:FieldGet( 1 )
		? o:first(),o:Recno(), o:FieldPut( 'last', time() )
		? 'LAST: ' , o:FieldGet( 'last' ), o:Recno()
		? '<hr>'
		
		o:first()
		
		?? '<table border="1">'
		
		FOR nI := 1 TO 10
		
			?? '<tr>' 
			?? '<td>' + valtochar(o:Recno()) + '</td>' 
			?? '<td>' + o:FieldGet( 1 ) + '</td>' 
			?? '<td>' + o:FieldGet( 2 ) + '</td>' 
			?? '<td>' + o:FieldGet( 3 ) + '</td>' 
			?? '</tr>'
			
			o:next()
			
		NEXT
		
		?? '</table>'
		
		
		
RETU NIL