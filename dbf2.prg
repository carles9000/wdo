//	------------------------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}	//	Loading WDO lib
//	------------------------------------------------------------------------------

FUNCTION Main()

	LOCAL oDb1, oDb2
	
	?? 'Init ' + time() + '<hr>'

	
	//	Config Sistema...
	
		o := WDO():Dbf()
			o:cDefaultPath 	:= hb_getenv( 'PRGPATH' ) + '/data'				
			o:cDefaultRdd 		:= 'DBFCDX'
				
	//	Exclusive Mode
	
		? '<br><b>==> Open Exclusive Mode...</b>'		
		
		oDb1 := WDO():Dbf( 'customer.dbf', 'customer.cdx', .F. )			//	Open Exclusive
			oDb1:lExclusive 	:= .T.			
			oDb1:cAlias		:= 'MYCUSTO'
			oDb1:Open()	
	
			? 'DB1 - Open Exclusive', oDb1:lOpen, oDb1:cAlias


	//	Shared Mode
	
		? '<br><b>==> Open Shared Mode...</b>'			
			
		oDb2 := RDBMS_Dbf():New( 'customer.dbf', 'customer.cdx'  )		//	Open Shared. Default Mode			
			
			? 'DB2 - Open Shared', oDb2:lOpen			

			
	//	Values...
	
		? '<br><b>==> Datas...</b>'	
		? '<br><u>Get values from Db1 & DB2</u><br>'
		? 'DB1 - Fielget( "first" ) =>', oDb1:FieldGet( 'first' )
		? 'DB2 - Fielget( "first" ) =>', oDb2:FieldGet( 'first' )
		
		oDb1:FieldPut( 'last', time() )
		
		View( oDb1 )		

RETU NIL



FUNCTION View( o )

	? '<hr><h3>View Table', o:cDbf, o:cRdd, '</h3>'	

	o:first()		
	
	?? '<table border="1">'
	
	FOR nI := 1 TO 10
	
		?? '<tr>' 
		?? '<td>' + valtochar(o:Recno()) + '</td>' 
		?? '<td>' + o:FieldGet( 1 ) + '</td>' 
		?? '<td>' + o:FieldGet( 'last' ) + '</td>' 
		?? '<td>' + o:FieldGet( 'street' ) + '</td>' 
		?? '</tr>'
		
		o:next()
		
	NEXT
	
	?? '</table>'	

RETU 