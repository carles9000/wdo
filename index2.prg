//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	
	
	//	Parametrizacón para todos los objetos que crearemos. CLASSDATA
	
		o := WDO():Dbf()
			o:cPath 	:= hb_getenv( 'PRGPATH' ) + '/data'
			o:cRdd 	:= 'DBFCDX'
			
			?? '<b>Version WDO</b>', o:ClassName(), o:Version()
		
		
	//	Uso de tabla Dbf...
		
		o := WDO():Dbf( 'customer.dbf', 'customer.cdx' )		
	
			Test( o )
			
			
//		o := WDO():Rdbms( 'MYSQL' , "localhost", "harbour", "password", "dbHarbour", 3306  )			
//		o := WDO():Rdbms( 'ORACLE', "localhost", "harbour", "password", "dbHarbour", 3306  )			
//		o := WDO():Rdbms( 'SQLITE', "localhost", "harbour", "password", "dbHarbour", 3306  )					
		
RETU NIL

FUNCTION Test( o )

	LOCAl cHtml := ''

	o:first()		
	
	cHtml +=  '<table border="1">'
	
	FOR nI := 1 TO 10
	
		cHtml +=  '<tr>' 
		cHtml +=  '<td>' + ltrim(str(o:Recno())) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 1 ) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 2 ) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 3 ) + '</td>' 
		cHtml +=  '</tr>'
		
		o:next()
		
	NEXT
	
	cHtml +=  '</table>'	
	
	? cHtml

RETU 
