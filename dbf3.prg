//	------------------------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	------------------------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	LOCAL oDb1
	
	?? 'Init ' + time() + '<hr>'

	
	//	Config Sistema...
	
		o := WDO():Dbf()
			o:cDefaultPath 	:= hb_getenv( 'PRGPATH' ) + '/data'				
			o:cDefaultRdd 		:= 'DBFCDX'

	//	Open Tables
	
		oDb1 := WDO():Dbf( 'custo.dbf', 'custo.cdx' )				

			oDb1:Focus( 'state' )
			oDb1:Seek( 'LA' )			//	KS, LA, MA,...
	
			Test( oDb1, 'state', 'LA' )
			
			? '<hr>'
			
			oDb1:Focus( 'first' )
			oDb1:Seek( 'Sandy' )			//	
	
			Test( oDb1, 'first', 'Sandy' )	

			? '<hr>'
			
			oDb1:Focus( 'zip' )
			oDb1:Seek( '68428-0759' )			//	
	
			Test( oDb1, 'zip', '68428-0759' )			

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