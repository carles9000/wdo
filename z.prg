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

	LOCAL cFileDbf 	:= hb_getenv( 'PRGPATH' ) + '/data/test.dbf'	
	LOCAL cFileCdx 	:= hb_getenv( 'PRGPATH' ) + '/data/test.cdx'	
	LOCAL aStruct 		:= {;
							{"id", "+", 10, 0},;
							{"updated", "=", 8, 0},;
							{"first", 'C', 40, 0 },;
							{"age", 'N', 3, 0 };
							} 

	//	Configuracion por defecto de nuestro sistema
	
		o := WDO():Dbf()
			o:cPath 		:= hb_getenv( 'PRGPATH' ) + '/data'
			o:cRdd 		:= 'DBFCDX'

	//	Check Dbf File
  
		IF !File( cFileDbf )  
		
			dbcreate( cFileDbf, aStruct )	
			? 'File test.dbf created'						
			
		ENDIF
	
	//	Check Index File	
	
		IF !File( cFileCdx )
		
			? 'No existe ' , cFileCdx
			
			o := WDO():Dbf( 'test.dbf', NIL, .F. )
					o:lExclusive	:= .T.
					o:Open()						
			
			? 'Open Exclusive' , o:lExclusive

			(o:cAlias)->( ORDCREATE( , "ID", "id" ) )
			(o:cAlias)->( ORDCREATE( , "FIRST", "first" ) )
			(o:cAlias)->( ORDCREATE( , "AGE", "age" ) )
			
			o:Close()
			
			? 'Indexado...'						
			
		ENDIF	
		
	//	Check Integrity	
	
		? 'Alias: ' , o:cAlias
	
		IF File( cFileDbf ) .AND. File( cFileCdx )

			o := WDO():Dbf( 'test.dbf', 'test.cdx')	
			
				o:Info()
			? 'Cdx: ' , o:cIndex
			? 'ordBagExt()', (o:cAlias)->( ordBagExt() )
			? 'ordKey() ', (o:cAlias)->( ordKey()  )
			? 'IndexOrd()', hb_ntos( IndexOrd() )
			? 'IndexKey( 1 )', (o:cAlias)->( IndexKey( 1 ) ) 	
			
		ELSE
			? 'Error con test.dbf' 
		ENDIF
		
	//	Open Test Table
	
			/*
			

			? 'ordName(1)', (o:cAlias)->( ordName(1) )
		*/
	
