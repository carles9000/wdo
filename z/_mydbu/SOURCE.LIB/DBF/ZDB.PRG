#include "FiveWin.ch"
#include "error.ch"

#define DATA_ID        1
#define DATA_BLOC      2
#define DATA_CLASS     3
#define DATA_OBJECT    4
#define DATA_RDD       5

*--------
CLASS ZDb
*--------

   DATA   aBuffer                AS ARRAY INIT {}
   DATA   aError                 AS ARRAY INIT {}
   DATA   cError
   DATA   cTableError
   DATA   lOpen

   METHOD New()  CONSTRUCTOR

   METHOD Add( cID, bOpen )
   METHOD Open()

   METHOD Close()
   METHOD End()                INLINE ::Close()
   METHOD MsgError()           INLINE zTable( ::aError, { 'File', 'Error' }, 'TDb():Error' )

   ERROR HANDLER OnError( uParam1 )

ENDCLASS


*---------------------
METHOD New() CLASS ZDb
*---------------------

   ::aBuffer      := {}
   ::aError       := {}
   ::cError       := ''
   ::cTableError  := ''
   ::lOpen        := .F.

RETU Self

*---------------------------------
METHOD Add( cID, bOpen ) CLASS ZDb
*---------------------------------
    LOCAL nPos   := 0
    LOCAL oError := NIL

    IF ValType( cID ) != 'C'
       RETU NIL
    ENDIF

    cID    := Upper( cID )
    nPos   := AScan( ::aBuffer, { |x| x[ DATA_ID ] == cID } )

    IF nPos == 0
       Aadd( ::aBuffer, { cID, bOpen, NIL, NIL, NIL } )
      ELSE
       MsgStop( "Variable en uso: " + cID )
    ENDIF

RETURN NIL


*----------------------
METHOD Open() CLASS ZDb
*----------------------
    LOCAL nLen   := Len( ::aBuffer )
    LOCAL nI     := 0
    LOCAL lOpen  := .t.
    LOCAL lError := .f.
    LOCAL bOpen
    LOCAL oApp       := zApp():New()
    LOCAL oMeter
    LOCAL oObject

*    oMeter := ZMeterBar( nLen, 'Proc. BD', .t., GetWndMain() )

*    WHILE nI < nLen .AND. lOpen
    WHILE nI < nLen

        nI++

        bOpen   := ::aBuffer[ nI ][ DATA_BLOC ]
        oObject := Eval( bOpen )

        ::aBuffer[ nI ][ DATA_CLASS  ] := oObject:ClassName()
        ::aBuffer[ nI ][ DATA_OBJECT ] := oObject

        DO CASE
           CASE ::aBuffer[ nI ][ DATA_CLASS  ] == 'ZFILEDBF'

                IF ! oObject:lOpen
                    lError := .t.
                    Aadd( ::aError, { oObject:cFile, oObject:cError } )
                  ELSE
                    ::aBuffer[ nI ][ DATA_RDD ] := zRdd():New( oObject )
                ENDIF

        ENDCASE

*        oMeter:Set( nI )

    END

*    oMeter:End()

    ::lOpen := !lError

    IF ! ::lOpen
         ::Close()
    ENDIF

RETU ::lOpen

*-----------------------
METHOD Close() CLASS ZDb
*-----------------------
    LOCAL nLen := Len( ::aBuffer )
    LOCAL nI   := 0

    WHILE nI < nLen
        nI++
        IF ::aBuffer[ nI ][ DATA_CLASS  ] == 'ZFILEDBF'
           ::aBuffer[ nI ][ DATA_OBJECT ]:End()
        ENDIF
        SysRefresh()
    END

    ::aBuffer := {}

RETU NIL

*----------------------------------
METHOD OnError( uParam1 ) CLASS ZDb
*----------------------------------
    LOCAL nVar
    LOCAL cMsg   := __GetMessage()
    LOCAL nError := If( SubStr( cMsg, 1, 1 ) == "_", 1005, 1004 )

    cMsg := Upper( cMsg )

    IF SubStr( cMsg, 1, 1 ) == "_"    // SET

//     En aquesta clase no dixarem fer una assignacio

        _ClsSetError( _GenError( nError, ::ClassName(), 'No se puede asignar a ningun miembro de la clase' ) )

     ELSE                           // GET

       nVar := AScan( ::aBuffer, { |x| x[ DATA_ID ] == cMsg } )

       IF nVar > 0

          RETU ::aBuffer[ nVar ][ DATA_RDD ]

         ELSE
           MsgBeep()
           MsgStop( "Taula no definida: " + cMsg , 'ZDb () - Get')
           _ClsSetError( _GenError( nError, ::ClassName(), 'Taula no definida ' + cMsg ) )
       ENDIF

    ENDIF

RETU NIL
