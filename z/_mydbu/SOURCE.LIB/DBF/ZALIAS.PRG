#include 'fivewin.ch'

*----------------------------
FUNCTION ZNewAlias( cDbfNom )
*----------------------------

    LOCAL n      := 0
    LOCAL cAlias

    DEFAULT cDbfNom := 'ALIAS'

    cDbfNom := cFileNoExt( cDbfNom )

    cAlias  := cDbfNom + Ltrim(Str(n++))

    WHILE Select(cAlias) != 0
          cAlias := cDbfNom + Ltrim(Str(n++))
    END

RETU cAlias
