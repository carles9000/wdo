#include 'fivewin.ch'

*------------------
FUNCTION zTestDat()
*------------------

    LOCAL oFTest   := zOpenTest()
    LOCAL oFCust   := zOpenCust()
    LOCAL oTest, oCust
    LOCAL oDb

// Tindrem 3 maneres de treballar amb DBF's

/* 1.- zFileDbf()

   Es crea un objecte q se encarrega d'obrir la taula i si hi ha index
   Ens controla el proces d'obertura i tancament, i tenim un ::cAlias
*/

MsgInfo( 'Test zFileDbf()' )

    oFTest   := zOpenTest()   // Obrim Test.dbf i Test.cdx
    oFCust   := zOpenCust()   // Obrim Customer.dbf

    MsgInfo( 'oFTest ' + cValToChar( oFTest:lOpen ) + CRLF + ;
             'oFCust ' + cValToChar( oFCust:lOpen ) )

    MsgInfo( (oFTest:cAlias)->first + ' ' + (oFTest:cAlias)->last, oFTest:cFile )
    MsgInfo( (oFCust:cAlias)->first + ' ' + (oFCust:cAlias)->last, oFCust:cFile )

/* 2.- zRdd()

   Es crea un objecte amb tots els comandaments RDD()
*/

MsgInfo( 'Test zRdd()' )

    IF oFTest:lOpen

       oTest := zSetRdd( oFTest )

       MsgInfo( oTest:First + ' ' + oTest:Last, oTest:cAlias + '  Reg: ' + str(oTest:Recno())  )

       oTest:End()


    ENDIF

    IF oFCust:lOpen

       oCust := zSetRdd():New( oFCust )
       MsgInfo( oCust:First + ' ' + oCust:Last, oCust:cAlias + '  Reg: ' + str(oCust:Recno()) )
       oCust:Skip()
       MsgInfo( oCust:First + ' ' + oCust:Last, oCust:cAlias + '  Reg: ' + str(oCust:Recno())  )

       MsgInfo( 'Test xBrowse()' )

       oCust:Browse()

       oCust:End()

    ENDIF



/* 3.- zDb()

   Obrim una serie de Taules. El Process s'encarrega al iniciar un modul
   d'obrir les taules pertienents i controlar el fluxe. En el cas de no
   obrirse, tancara tot el q ha obert
*/

MsgInfo( '1 Test zDb() - Tot Obert ' )


    oDb := ZDb():New()

    oDb:Add( 'TEST' , {|| zOpenTest() } )
    oDb:Add( 'CUST' , {|| zOpenCust() } )

    IF oDb:Open()

       MsgInfo( oDb:test:first() + ' -> ' + oDb:test:last(), oDb:Test:cAlias )
       MsgInfo( oDb:Cust:first() + ' -> ' + oDb:Cust:last(), oDb:Cust:cAlias )

       oDb:End()

    ENDIF

MsgInfo( '2 Test zDb() - No pot obrir una taula ' )


    oDb := ZDb():New()

    oDb:Add( 'TEST'  , {|| zOpenTest()  } )
    oDb:Add( 'CUST'  , {|| zOpenCust()  } )
    oDb:Add( 'DUMMY' , {|| zOpenDummy() } )

    IF ! oDb:Open()

       oDb:MsgError()

    ENDIF


RETU NIL
