#include "FiveWin.ch"
#include ".\include\ado.ch"

*----------------------
FUNCTION zAdoDataLink()
*----------------------
   LOCAL oDataLink := TOleAuto():New("Datalinks") ,;
         oConn     := oDataLink:PromptNew()

RETU IF( oConn != NIL, oConn:connectionString, '' )

*----------------------------
FUNCTION zAdoTables( ozConn )
*----------------------------
    LOCAL oTables
    LOCAL cInfo   := ''
    LOCAL oCon    := ozConn:oConn
    LOCAL cName, cDescription

    IF ! zAdoIsConn( oCon )
       RETU ''
    ENDIF

    oTables := oCon:OpenSchema(adSchemaTables)
    cInfo   := ''

    oTables:Filter := "TABLE_TYPE = 'TABLE'"

    WHILE !oTables:Eof

       cName        := oTables:Fields(2):Value
       cDescription := IF( oTables:Fields(5):Value == NIL, '', oTables:Fields(5):Value )

       cInfo += cName + Space(4) + Chr( VK_TAB ) + cDescription
       cInfo += CRLF

       oTables:MoveNext()

    END

    oTables:Close()

    MsgInfo( cInfo )

RETU nil


*-------------------------------------
FUNCTION zAdoError( oError, lMessage )
*-------------------------------------
    LOCAL cError := .T.

    DEFAULT lMessage := .T.

*        MsgStop( 'Error: ' + oError:description + ' => ' + CRLF + ;
*                             oError:operation, 'Sistema'  )

    cError := "Descripción  "  + Chr( VK_TAB) + ": " + oError:Description              + CRLF + CRLF +  ;
              "Error Nativo  " + Chr( VK_TAB) + ": "  + Ltrim(Str(oError:NativeError)) + CRLF + ;
              "Número Error  " + Chr( VK_TAB) + ": "  + Ltrim(Str(oError:Number))      + CRLF + ;
              "Origen        " + Chr( VK_TAB) + ": "  + oError:Source                  + CRLF + ;
              "EszAdo SQL  "   + Chr( VK_TAB) + ": "  + oError:SQLState

    IF lMessage
       MsgStop( cError, 'Ado Connection' )
    ENDIF

RETU cError

*----------------------
FUNCTION zRsInfo( oRs )
*----------------------
    LOCAL cMsg := ''

    cMsg += 'State         ' + Chr( VK_TAB ) + Ltrim(Str(oRs:state   )) + CRLF
    cMsg += 'Status        ' + Chr( VK_TAB ) + Ltrim(Str(oRs:status  )) + CRLF
    cMsg += 'EditMode      ' + Chr( VK_TAB ) + Ltrim(Str(oRs:editmode)) + CRLF
    cMsg += 'LockType      ' + Chr( VK_TAB ) + Ltrim(Str(oRs:locktype)) + CRLF
    cMsg += 'CacheSize     ' + Chr( VK_TAB ) + Ltrim(Str(oRs:cacheSize)) + CRLF
    cMsg += 'MaxRecords    ' + Chr( VK_TAB ) + Ltrim(Str(oRs:maxrecords)) + CRLF
    cMsg += 'PageCount     ' + Chr( VK_TAB ) + Ltrim(Str(oRs:pagecount )) + CRLF
    cMsg += 'PageSize      ' + Chr( VK_TAB ) + Ltrim(Str(oRs:pagesize  )) + CRLF
    cMsg += 'RecordCount   ' + Chr( VK_TAB ) + Ltrim(Str(oRs:recordcount)) + CRLF
    cMsg += 'CursorLocation' + Chr( VK_TAB ) + Ltrim(Str(oRs:cursorlocation)) + CRLF
    cMsg += 'CursorType    ' + Chr( VK_TAB ) + Ltrim(Str(oRs:cursortype)) + CRLF

    MsgInfo( cMsg, 'Info RecordSet' )

RETU NIL

*---------------------------
FUNCTION zAdoIsConn( oConn )
*---------------------------

    IF ValType( oConn ) <> 'O'
       RETU .F.
    ENDIF

    IF oConn:State <> adStateOpen
       IF oConn:lMessage
          MsgAlert( 'Connection state: ' + ltrim(Str(oConn:State)), 'ADO Connection' )
       ENDIF
       RETU .F.
    ENDIF

RETU .T.

