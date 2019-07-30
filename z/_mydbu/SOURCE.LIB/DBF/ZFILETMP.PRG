#include 'Fivewin.ch'

*-----------------------------------------
FUNCTION zFileTmp( cPath, cPrefixe, cExt )
*-----------------------------------------
    LOCAL nContador  := 0
    LOCAL nAmpla     := 0
    LOCAL cFila      := ''
    LOCAL oApp

    IF cPath == NIL
       oApp  := zApp():New()
       cPath := oApp:cDirTmp
    ENDIF

    DEFAULT cPrefixe   := "TMP"
    DEFAULT cExt       := ""

    IF Right( cPath, 1 ) == '\'
       cPath := Substr( cPath, 1, Len(cPath)-1 )
    ENDIF

    nAmpla := 8 - Len( cPrefixe )

    FOR nContador := 1 TO 99999

        IF Empty( cExt )
           cFila := cPath + '\' + cPrefixe + PADL( nContador, nAmpla, "0" )
          ELSE
           cFila := cPath + '\' + cPrefixe + PADL( nContador, nAmpla, "0" ) + '.' + cExt
        ENDIF

        IF ! File( cFila )
             EXIT
        ENDIF

    NEXT

RETU cFila
