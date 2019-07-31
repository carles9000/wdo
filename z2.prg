/*
From Bielsys
Code Name Width (Bytes) Description
---- ------- ----------------- -------------------------------------------------------------------
D Date 3, 4 or 8 Date
M Memo 4 or 8 Memo
+ AutoInc 4 Auto increment
= ModTime 8 Last modified date & time of this record
^ RowVers 8 Row version number; modification count of this record
@ DayTime 8 Date & Time
I Integer 1, 2, 3, 4 or 8 Signed Integer ( Width : )" },;
T Time 4 or 8 Only time (if width is 4 ) or Date & Time (if width is 8 ) (?)
V Variant 3, 4, 6 or more Variable type Field
Y Currency 8 64 bit integer with implied 4 decimal
B Double 8 Floating point / 64 bit binaryEn el caso de ModTime, aunque no lo uso, entiendo que la diferencia es que se va actualizando automaticamente cada vez que modificas el registro.
espere

*/

//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}	//	Loading WDO lib
//	--------------------------------------------------------------

function main()
	LOCAL cFileCdx 	:= hb_getenv( 'PRGPATH' ) + '/data/test.cdx'	


	LOCAL cFile 	:= hb_getenv( 'PRGPATH' ) + '/data/test.dbf'	
	Local aStruct 	:= {;
						 {"id", "+", 10, 0},;
						 {"updated", "=", 8, 0},;
						 {"first", 'C', 40, 0 },;
						 {"age", 'N', 3, 0 };
						}   
  
  
  dbcreate( cFile, aStruct)	

  
  ? time(), 'Done !'
  
  
	
	//	Parametrizacón para todos los objetos que crearemos. CLASSDATA
	
		o := WDO():Dbf()
			o:cPath 		:= hb_getenv( 'PRGPATH' ) + '/data'
			o:cRdd 			:= 'DBFCDX'
			
			
			?? '<b>Version WDO</b>', o:ClassName(), o:Version(), '<hr>'  
  
	//	Uso de tabla Dbf...
		/*
		o := WDO():Dbf( 'test.dbf', NIL, .F. )
				o:cPath 	:= hb_getenv( 'PRGPATH' ) + '/data'		
				o:lExclusive	:= .T.
				o:Open()
		
			IF !File( cFileCdx )
				? 'No existe ' , cFileCdx
				? o:lExclusive
				INDEX ON id TO id
				(o:cAlias)->( ORDCREATE( , "ID", "id" ) )
				(o:cAlias)->( ORDCREATE( , "FIRST", "first" ) )
				
				SET INDEX TO (cFileCdx)
				? 'Indexado...'						
			ENDIF
			
			*/
			
			o := WDO():Dbf( 'test.dbf', 'test.cdx' )	

				? 'ordBagExt()', (o:cAlias)->( ordBagExt() )
				? 'ordName(1)', (o:cAlias)->( ordName(1) )
				? 'ordKey() ', (o:cAlias)->( ordKey()  )
				? 'IndexOrd()', hb_ntos( IndexOrd() )
				? 'IndexKey( 1 )', (o:cAlias)->( IndexKey( 1 ) ) 


			
			
				o:Focus( 'id' )
			IF o:Seek( 4 ) 
			
				? '</b>FOUND</b>', o:Recno(), o:FieldGet( 'id' ), o:FieldGet( 'updated' ),  o:FieldGet( 'first' )
				
				o:FieldPut( 'first', 'Test_Append a las ' + DToC(date()) + ' ' + time() )
				
			ELSE
			
				? 'No found' 
				
			ENDIF
			
			
			IF o:Seek( 5555 )
			
				? '</b>FOUND</b>', o:Recno(), o:FieldGet( 'id' ), o:FieldGet( 'updated' ),  o:FieldGet( 'first' )
				
			ELSE
			
				? 'No found' 
				
			ENDIF			
			
			? '<hr>'
			
			
			/*
			IF o:Append()			

				o:Fieldput( 'First', 'Test_Append a las ' + time() )
								
				? o:Recno(), o:FieldGet( 'id' ), o:FieldGet( 'updated' ),  o:FieldGet( 'first' )
				
			ELSE
				? 'Error Append()'
			ENDIF
			*/

			Test(o)
			
  
  

retu nil


FUNCTION Test( o )

	LOCAl cHtml := ''

	o:First()
	
	cHtml +=  '<table border="1">'	
	
	WHILE !o:Eof() 
	
		cHtml +=  '<tr>' 
		cHtml +=  '<td>' + ltrim(str(o:Recno())) + '</td>' 
		cHtml +=  '<td>' + valtochar(o:FieldGet( 'id' )) + '</td>' 
		cHtml +=  '<td>' + hb_ValToExp(o:FieldGet( 'updated' )) + '</td>' 
		cHtml +=  '<td>' + o:FieldGet( 'first' ) + '</td>' 		
		cHtml +=  '</tr>'
		
		o:next()
		
	END
	
	cHtml +=  '</table>'	
	
	? cHtml

RETU 


