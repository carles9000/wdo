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
			
			?? '<b>Version WDO</b>', o:ClassName(), o:Version(), '<hr>'
		
		
	//	Uso de tabla Dbf...
		
		o := WDO():Dbf( 'custo.dbf', 'custo.cdx' )		
		
			o:Focus( 'state' )
			o:Seek( 'LA' )			//	KS, LA, MA,...
	
			Test( o, 'state', 'LA' )
			
			? '<hr>'
			
			o:Focus( 'first' )
			o:Seek( 'Sandy' )			//	
	
			Test( o, 'first', 'Sandy' )	

			? '<hr>'
			
			o:Focus( 'zip' )
			o:Seek( '68428-0759' )			//	
	
			Test( o, 'zip', '68428-0759' )					
			
		
RETU NIL

FUNCTION Test( o, cField, uValue )

	LOCAl cHtml := ''

	cHtml += '<b>Focus </b>' + cField + ' = ' + uValue + '<br>'
	
	cHtml +=  '<table border="1">'
	
	WHILE !o:Eof() .AND. o:FieldGet( cField ) = uValue
	
		cHtml +=  '<tr>' 
		cHtml +=  '<td>' + ltrim(str(o:Recno())) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 'first' ) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 'last' ) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 'city' ) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 'zip' ) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 'state' ) + '</td>' 
		cHtml +=  '</tr>'
		
		o:next()
		
	END
	
	cHtml +=  '</table>'	
	
	? cHtml

RETU 
