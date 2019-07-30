/*	---------------------------------------------------------
	File.......: rdbms_dbf.prg
	Description: Conexión a Dbf
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */ 
	
#define RDBMS_VERSION  					'0.1a'

#define _SET_AUTOPEN          45
	
CLASS RDBMS_Dbf FROM RDBMS


	DATA cAlias 							INIT ''
	DATA cError 							INIT ''
	DATA lExclusive						INIT .F.
	DATA lRead								INIT .F.
	DATA lOpen								INIT .F.
	DATA bExit								//INIT {|| AP_RPUTS( '<h3>Destructor Class...</h3>' )}
	
		
	CLASSDATA cPath 						INIT hb_getenv( 'PRGPATH' )
	CLASSDATA cRdd 							INIT 'DBFCDX'
	CLASSDATA nTime							INIT 10
	
	METHOD New() 							CONSTRUCTOR
	
	//	Common methods

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
	
	//	Particular methods...
	
    METHOD GoTo( n ) 						INLINE IF ( ::lOpen, (::cAlias)->( DbGoTo( n ) ), NIL )	
    METHOD Recno() 						INLINE IF ( ::lOpen, (::cAlias)->( Recno() ), -1 )	
	  
	
	DESTRUCTOR  Exit()					

ENDCLASS

METHOD New( cDbf, cIndex, lOpen ) CLASS RDBMS_Dbf

	hb_default( @cDbf, '' )
	hb_default( @cIndex, '' )
	hb_default( @lOpen, .T. )
	
	::cDbf		:= cDbf
	::cIndex	:= cIndex	
	
	IF lOpen .AND. !empty( ::cDbf )
	
		::Open()
	
	ENDIF	

RETU SELF


METHOD Open() CLASS RDBMS_Dbf

	LOCAL oError
	LOCAL cError 	 	:= ''
    LOCAL nIni  		:= 0
    LOCAL nLapsus  	:= ::nTime
    LOCAL bError   	:= Errorblock({ |o| ErrorHandler(o) })	
	LOCAL cFileDbf 	:= ''
	LOCAL cFileCdx 	:= ''
	LOCAL lAutoOpen	:= Set( _SET_AUTOPEN, .F. )	//	SET AUTOPEN OFF
	
	//	Check files...

		IF !empty( ::cDbf )
		
			cFileDbf := ::cPath + '/' + ::cDbf

			IF !File( cFileDbf )
			   ::SetError( 'Tabla de datos no existe: ' + ::cDbf )
			   RETU .F.
			ENDIF
			
		ELSE
		
			RETU .F.
			
		ENDIF
		
		IF !empty( ::cIndex ) 
		
			cFileCdx := ::cPath + '/' + ::cIndex

			IF !File( cFileCdx )
				::SetError( 'Indice de datos no existe: ' + ::cIndex )
				RETU .F.
			ENDIF
			
		ENDIF
		
	//	Open table dbf...
	
		nIni  		:= Seconds()
		
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

				 nLapsus := ::nTime - ( Seconds() - nIni )

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

				cError += if( ValType( oError:SubSystem   ) == "C", oError:SubSystem, "???" ) 
				cError += if( ValType( oError:SubCode     ) == "N", " " + ltrim(str(oError:SubCode )), "/???" ) 
				cError += if( ValType( oError:Description ) == "C", " " + oError:Description, "" )		
			
				::SetError( cError )			

	   END SEQUENCE	
	   
	   
	// Restore handler 		   

		ErrorBlock( bError )   
		Set( _SET_AUTOPEN, lAutoOpen )		
			
	
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
	
	IF ::lShowError			
		? '<h3>Error', ::cDbf, ' => ', ::cError, '</h3>'
	ENDIF
	
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


