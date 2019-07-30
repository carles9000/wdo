#include "FiveWin.ch"

#define AE_LOCK_FAILED 5035

STATIC oConnDbf
STATIC oConnAccess
STATIC oConnFb


*-------------------
FUNCTION zAdoTest1()  // Seleccionar Proveedor i mostrar info de conexion
*-------------------
    LOCAL oCon  := zAdoConnection():New()

    IF oCon:Open()
       oCon:ShowInfo()
       oCon:Close()
    ENDIF

RETU NIL

*-------------------
FUNCTION zAdoTest2() // Selecciona Proveedor i salvamos nuestra configuracion
*-------------------

    LOCAL oCon      := zAdoConnection():New()
    LOCAL cSection  := Space(20)

    IF oCon:Open()
       oCon:ShowInfo()
       IF MsgYesNo( 'Salvar Configuracio?', 'Sistema' )
          IF MsgGet('Cadena conexio', 'Etiqueta', @cSection )
             cSection := Upper( Alltrim( cSection ) )
             oCon:SaveConfig( cSection )
             MsgInfo( 'Info salvada con etiqueta ' + cSection )
          ENDIF
       ENDIF
       oCon:Close()
    ENDIF

RETU NIL


*-------------------
FUNCTION zAdoTest3()  // Cargamos conexion i conectamos con proveedor
*-------------------
    LOCAL oCon      := zAdoConnection():New()
    LOCAL cSection  := Space(20)

    IF MsgYesNo( 'Cargar Configuracio?', 'Sistema' )

       IF MsgGet('Cadena conexio', 'Etiqueta', @cSection )

         cSection := Upper( Alltrim( cSection ) )

         oCon:LoadConfig( cSection )

         IF oCon:Open()
            oCon:ShowInfo()
            oCon:Close()
           ELSE
            MsgAlert( oCon:cError, 'Error' )
         ENDIF

       ENDIF

    ENDIF

RETU NIL


FUNCTION zAdoTest40()  // Conectem amb un driver per DBF
*--------------------
    LOCAL cString, cPath

    IF ValType( oConnDbf ) <> 'O'

       cPath   := HB_CurDrive() + ':\' + CurDir() + '\DAT'
       cString := 'Driver={Microsoft dBASE Driver (*.dbf)};' + ;
                  'DriverID=277;Dbq=' + cPath

       oConnDbf := zAdoConnection():New( cString )

       IF oConnDbf:Open()
          oConnDbf:ShowInfo()
         ELSE
           MsgAlert( oConnDbf:cError, 'Error' )
           oConnDbf:End()
       ENDIF

      ELSE

*        oConnDbf:ShowInfo()

    ENDIF

RETU oConnDbf

*-------------------
FUNCTION zAdoTest41()  // Conectem amb un driver per ACCESS
*-------------------
    LOCAL cString, cPath

    IF ValType( oConnAccess ) <> 'O'

       cPath   := HB_CurDrive() + ':\' + CurDir() + '\Dat\Taller.mdb'
       cString := "Provider=Microsoft.Jet.OLEDB.4.0;" + ;
                  "Data Source=" + cPath + ";User Id=;Password=;"

       oConnAccess := zAdoConnection():New( cString )

       IF oConnAccess:Open()
          oConnAccess:ShowInfo()
         ELSE
           MsgAlert( oConnAccess:cError, 'Error' )
           oConnAccess:End()
       ENDIF

      ELSE

*        oConnAccess:ShowInfo()

    ENDIF

RETU oConnAccess

*-------------------
FUNCTION zAdoTest42()  // Conectem amb un driver per FIREBIRD
*-------------------
    LOCAL cString, cPath

    IF ValType( oConnAccess ) <> 'O'

       cPath   := Hb_CurDrive() + ':\' + CurDir() + '\Dat\Taller.mdb'
       cString := "Provider=Microsoft.Jet.OLEDB.4.0;" + ;
                  "Data Source=" + cPath + ";User Id=;Password=;"

       oConnAccess := zAdoConnection():New( cString )

       IF oConnAccess:Open()
          oConnAccess:ShowInfo()
         ELSE
           MsgAlert( oConnAccess:cError, 'Error' )
           oConnAccess:End()
       ENDIF

      ELSE

*        oConnAccess:ShowInfo()

    ENDIF

RETU oConnAccess

*--------------------
FUNCTION zAdoTest43()  // Cargamos conexion i conectamos con proveedor
*--------------------
    LOCAL oCon      := zAdoConnection():New()
    LOCAL cSection  := Space(20)

    oCon:LoadConfig( 'FERRE' )

    IF oCon:Open()
       oCon:ShowInfo()
      ELSE
       MsgAlert( oCon:cError, 'Error' )
    ENDIF


RETU oCon

*----------------------------
FUNCTION zAdoGetConn( cType )
*----------------------------
    LOCAL oConn

    DO CASE
       CASE cType == 'DBF'    ; oConn  := zAdoTest40()
       CASE cType == 'ACCESS' ; oConn  := zAdoTest41()
       CASE cType == 'MYSQL'  ; oConn  := zAdoTest43()
    ENDCASE

RETU oConn

*---------------------
FUNCTION zAdoSelConn()
*---------------------
    LOCAL nOp := Alert( "Tipus de BD",;
                        { "&DBFCDX", "ACCESS", "MYSQL" },;
                        "Please, select" )

RETU nOp

FUNCTION zAdoGetTables( cType )
*------------------------------
    LOCAL oConn

    DO CASE
       CASE cType == 'ACCESS'
            oConn := zAdoGetConn( cType )
            zAdoTables( oConn )
       CASE cType == 'DBF'
            oConn := zAdoGetConn( cType )
            zAdoTables( oConn )
       CASE cType == 'MYSQL'
            oConn := zAdoGetConn( cType )
            zAdoTables( oConn )
    ENDCASE

RETU NIL

