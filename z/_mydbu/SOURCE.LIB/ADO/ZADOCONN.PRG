/*
 *  (c) 2008 Carles Aubia
 *
 *  Inspirat en idees i clases de Carlos Mora i Biel
 *
 */

#include "Fivewin.ch"
#include ".\include\ado.ch"

*-------------------
CLASS zAdoConnection
*-------------------

   DATA cConnString        AS CHARACTER INIT ''
   DATA cUser              AS CHARACTER INIT ''
   DATA cPass              AS CHARACTER INIT ''
   DATA nOptions
   DATA lFromUser          AS LOGICAL
   DATA CommandTimeOut     AS NUMERIC
   DATA ConnectionTimeOut  AS NUMERIC
   DATA CursorLocation     AS NUMERIC
   DATA lMessage           AS LOGICAL   INIT    .T.
   DATA lActive            AS LOGICAL   INIT    .F.
   DATA cError             AS CHARACTER INIT    ''
   DATA cIni               AS CHARACTER INIT    HB_CurDrive() + ':\' + CurDir() + '\Ado.ini'

   DATA oConn              AS OBJECT
   DATA oRS                AS OBJECT

   METHOD New( cString, cUser, cPassword, nOptions, lFromUser ) CONSTRUCTOR
   METHOD Open()
   METHOD Close()
   METHOD End()                       INLINE  ::Close()
   METHOD Execute( cCommand, nCount, nOptions )

   METHOD BeginTrans()                INLINE ::oConn:BeginTrans()
   METHOD CommitTrans()               INLINE ::oConn:CommitTrans()
   METHOD RollbackTrans()             INLINE ::oConn:RollbackTrans()

   METHOD ShowInfo()
   METHOD LoadConfig( cProvider )
   METHOD SaveConfig( cProvider )

ENDCLASS


*--------------------------------------------------------------------------------
METHOD New( cString, cUser, cPassword, nOptions, lFromUser ) CLASS zAdoConnection
*--------------------------------------------------------------------------------
   LOCAL oError
   LOCAL lError := .F.

   DEFAULT lFromUser := Empty( cString )

   TRY

      ::oConn := TOleAuto():new("ADODB.Connection")

   CATCH oError

      FOR EACH oError IN ::oConn:Errors
          ::cError := zAdoError( oError, ::lMessage )
      NEXT

      lError := .T.

   END

   IF ! lError

      ::cConnString       := IF( Valtype( cString   ) == 'C', cString  , '' )
      ::cUser             := IF( Valtype( cUser     ) == 'C', cUser    , '' )
      ::cPass             := IF( Valtype( cPassword ) == 'C', cPassword, '' )
      ::nOptions          := nOptions
      ::lFromUser         := lFromUser

      ::CommandTimeOut    := 5
      ::ConnectionTimeOut := 10
      ::CursorLocation    := adUseClient

   ENDIF

RETU Self


*---------------------------------
METHOD Open() CLASS zAdoConnection
*---------------------------------
   LOCAL oError
   LOCAL lOpen  := .F.

   IF ::oConn != NIL

      IF ::oConn:State != adStateClosed
         ::oConn:Close()
      ENDIF

   ENDIF

   IF ::lFromUser

      ::cConnString := zAdoDatalink()

   ENDIF

   IF Empty( ::cConnString )
      ::cError := 'No existe cadena de conexion'
      RETU .F.
   ENDIF

   TRY

      ::oConn:Open( ::cConnString, ::cUser, ::cPass, ::nOptions )

      lOpen := .T.

    CATCH oError

       ::cError :=  oError:description + ' => ' + oError:operation

       IF ::lMessage
          MsgStop( ::cError, 'Ado Connection')
       ENDIF

* ---- Aqui no va, no se per que..
*      FOR EACH oError IN ::oConn:Errors
*          ::cError := zAdoError( oError, ::lMessage )
*      NEXT
* ---------------------------------------------------

   END

RETU lOpen

*----------------------------------
METHOD Close() CLASS zAdoConnection
*----------------------------------
   LOCAL oError

   IF ::oRS != NIL

      IF ::oRS:State == adStateOpen
         ::oRS:Close()
         ::oRS:= NIL
      ENDIF

   ENDIF

   TRY

      ::oConn:Close()
      ::oConn:= NIL

    CATCH oError

      FOR EACH oError IN ::oConn:Errors
          ::cError := zAdoError( oError, ::lMessage )
      NEXT

   END

RETU NIL

*-----------------------------------------------------------------
METHOD Execute( cCommand, nRecAff, nOptions ) CLASS zAdoConnection
*-----------------------------------------------------------------
   LOCAL oError
   LOCAL lResult := .T.

   DEFAULT nRecAff := 0

   /* A closed Recordset object will be returned if it is not a row-returning query.
      The returned Recordset is always a read-only, forward-only Recordset!
      To create a Recordset with more functionality, first create a Recordset object.
      Set the desired properties, and then use the Recordset object's Open method to execute the query.
   */

   IF ::oRS != NIL

      IF ::oRS:State == adStateOpen
         ::oRS:Close()
         ::oRS:= NIL
      ENDIF

   ENDIF

   TRY

      ::oRS := ::oConn:Execute( cCommand, @nRecAff, nOptions)

    CATCH oError

      lResult := .F.

      FOR EACH oError IN ::oConn:Errors
          ::cError := zAdoError( oError, ::lMessage )
      NEXT

   END

RETU lResult

*-------------------------------------
METHOD ShowInfo() CLASS zAdoConnection
*-------------------------------------
    LOCAL cInfo      := ''

    cInfo += 'Version Ado       '  + Chr( VK_TAB ) + Chr( VK_TAB ) + ': '  + Alltrim( cValToChar( ::oConn:Version()            )) + CRLF
    cInfo += 'Provider          '  + Chr( VK_TAB ) + Chr( VK_TAB ) + ': '  + Alltrim( cValToChar( ::oConn:Provider()           )) + CRLF
    cInfo += 'Mode              '  + Chr( VK_TAB ) + Chr( VK_TAB ) + ': '  + Alltrim( cValToChar( ::oConn:Mode()               )) + CRLF
    cInfo += 'State             '  + Chr( VK_TAB ) + Chr( VK_TAB ) + ': '  + Alltrim( cValToChar( ::oConn:State()              )) + CRLF
    cInfo += 'CursorLocation    '  + Chr( VK_TAB ) + Chr( VK_TAB ) + ': '  + Alltrim( cValToChar( ::oConn:CursorLocation()     )) + CRLF
    cInfo += 'Connection TimeOut'  + Chr( VK_TAB ) + ': '  + Alltrim( cValToChar( ::oConn:ConnectionTimeOut()  )) + CRLF
    cInfo += 'Command TimeOut   '  + Chr( VK_TAB ) + ': '  + Alltrim( cValToChar( ::oConn:CommandTimeOut()     )) + CRLF + CRLF
    cInfo += 'Connection String '  + CRLF
    cInfo += ::oConn:ConnectionString()

    MsgInfo( cInfo, 'Info Connection' )

RETU NIL

*--------------------------------------------------
METHOD LoadConfig( cProvider ) CLASS zAdoConnection
*--------------------------------------------------
    LOCAL oIni
    LOCAL cSection  := 'Provider'

    IF Valtype( cProvider ) == 'C'
       cSection += ' ' + cProvider
    ENDIF

    INI oIni FILE ::cIni

      GET ::cConnString SECTION cSection ENTRY "Datalink" DEFAULT "" OF oIni

    ENDINI

    ::lFromUser := .F.

RETU NIL

*--------------------------------------------------
METHOD SaveConfig( cProvider ) CLASS zAdoConnection
*--------------------------------------------------
    LOCAL oIni
    LOCAL cSection  := 'Provider'

    IF Valtype( cProvider ) <> 'C' .OR. Empty( cProvider )
       RETU NIL
    ENDIF

    cSection += ' ' + cProvider

    INI oIni FILE ::cIni

      SET SECTION cSection ENTRY "Datalink" TO ::oConn:ConnectionString  OF oIni

    ENDINI

RETU NIL
