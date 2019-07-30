//	------------------------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}				//	Loading WDO lib
//	------------------------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	LOCAL oDb1, oDb2

	
	//	Config Sistema...
	
		o := RDBMS_Dbf()
		
			?? 'Version WDO', o:ClassName(), o:Version()
		
		//	Parametrizacón para todos los objetos que crearemos
			o:cPath 	:= hb_getenv( 'PRGPATH' ) + '/data'				
			
			
		//	Open DBF default Rdd
		
			o := RDBMS_Dbf():New( 'customer.dbf', 'customer.cdx' )	

			Test( o )
			
		//	Open DBF		
			
			o := RDBMS_Dbf():New( 'users.dbf', 'users.ntx', .F. )	//	3 param. Open
				o:cRdd 	:= 'DBFNTX'		
				o:Open()				

			Test( o )
			
			
		//	Exclusive Mode
		
			? '<hr><h3>Open Exclusive Mode</h3>'			
			
			oDb1 := RDBMS_Dbf():New( 'customer.dbf', 'customer.cdx', .F. )	//	Open Exclusive
				oDb1:cRdd 			:= 'DBFCDX'		
				oDb1:lExclusive 	:= .T.			
				oDb1:cAlias		:= 'MYCUSTO'
				oDb1:Open()			
		
				? 'DB1 - Open Exclusive', oDb1:lOpen, oDb1:cAlias


					
			? '<hr><h3>Open Shared Mode</h3>'			
				
			oDb2 := RDBMS_Dbf():New( 'customer.dbf', 'customer.cdx'  )		//	Open Shared. Default Mode			
				
				? 'DB2 - Open Shared', oDb2:lOpen			
		
			? '<br><u>Get values from Db1 & DB2</u><br>'
			? 'DB1 - Fielget( "first" ) =>', oDb1:FieldGet( 'first' )
			? 'DB2 - Fielget( "first" ) =>', oDb2:FieldGet( 'first' )
		
RETU NIL



FUNCTION Test( o )

	? '<hr><h3>', o:cDbf, o:cRdd, '</h3>'
	
	? 'lOpen', o:lOpen
	? 'First()', o:first()
	? 'Fieldget(1)', o:FieldGet( 1 )
	? 'Fieldget( "first" )', o:FieldGet( 'first' )
	? 'Count()', o:Count()
	? 'Fieldname(1)', o:FieldName( 1 )
	? 'Next(5)', o:next( 5 ), o:Recno(), o:FieldGet( 1 )
	? 'Goto(7)', o:goto(7), o:Recno(), o:FieldGet( 1 )
	? 'Prev(2)', o:prev( 2 ), o:Recno(), o:FieldGet( 1 )
	? 'Last()', o:last(), o:FieldGet( 1 )
	? 'First()', o:first(),o:Recno(), o:FieldPut( 'street', time() )
	? 'Street: ' , o:FieldGet( 'street' ), o:Recno()
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

RETU 