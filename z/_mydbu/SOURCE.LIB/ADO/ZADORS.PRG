/*
 *  (c) 2008 Carles Aubia
 *
 *  Inspirat en idees i clases de Carlos Mora, Biel, Adolfo, ...
 *
 */

#include "Fivewin.ch"
#include ".\include\ado.ch"

*------------------
CLASS zAdoRS
*------------------
   DATA oRS
   DATA oAdoConnection    AS OBJECT

   DATA lOpen              AS LOGICAL   INIT .F.
   DATA lDbg               AS LOGICAL   INIT .F.

   DATA cError             AS CHARACTER INIT  ''
   DATA nFields            AS NUMERIC   INIT 0
   DATA aFldNames          AS ARRAY     INIT {}
   DATA aStruct            AS ARRAY     INIT {}

   METHOD New( oConnection ) CONSTRUCTOR

   METHOD Open( cSqlStm, nCursorType, nLockType, nOptions )

   METHOD Structure()
   METHOD GetoConn()       INLINE ::oAdoConnection:oConn

ENDCLASS

*------------------------------------------------
METHOD New( oAdoConnection ) CLASS zAdoRS
*------------------------------------------------
   LOCAL oError


   TRY

*     ::oRs := OleWEvent():New("ADODB.Recordset")  // No xuta be quan fem MDI
     ::oRs := CreateObject( "ADODB.RecordSet" )

    CATCH oError

      Alert( oError:Operation,"Ado RecordSet NEW")

   END

   ::oAdoConnection := oAdoConnection
   ::lOpen          := .F.


RETU Self

/* oConn:State
adStateClosed     0 The object is closed
adStateOpen       1 The object is open
adStateConnecting 2 The object is connecting
adStateExecuting  4 The object is executing a command
adStateFetching   8 The rows of the object are being retrieved
*/


*---------------------------------------------------------------------------
METHOD Open( cSqlStm, nCursorType, nLockType, nOptions ) CLASS zAdoRS
*---------------------------------------------------------------------------
   LOCAL oError
   LOCAL oConn    := ::oAdoConnection:oConn
   LOCAL cTxt
   LOCAL nLapsus

   IF oConn:State <> adStateOpen
      IF ::oAdoConnection:lMessage
         MsgAlert( 'Connection state: ' + ltrim(Str(oConn:State)), 'ADO Connection' )
      ENDIF
      RETU .F.
   ENDIF

   DEFAULT nCursorType := adOpenDynamic      // ADS Ok
   DEFAULT nLockType   := adLockReadOnly  // adLockPessimistic  // adLockOptimistic, adLockReadOnly
   DEFAULT nOptions    := adCmdUnknown       // && adOptionUnspecified


IF ::lDbg

    cTxt := '::oRs:Source          ' + Chr( VK_TAB ) + cValToChar(::oRs:Source         ) + CRLF +;
            '::oRs:CursorLocation  ' + Chr( VK_TAB ) + cValToChar(::oRs:CursorLocation ) + CRLF +;
            '::oRs:LockType        ' + Chr( VK_TAB ) + cValToChar(::oRs:LockType       ) + CRLF +;
            '::oRs:CursorType      ' + Chr( VK_TAB ) + cValToChar(::oRs:CursorType     ) + CRLF +;
            '::oRs:CacheSize       ' + Chr( VK_TAB ) + cValToChar(::oRs:CacheSize       )

    MsgInfo( cTxt, '1' )

ENDIF

    TRY

       ::oRs:CursorLocation := 3

nLapsus := Seconds()

       ::oRS:Open( cSqlStm, oConn, 1, 3 )

nLapsus := Seconds() - nLapsus

       ::lOpen := .T.

IF ::lDbg

    MsgInfo( nLapsus, '2' )

    cTxt := '::oRs:Source          ' + Chr( VK_TAB ) + cValToChar(::oRs:Source         ) + CRLF +;
            '::oRs:CursorLocation  ' + Chr( VK_TAB ) + cValToChar(::oRs:CursorLocation ) + CRLF +;
            '::oRs:LockType        ' + Chr( VK_TAB ) + cValToChar(::oRs:LockType       ) + CRLF +;
            '::oRs:CursorType      ' + Chr( VK_TAB ) + cValToChar(::oRs:CursorType     ) + CRLF +;
            '::oRs:CacheSize       ' + Chr( VK_TAB ) + cValToChar(::oRs:CacheSize       )

    MsgInfo( cTxt, '::Open(3)' )

ENDIF

       ::Structure()

     CATCH oError


       ::cError :=  oError:description + ' => ' + oError:operation

       IF ::oAdoConnection:lMessage
          MsgStop( ::cError, 'Ado Connection')
       ENDIF

* ---- Aqui no va, no se per que..
*       FOR EACH oError IN oConn:Errors
*           ::cError := zAdoError( oError, ::oAdoConnection:lMessage )
*       NEXT
* --------------------------------
       RETU .F.

    END

RETU .T.


*-------------------------------------
METHOD Structure() CLASS zAdoRS
*-------------------------------------
    LOCAL nI

    ::nFields   := ::oRs:Fields:Count
    ::aFldNames := Array( ::nFields )
    ::aStruct   := Array( ::nFields )

    FOR nI := 1 TO ::nFields

        ::aStruct  [ nI ] := { ::oRs:Fields(nI-1):Name , ;
                               ColType( ::oRs:Fields(nI-1):Type ) , ;
                               ::oRs:Fields(nI-1):DefinedSize ,;
                               IF( ColType( ::oRs:Fields(nI-1):Type ) == 'N', ::oRs:Fields(nI-1):NumericScale, 0 ) }

        ::aFldNames[ nI ] := ::aStruct[ nI ][ 1 ]

    NEXT

*       ::aFldType  := Array( nLen )
*       ::aModify   := Array( nLen )
*       ::aLoad     := Array( nLen )
*       ::aBuffer   := Array( nLen )

RETU NIL

//-> Funcio Adolfo

STATIC FUNCTION ColType( xType )
*-------------------------------
   LOCAL cType:="N"

   DO CASE
      CASE xType = adArray
           cType = "A"

      CASE xType = adBSTR         .or. ;
           xType = adChar         .or. ;
	   xType = adVarChar      .or. ;
	   xType = adLongVarChar  .or. ;
 	   xType = adWChar        .or. ;
	   xType = adVarWChar     .or. ;
	   xType = adLongVarWChar

           cType = "C"

      CASE xType = adDate .or. ;
           xType = adDBDate

           cType = "D"

      CASE xType = adBoolean

           cType = "L"

      CASE xType = adEmpty         .or. ;
           xType = adError         .or. ;
           xType = adUserDefined   .or. ;
           xType = adBinary        .or. ;
           xType = adVarBinary     .or. ;
           xType = adLongVarBinary .or. ;
           xType = adIUnknown      .or. ;
           xType = adGUID          .or. ;
           xType = adVariant       .or. ;
           xType = adIDispatch     .or. ;
           xType = adIUnknown      .or. ;
           xType = adGUID          .or. ;
           xType = adChapter       .or. ;
           xType = adFileTime      .or. ;
           xType = adPropVariant

           cType = "U"

   ENDCASE

RETU cType
