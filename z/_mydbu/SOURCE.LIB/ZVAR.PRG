#include "FiveWin.ch"
#include "error.ch"

#define DATA_NAME      1
#define DATA_VAL       2
#define DATA_TXT       3

*---------
CLASS ZVar
*---------

   DATA   aBuffer                AS ARRAY INIT {}

   METHOD New()  CONSTRUCTOR
   METHOD End()

   METHOD AddVar( cName, uVal, cTxt )

   METHOD GetTxt( cName )
   METHOD GetVar()                        INLINE ::aBuffer

   ERROR HANDLER OnError( uParam1 )

ENDCLASS


*----------------------
METHOD New() CLASS ZVar
*----------------------

   ::aBuffer := {}

RETURN Self

*----------------------
METHOD End() CLASS ZVar
*----------------------

    ::aBuffer := {}

RETURN NIL

*--------------------------------------------
METHOD AddVar( cName, uVal, cTxt ) CLASS ZVar
*--------------------------------------------

    LOCAL nPos   := 0
    LOCAL oError := NIL

    DEFAULT uVal := NIL
    DEFAULT cTxt := ""

    IF ValType( cName ) != 'C'
       RETU NIL
    ENDIF

*    IF Len( cName ) > 9
*       MsgBeep()
*       MsgStop( "Variable no puede ser superior a 9 caracteres" + CRLF + cName, 'ZVar():New()' )
*       RETU NIL
*    ENDIF

*    IF Len( cName ) > 9
*       cName := Substr( cName, 1, 9 )
*    ENDIF

    cName  := Upper( cName )
    nPos   := AScan( ::aBuffer, { |x| x[ DATA_NAME ] == cName } )

    IF nPos == 0
       Aadd( ::aBuffer, { cName, uVal, cTxt } )
      ELSE
**-     Generarem un error !!!
*       oError             := ErrorNew()
*       oError:Subsystem   := ::ClassName()
*       oError:Severity    := ES_ERROR
*       oError:Description := "Variable in use: " + cName
*       oError:Operation   := ""
*       Eval( ErrorBlock(), oError )
        MsgBeep()
        MsgStop( "Variable en uso: " + cName )
    ENDIF

RETURN NIL


*--------------------------------
METHOD GetTxt( cName ) CLASS ZVar
*--------------------------------

    LOCAL cTxt := ''
    LOCAL nVar := 0

    cName := Upper( cName )
    nVar  := AScan( ::aBuffer, { |x| x[ DATA_NAME ] == cName } )

    IF nVar > 0
       cTxt := ::aBuffer[ nVar ][ DATA_TXT ]
    ENDIF

RETURN cTxt

*-----------------------------------
METHOD OnError( uParam1 ) CLASS ZVar
*-----------------------------------
    LOCAL nVar
    LOCAL cMsg   := __GetMessage()
    LOCAL nError := If( SubStr( cMsg, 1, 1 ) == "_", 1005, 1004 )

    cMsg := Upper( cMsg )

    IF SubStr( cMsg, 1, 1 ) == "_"    // SET

*       cMsg := Substr( cMsg, 2, 9 )
       cMsg := Substr( cMsg, 2 )
       nVar := AScan( ::aBuffer, { |x| x[ DATA_NAME ] == cMsg } )

       IF nVar > 0
*          ::aBuffer[ nVar ][ DATA_VAL ] := GetParam( 1, 1 )
          ::aBuffer[ nVar ][ DATA_VAL ] := uParam1
         ELSE
*          _ClsSetError( _GenError( nError, ::ClassName(), cMsg ) )
           MsgBeep()
           MsgStop( "Variable no existe: " + cMsg , 'ZVar() - Set')
       ENDIF

     ELSE                           // GET

*       IF Len( cMsg ) > 9
*          cMsg := Substr( cMsg, 1, 9 )
*       ENDIF

       nVar := AScan( ::aBuffer, { |x| x[ DATA_NAME ] == cMsg } )

       IF nVar > 0
          RETURN ::aBuffer[ nVar ][ DATA_VAL ]
         ELSE
           MsgBeep()
           MsgStop( "Variable no existe: " + cMsg , 'ZVar() - Get')
       ENDIF

    ENDIF

RETURN NIL
