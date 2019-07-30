#include "FiveWin.ch"
#include "error.ch"

#define NTRIM(n)    ( LTrim( Str( n ) ) )

#define DBS_NAME   1
#define DBS_TYPE   2
#define DBS_LEN    3
#define DBS_DEC    4


#define ERROR_DBF_OPEN      1
#define ERROR_DBF_CRYPT    10

*-------------
CLASS zFileDbf
*-------------

   DATA   cFile, cCdx, cFpt
   DATA   cAlias
   DATA   nArea
   DATA   lExclusive
   DATA   lMemo
   DATA   lRead
   DATA   lOpen
   DATA   lCrypt
   DATA   lAutoCrypt
   DATA   cRdd
   DATA   cError
   DATA   nError
   DATA   nSubcode
   DATA   cPassword
   DATA   nTime
   DATA   lDebug

   METHOD New( cFile, cCdx )  CONSTRUCTOR

   METHOD Open()
   METHOD End()
   METHOD Close()             INLINE ::End()

ENDCLASS


*--------------------------------------
METHOD New( cFile, cCdx ) CLASS zFileDbf
*--------------------------------------

    DEFAULT cFile := ''
    DEFAULT cCdx  := ''

    ::cAlias      := ''
    ::cFile       := cFile
    ::cCdx        := cCdx
    ::cFpt        := ''
    ::cRdd        := RddSetDefault()
    ::lExclusive  := Set( _SET_EXCLUSIVE )
    ::lRead       := .f.
    ::lOpen       := .f.
    ::lMemo       := .f.
    ::lCrypt      := .f.
    ::lAutoCrypt  := .f.
    ::cError      := ''
    ::nError      := 0
    ::nSubCode    := 0
    ::cPassword   := 'NAP'
    ::nTime       := 5
    ::lDebug      := .f.


RETU Self

*--------------------------
METHOD End() CLASS zFileDbf
*--------------------------

    IF ::lOpen
       IF Select( ::cAlias ) > 0
         (::cAlias)->( DbCloseArea() )
       ENDIF
       ::cAlias := ''
       ::lOpen  := .f.
    ENDIF

RETU NIL

*--------------------------
METHOD Open() CLASS zFileDbf
*--------------------------
    LOCAL lOk         := .f.
    LOCAL cError      := ''
    LOCAL bError
    LOCAL oError
    LOCAL nInici
    LOCAL nLapsus
    LOCAL aSt

    IF !File( ::cFile )
       ::cError :=  'Tabla de datos no existe: ' + ::cFile
       RETU .F.
    ENDIF

    IF !Empty( ::cCdx ) .AND. !File( ::cCdx )
       ::cError :=  'Indice de Tabla no existe: ' + ::cCdx
       RETU .F.
    ENDIF

    nInici   := Seconds()
    nLapsus  := ::nTime
    bError   := Errorblock({ |o| ErrorHandler(o) })

    BEGIN SEQUENCE

          WHILE nLapsus >= 0

             IF Empty( ::cAlias )
                ::cAlias := ZNewAlias( cFileNoExt( ::cFile ) )
             ENDIF

*msginfo( 'File ' + ::cFile + CRLF + ;
*         'Cdx ' + ::cCdx + CRLF + ;
*         'Rdd ' + ::cRdd + CRLF + ;
*         'Alias ' + ::cAlias )

             DbUseArea( .T., ::cRDD, ::cFile, ::cAlias, ! ::lExclusive, ::lRead )

             IF !Neterr() .OR. ( nLapsus == 0 )
                 EXIT
             ENDIF

             SysWait( 0.1 )

             nLapsus := ::nTime - ( Seconds() - nInici )

             SysRefresh()

          END

          IF NetErr()
             ::cError := 'Error de apertura de: ' + ::cFile
            ELSE
             ::cAlias := Alias()
             ::lOpen  := .t.
          ENDIF

       RECOVER USING oError


          ::nError    := ERROR_DBF_OPEN
          ::nSubcode  := oError:Subcode

          ::cError += if( ValType( oError:SubSystem   ) == "C", oError:SubSystem(), "???" )
          ::cError += if( ValType( oError:SubCode     ) == "N", "/" + NTRIM( oError:SubCode ), "/???" )
          ::cError += if( ValType( oError:Description ) == "C", "  " + oError:Description, "" )

   END SEQUENCE


   IF ::lOpen

      ::nArea := Select()

      aSt     := (::cAlias)->( DbStruct() )

      IF Ascan( aSt, {|x| x[ DBS_TYPE ] == 'M' } ) > 0
        ::lMemo := .t.
        ::cFpt  := cFilePath( ::cFile ) + cFileNoExt( ::cFile ) + '.fpt'
      ENDIF

/* ADS
      IF ::lCrypt

         IF (::cAlias)->( ADSIsTableEncrypted() )

            IF (::cAlias)->( ADSEnableEncryption( ::cPassword ) ) > 0

               AdsGetLastError(@cError)
               ::cError := cError
               ::End()
               RETU ::lOpen
            ENDIF

           ELSE

              IF (::cAlias)->( ADSEnableEncryption( ::cPassword ) ) > 0

                 AdsGetLastError(@cError)
                 ::cError := cError
                 ::End()
                 RETU ::lOpen

               ELSE

                 IF (::cAlias)->( ADSEncryptTable() ) > 0
                    AdsGetLastError(@cError)
                    ::cError := cError
                    ::End()
                 RETU ::lOpen

                 ENDIF

              ENDIF

            ENDIF

        ELSE

          IF (::cAlias)->( ADSIsTableEncrypted() )

             ::cError := 'Tabla encryptada. Abrir con password'
             ::nError := ERROR_DBF_CRYPT
             ::End()
             RETU ::lOpen
          ENDIF

      ENDIF

*/

    BEGIN SEQUENCE

        IF !Empty( ::cCdx )

            SET INDEX TO ( ::cCdx )

           ELSE

             (::cAlias)->( OrdListClear() )

        ENDIF

     RECOVER USING oError


        ::nError    := ERROR_DBF_OPEN
        ::nSubcode  := oError:Subcode

        ::cError += if( ValType( oError:SubSystem   ) == "C", oError:SubSystem(), "???" )
        ::cError += if( ValType( oError:SubCode     ) == "N", "/" + NTRIM( oError:SubCode ), "/???" )
        ::cError += if( ValType( oError:Description ) == "C", "  " + oError:Description, "" )

   END SEQUENCE


   ENDIF

   Errorblock(bError)

RETU ::lOpen

*-----------------------------------
STATIC FUNCTION ErrorHandler(oError)
*-----------------------------------

    BREAK oError

RETU NIL
