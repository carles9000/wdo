#include "fivewin.ch"

*--------------------------------------
FUNCTION zNewoDbf( cDbf, cCdx, lCrypt )
*--------------------------------------
    LOCAL oApp          := zApp():New()
    LOCAL oFileDbf
    LOCAL cFile         := oApp:cServer + '\' + cDbf
    LOCAL cIndex        := NIL

    DEFAULT lCrypt := .f.

    IF ValType( cCdx ) == 'C'
       cIndex := oApp:cServer + '\' + cCdx
    ENDIF

    oFileDbf      := zFileDbf():New( cFile, cIndex )

*    oFileDbf:lCrypt     := lCrypt   // ADS
*    oFileDbf:cPassword  := 'NAP'    // ADS
    oFileDbf:lExclusive := .f.

    oFileDbf:Open()

RETU oFileDbf

//-- TEST ------------------------------------------------------------------//

FUNCTION zOpenTest()     ; RETU zNewoDbf( 'Test.dbf'     , 'Test.cdx'    , .t. )
FUNCTION zOpenCust()     ; RETU zNewoDbf( 'Customer.dbf' )
FUNCTION zOpenDummy()    ; RETU zNewoDbf( 'dummy.dbf' )

//--------------------------------------------------------------------------//
