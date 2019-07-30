#include 'Fivewin.ch'

*-------------------------------------------
FUNCTION zRLock( nTemps, bBloc, xIdentidad )
*-------------------------------------------
    LOCAL nInici      := 0
    LOCAL nlapsus     := 0
    LOCAL lSeguir     := .T.
    LOCAL lBloqueig   := .F.

    DEFAULT nTemps    := 5
    DEFAULT bBloc     := { || .T. }

    IF Empty( alias() )
       RETU .f.
    ENDIF

    nInici   := seconds()
    nLapsus  := nTemps

    WHILE nLapsus >= 0 .and. lSeguir

       lBloqueig := DbRlock( xIdentidad )

       IF !Neterr() .or. ( nLapsus == 0 )
           EXIT
       ENDIF

       SysWait( 0.1 )

       lSeguir := Eval( bBloc, ( Seconds() - nInici ) )

       nLapsus := nTemps - ( seconds() - nInici )

       SysRefresh()

    END

RETU lBloqueig

*---------------------------------------------
FUNCTION zAppend( nTemps, bBloc, lLiberaBloq )
*---------------------------------------------

    LOCAL nInici        := 0
    LOCAL nlapsus       := 0
    LOCAL lSeguir       := .T.

    DEFAULT nTemps      := 5
    DEFAULT bBloc       := { || .T. }
    DEFAULT lLiberaBloq := .T.

    IF Empty( Alias() )
       RETU .f.
    ENDIF

    nInic    := seconds()
    nLapsus  := nTemps

    WHILE nLapsus >= 0 .and. lSeguir

       DbAppend( lLiberaBloq )

       IF !Neterr() .or. ( nLapsus == 0 )
           EXIT
       ENDIF

       SysWait( 0.1 )

       lSeguir := Eval( bBloc, ( Seconds() - nInici ) )

       nLapsus := nTemps - ( seconds() - nInici )

       SysRefresh()

    END

RETU IF( !Neterr(), .t., .f. )

*--------------------------------------------
FUNCTION zDelete( nTemps, bBloc, xIdentidad )
*--------------------------------------------
    LOCAL lBloqueig   := .F.

    IF Empty( alias() )
       RETU .f.
    ENDIF

    lBloqueig := zRLock( nTemps, bBloc, xIdentidad )

    IF lBloqueig
       DbDelete()
    ENDIF

RETU lBloqueig
