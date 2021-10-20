//	Test de Diego Fazio

//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}							//	Loading WDO lib
//	{% HB_SetEnv( 'WDO_PATH_MYSQL', "c:/xampp/htdocs/" ) %}	//	Usuarios Xampp


FUNCTION Main()

   LOCAL o, a, hRes := {=>}


   ? "Connecting MySQL..."
   a =  hb_MilliSeconds()
   o := WDO():Rdbms( 'MYSQL', "localhost", "harbour", "password", "harbourdb", 3306 )						   
	o:lLog := .t.
	o:lWeb := .f.
	
   IF !o:lConnect

      ? o:cError
      QUIT

   ENDIF

   ?? 'OK ', hb_MilliSeconds() - a, 'ms' 

   ? "Getting data..."
   a =  hb_MilliSeconds()
   //hRes := o:Query( "select * from db where KAR_FECHA >= '2004-01-01' and KAR_FECHA <= '2004-12-31'" )
   hRes := o:Query( "select * from db where KAR_FECHA between '2004-01-01' and '2004-12-31'" )
   
   
  aData := o:FetchAll( hRes )
//aData := o:FetchAll( hRes, .t., { 'KAR_ARTIC' } )		//	Max process, .t. == hash, array = field with no escape

   ?? 'OK'
   ? "Total time:", hb_MilliSeconds() - a, "ms"
   ? "Result: ", Len( aData )
   ? "Result: ", o:Count( hRes )
   
   ? '<hr>'
   ? "Getting data..."
   
	a =  hb_MilliSeconds()  
   
   // hRes := o:Query( "select count(*) from db where KAR_FECHA between '2004-01-01' and '2004-12-31'" )
    //hRes := o:Query( "select * from db where KAR_FECHA between '2004-01-01' and '2004-12-31'" )
    hRes := o:Query( "select * from db where KAR_FECHA >= '2004-01-01' and KAR_FECHA <= '2004-12-31'" )
	? 'Lap Query ', hb_MilliSeconds() - a, "ms"
	retu
   
	
	f := o:nFields
	aData := {}
	
	
	hRow := o:mysql_fetch_row( hRes ) 
	
	
	while ( hRow := o:mysql_fetch_row( hRes ) ) != 0
	
		aReg := array( f )
		
		for m = 1 to f
			aReg[ m ] := PtrToStr( hRow, m - 1 ) 
		next		
		
		Aadd( aData, aReg )
	end 
	
	
    ? "Total time:", hb_MilliSeconds() - a, "ms"
    ? "Result: ", Len( aData )
    ? "Result: ", o:Count( hRes )  
   

RETURN NIL
