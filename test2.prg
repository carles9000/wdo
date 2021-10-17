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
   hRes := o:Query( "select * from db where KAR_FECHA >= '2004-01-01' and KAR_FECHA <= '2004-12-31'" )
   
   
  aData := o:FetchAll( hRes )
//aData := o:FetchAll( hRes, .t., { 'KAR_ARTIC' } )		//	Max process, .t. == hash, array = field with no escape

   ?? 'OK'
   ? "Total time:", hb_MilliSeconds() - a, "ms"
   ? "Result: ", Len( aData )
   ? "Result: ", o:Count( hRes )

RETURN NIL
