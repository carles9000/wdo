#include "FiveWin.ch"
#include "error.ch"

#define DATA_NAME      1
#define DATA_VAL       2
#define DATA_TXT       3

STATIC aBuffer := {}

*-----------------
FUNCTION GetoApp() ; RETU zApp():New()
*-----------------

*---------
CLASS zApp
*---------

   CLASSDATA lRegistered     AS LOGICAL   INIT .F.
   CLASSDATA cDirPrg         AS CHARACTER INIT DirPrg()
   CLASSDATA cNameDll        AS CHARACTER INIT ''
   CLASSDATA cDirDll         AS CHARACTER INIT DirPrg() + '\Dll'
   CLASSDATA cDirTmp         AS CHARACTER INIT DirPrg() + '\Temp'
   CLASSDATA cDirError       AS CHARACTER INIT DirPrg() + '\Error'
   CLASSDATA cDirTools       AS CHARACTER INIT DirPrg() + '\Tools'
   CLASSDATA cLogin          AS CHARACTER INIT Space(8)
   CLASSDATA cUsrName        AS CHARACTER INIT Space(50)
   CLASSDATA lUsrUpdate      AS LOGICAL   INIT .F.

   METHOD New()  CONSTRUCTOR
   METHOD End()

   METHOD AddVar( cName, uVal, cTxt )

   METHOD SetDll( hResource )

   ERROR HANDLER OnError( uParam1 )

ENDCLASS


*----------------------
METHOD New() CLASS zApp
*----------------------

    IF ::lRegistered
       RETU Self
    ENDIF

    ::lRegistered := .t.

RETURN Self

*----------------------
METHOD End() CLASS zApp
*----------------------

    ::aBuffer := {}

RETURN NIL

*--------------------------------------------
METHOD AddVar( cName, uVal, cTxt ) CLASS zApp
*--------------------------------------------
    LOCAL nPos   := 0
    LOCAL oError := NIL

    DEFAULT uVal := NIL
    DEFAULT cTxt := ""

    IF ValType( cName ) != 'C'
       RETU NIL
    ENDIF

    cName  := Upper( cName )
    nPos   := AScan( aBuffer, { |x| x[ DATA_NAME ] == cName } )

    IF nPos == 0
       Aadd( aBuffer, { cName, uVal, cTxt } )
      ELSE
**-     Generarem un error !!!
       oError             := ErrorNew()
       oError:Subsystem   := ::ClassName()
       oError:Severity    := ES_ERROR
       oError:Description := "Variable in use: " + cName
       oError:Operation   := ""
       Eval( ErrorBlock(), oError )
       MsgBeep()
       MsgStop( "Variable en uso: " + cName )
    ENDIF


RETU NIL


*-----------------------------------
METHOD OnError( uParam1 ) CLASS zApp
*-----------------------------------
    LOCAL nVar
    LOCAL cMsg   := __GetMessage()
    LOCAL nError := If( SubStr( cMsg, 1, 1 ) == "_", 1005, 1004 )

    cMsg := Upper( cMsg )

    IF SubStr( cMsg, 1, 1 ) == "_"    // SET

       cMsg := Substr( cMsg, 2 )
       nVar := AScan( aBuffer, { |x| x[ DATA_NAME ] == cMsg } )

       IF nVar > 0
          aBuffer[ nVar ][ DATA_VAL ] := uParam1
         ELSE
*          _ClsSetError( _GenError( nError, ::ClassName(), cMsg ) )
           MsgBeep()
           MsgStop( "Variable no existe: " + cMsg , 'zApp() - Set')
       ENDIF

     ELSE                           // GET

       nVar := AScan( aBuffer, { |x| x[ DATA_NAME ] == cMsg } )

       IF nVar > 0
          RETURN aBuffer[ nVar ][ DATA_VAL ]
         ELSE
           MsgBeep()
           MsgStop( "Variable no existe: " + cMsg , 'zApp() - Get')
       ENDIF

    ENDIF

RETU NIL


*------------------------------------
METHOD SetDll( hResource ) CLASS zApp
*------------------------------------
     LOCAL hOldRes := GetResources()

     DO CASE
        CASE ValType( hResource ) == 'N'
             SetResources( hResource )
        CASE ValType( hResource ) == 'C'
             IF SetResources( ::cDirDll + '\' + hResource ) < 32
                  MsgStop( ::cDirDll + '\' + hResource + " not found, imposible to continue",;
                          "'Z' Error")
                  RETU 0
             ENDIF
        OTHERWISE
             IF SetResources( ::GetDll() ) < 32
                  MsgStop( ::GetDll() + " not found, imposible to continue",;
                          "'Z' Error")
                  RETU 0
             ENDIF
     ENDCASE

RETU hOldRes

