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
		
		? o:ClassName()
		? o:cPath
		o:cPath := hb_getenv( 'PRGPATH' ) + '/data'
		? o:cPath
		
	//	Open DBF
	
		o := RDBMS_Dbf():New( 'customer.dbf', 'customer.cdx' )
		
		? '<hr>'
		? o:first(), o:FieldGet( 1 )
		? o:Recno(), o:FieldGet( 1 ), o:FieldGet( 2 ), o:FieldGet( 3 )
		? o:FieldGet( 1 )
		? o:FieldGet( 'first' )
		? o:Count()
		? o:FieldName( 1 )
		? o:next( 10 ), o:FieldGet( 1 )
		? o:prev( 5 ), o:Recno(), o:FieldGet( 1 )
		? o:last(), o:FieldGet( 1 )
		? o:prev( 1),o:Recno(), o:FieldPut( 'first', time() )
		? 'FIRST: ' , o:FieldGet( 'FIRST' ), o:Recno()
		
RETU NIL