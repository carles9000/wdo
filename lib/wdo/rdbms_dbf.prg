/*	---------------------------------------------------------
	File.......: rdbms_dbf.prg
	Description: Conexión a Dbf
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */ 
	
#define RDBMS_VERSION  					'0.1a'
	
CLASS RDBMS_Dbf FROM RDBMS


	DATA cAlias 							INIT ''
	DATA cError 							INIT ''
	DATA lExclusive						INIT .F.
	DATA lRead								INIT .F.
	DATA lOpen								INIT .F.
	DATA bExit								INIT {|| AP_RPUTS( '<h3>Exit Event...</h3>' )}
		
	CLASSDATA cPath 						INIT hb_getenv( 'PRGPATH' )
	CLASSDATA cRdd 							INIT 'DBFCDX'
	CLASSDATA nTime							INIT 10
	
	METHOD New() 							CONSTRUCTOR
	
	//	Standard methods

	METHOD Open()
	METHOD Close()	
	
	METHOD Count()  						INLINE IF ( ::lOpen, (::cAlias)->( RecCount() ), 0 )
	METHOD FieldPos( n )  				INLINE IF ( ::lOpen, (::cAlias)->( FieldPos( n ) ), '' )
	METHOD FieldName( n )  				INLINE IF ( ::lOpen, (::cAlias)->( FieldName( n ) ), '' )
	METHOD FieldGet( ncField )  			INLINE IF ( ::lOpen, (::cAlias)->( FieldGet( If( ValType( ncField ) == "C", ::FieldPos( ncField ), ncField ) ) ), '' )
    METHOD FieldPut( ncField, uValue )	
	
    METHOD Next( n )  						INLINE IF ( ::lOpen, (::cAlias)->( DbSkip( n ) ), NIL )
    METHOD Prev( n )  						INLINE IF ( ::lOpen, (::cAlias)->( DbSkip( -n ) ), NIL )
    METHOD First() 						INLINE IF ( ::lOpen, (::cAlias)->( DbGoTop() ), NIL )
    METHOD Last() 							INLINE IF ( ::lOpen, (::cAlias)->( DbGoBottom() ), NIL )
	
	METHOD SetError( cError )		
	METHOD Version()						INLINE RDBMS_VERSION		
	
	//	Special methods...
	
	METHOD OpenDbf( cFile ) 
    METHOD Recno() 						INLINE IF ( ::lOpen, (::cAlias)->( Recno() ), -1 )	
	  
	
	DESTRUCTOR  Exit()					

ENDCLASS

METHOD New( cDbf, cCdx, lOpen ) CLASS RDBMS_Dbf

	hb_default( @cDbf, '' )
	hb_default( @cCdx, '' )
	hb_default( @lOpen, .T. )
	
	::cDbf		:= cDbf
	::cCdx		:= cCdx
	
	
	//SET AUTOPEN OFF
	//INDEX ON MiTabla->nombre1 TAG nom1
	
	IF lOpen .AND. !empty( ::cDbf )
	
		::Open()
	
	ENDIF	

RETU SELF


METHOD Open() CLASS RDBMS_Dbf

	LOCAL cFileDbf := ''
	LOCAL cFileCdx := ''

    IF !empty( ::cDbf )
	
		cFileDbf := ::cPath + '/' + ::cDbf
		? 'Open Dbf', cFileDbf
		IF !File( cFileDbf )
		   ::SetError( 'Tabla de datos no existe: ' + ::cDbf )
		   RETU .F.
	    ENDIF
		
	ELSE
	
		RETU .F.
		
    ENDIF
	
	?? '=> Check File Ok...'		
	
    IF !empty( ::cCdx ) 
		cFileCdx := ::cPath + '/' + ::cCdx
		? 'Open Cdx', cFileCdx
		IF !File( cFileCdx )
			::SetError( 'Indice de datos no existe: ' + ::cCdx )
			RETU .F.
		ENDIF
    ENDIF
	
	::OpenDbf( cFileDbf, cFileCdx )					
	
RETU NIL

METHOD OpenDbf( cFileDbf, cFileCdx ) 

	LOCAL oError
	LOCAL cError 	 := ''
    LOCAL nInici   := Seconds()
    LOCAL nLapsus  := ::nTime
    LOCAL bError   := Errorblock({ |o| ErrorHandler(o) })
	

    BEGIN SEQUENCE

          WHILE nLapsus >= 0


             IF Empty( ::cAlias )
                ::cAlias := NewAlias()
             ENDIF

             DbUseArea( .T., ::cRDD, cFileDbf, ::cAlias, ! ::lExclusive, ::lRead )

             IF !Neterr() .OR. ( nLapsus == 0 )
                 EXIT
             ENDIF


             //SysWait( 0.1 )

             nLapsus := ::nTime - ( Seconds() - nInici )

             //SysRefresh()

          END

          IF NetErr()
             ::SetError( 'Error de apertura de: ' + cFileDbf )
            ELSE
             ::cAlias := Alias()
             ::lOpen  := .t.
			 
			 IF !empty( cFileCdx )
				SET INDEX TO (cFileCdx )			 			 
			 ENDIF
			 
          ENDIF

       RECOVER USING oError
	   
			? 'Error.....'
		
		//? oError:Subcode
		
          cError += valtochar(oError:Subcode)
          cError += if( ValType( oError:SubSystem   ) == "C", oError:SubSystem(), "???" )
          cError += if( ValType( oError:SubCode     ) == "N", "/" + ltrim(str(oError:SubCode )), "/???" )
          cError += if( ValType( oError:Description ) == "C", "  " + oError:Description, "" )		
		  
		 ::ShowError( cError )

   END SEQUENCE

RETU NIL


METHOD Close() CLASS RDBMS_Dbf

    IF ::lOpen
       IF Select( ::cAlias ) > 0
         (::cAlias)->( DbCloseArea() )
       ENDIF
       ::cAlias := ''
       ::lOpen  := .f.
    ENDIF

RETU NIL


METHOD SetError( cError ) CLASS RDBMS_Dbf

	::cError := cError
	
	? 'SetError()', ::cError
	
RETU NIL



METHOD FieldPut( ncField, uValue ) CLASS RDBMS_Dbf

	LOCAL lUpdated := .F.
	LOCAL cField

	IF !::lOpen	
		RETU .F.
	ENDIF				

	IF (::cAlias)->(RLock()) 
	
		If ValType( ncField ) == "C"
			cField := ::FieldPos( ncField )
		ELSE
			cField := ncField 
		ENDIF				
		
		(::cAlias)->( FieldPut( cField, uValue ) )

		(::cAlias)->( DbUnLock() )
		
		lUpdated := .T.
		
	ELSE
	
		
	ENDIF

RETU lUpdated

METHOD Exit() CLASS RDBMS_Dbf

	IF  ::lOpen	
	
		IF Valtype( ::bExit ) == 'B'
			Eval( ::bExit )
		ENDIF
	
		::Close() 
		
		
	ENDIF
	
RETU NIL

*-----------------------------------
STATIC FUNCTION ErrorHandler(oError)
*-----------------------------------

    BREAK oError

RETU NIL

*------------------
FUNCTION NewAlias()
*------------------

    LOCAL n      	:= 0
    LOCAL cAlias
	LOCAL cSeed 	:= 'ALIAS'


    cAlias  := cSeed + Ltrim(Str(n++))

    WHILE Select(cAlias) != 0
          cAlias := cSeed + Ltrim(Str(n++))
    END

RETU cAlias


