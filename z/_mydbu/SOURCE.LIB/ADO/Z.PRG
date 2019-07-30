#INCLUDE "FIVEWIN.CH"
#INCLUDE "HBADO.CH"

static oRs, oCon

FUNCTION Main()

    MsgInfo( 'Hola' )

    ConnectMDB()
    Taules()
    ExeSQL( 'Select * from empleados' )

RETU NIL

static function ConnectMDB

   local lConnect := .f.
   local cStr   := "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + ;
                   ".\Taller.mdb;User Id=;Password=;"

   if oCon == nil
      oCon                     := TOleAuto():new("ADODB.Connection")
      oCon:ConnectionString   := cStr
      oCon:Open()
   endif

retu NIL

Function Taules()
        LOCAL oTables := oCon:OpenSchema(adSchemaTables)
        LOCAL cInfo   := ''

        oTables:Filter := "TABLE_TYPE = 'TABLE'"

        WHILE !oTables:Eof

                cInfo += oTables:Fields(2):Value + Space(4) + Chr( VK_TAB )
                cInfo += oTables:Fields(5):Value
                cInfo += CRLF
                oTables:MoveNext()
	END

        oTables:Close()

        MsgInfo( cInfo )

RETURN Nil

Function ExeSql( cSql )

        LOCAL oRs
        Local cInfo  := ''

      oRs                       := TOleAuto():new( "ADODB.RecordSet" )
      oRs:ActiveConnection      := oCon
      oRs:Source                := cSql
      oRs:LockType              := 1            // adLockReadOnly
      oRs:CursorLocation        := 3            // adUseClient
      oRs:CacheSize             := 100
      oRs:Open()

      WHILE !oRs:Eof

              cInfo += Str( oRs:Fields(0):Value, 4, 0 ) + ' ' + Chr( VK_TAB )
              cInfo +=      oRs:Fields(1):Value         + ' ' + Chr( VK_TAB )
              cInfo +=      oRs:Fields(2):Value         + ' ' + Chr( VK_TAB )
              cInfo +=      oRs:Fields(3):Value         + ' ' + Chr( VK_TAB )
              cInfo += DToC(oRs:Fields(5):Value )       + ' ' + Chr( VK_TAB )
              cInfo += CRLF
              oRs:MoveNext()
      END

      oRs:Close()

      MsgInfo( cInfo )

RETURN Nil
