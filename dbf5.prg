//	------------------------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% AAdd( getList, hb_milliseconds()  ) %}	//	Ocupará el 1 elemento del array
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	------------------------------------------------------------------------------

//	Test Speed...

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

exit procedure e

	LOCAl nLap 	:= ( hb_milliseconds() - M->getList[ 1 ] )
	LOCAL cHtml 
	
	cHtml 	:= '<div style="position:fixed;bottom:0px;background-color: #98cfff;">&nbsp;Lapsus milliseconds: ' 
	cHtml  	+= '<b>' + ltrim(str( nLap )) + '</b>&nbsp;'
	cHtml  	+= '</div>'
	
	? cHtml

retu 