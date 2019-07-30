// Testing an Object Inspector

#INCLUDE "FIVEWIN.CH"
#INCLUDE "FOLDER.CH"

 #DEFINE VAR_TYPE    1
 #DEFINE VAR_MESS    2
 #DEFINE VAR_VALUE   3

 STATIC oInspect
 static oWnd

/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  EXPORTED FUNCTION INSPECTOR                         ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹› */

 FUNCTION zInsp( oClient, cVarName )
 LOCAL ;
    oWnd,;
    oFont,;
    oTabs,;
    oList,;
    oCombo,;
    cCombo

    oInspect := TINSPECT():new( oClient, cVarName )


    DEFINE WINDOW oWnd FROM 2, 3 TO 26, 34 ;
     TITLE "Inspector" ;
     COLOR "N/W"


     DEFINE FONT oWnd:oFont NAME "Ms Sans Serif" SIZE 0, -8
     DEFINE FONT oFont NAME "Ms Sans Serif" SIZE 0, -8 BOLD

     @ 26,3 LISTBOX oList FIELDS "" OF oWnd ;
            SIZE 198, 310 ;
            COLSIZES 16, 100, 200 ;
            HEADERS "&", "Data", "Value" ;
            PIXEL ;
            ON DBLCLICK oInspect:Select()

     @ 3,3  Combobox oCombo VAR cCombo OF oWnd ;
            ITEMS { oInspect:cClient } ;
            PIXEL SIZE oWnd:nWidth - 10 , 80 ;
            FONT oFont ;
            ON CHANGE ( oInspect:aClient[::nAt]:SetFocus())

     @274,0 TABS oTabs OF oWnd ;
            PROMPTS "&Vars", "&Methods", "&Locals" ;
            PIXEL ;
            ACTION oInspect:SetFocus( nOption )

     oInspect:oWnd   := oWnd
     oInspect:oList  := oList
     oInspect:oCombo := oCombo
     oInspect:oTabs  := oTabs


    /* set events */
     oWnd:oBottom = oTabs

    /* Set Keyboard Eventhandler */
     oList:bKeyChar := {|nKey| IIF( nKey == VK_RETURN, oInspect:Select(),)}
     oList:bKeyDown := {|nKey| oInspect:KeyDown( nKey)}

    /* More Eventhandler */
     oWnd:bGotFocus := {|| oList:SetFocus() }
     oWnd:bResized  := {|nt,nW,nH| If( nW != nil, oList:nWidth := ( nW- 3),),;
                                  If( nH != nil, oList:nHeight:= ( nH - 48),) }

    /* Set Focus to oClient */
     oInspect:SetFocus()

     ACTIVATE WINDOW oWnd VALID ( oInspect := nil, .t. )


 RETURN oClient




/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  DLLCODE // Inspect Class                            ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 CREATE CLASS TINSPECT


        CLASSDATA nAt

       	CLASSDATA aHeaders AS ARRAY
        CLASSDATA aStack   AS ARRAY
        CLASSDATA alBase   AS ARRAY
        CLASSDATA aClient  AS ARRAY
        CLASSDATA aNames   AS ARRAY

        CLASSDATA oWnd     AS OBJECT
        CLASSDATA oList    AS OBJECT
        CLASSDATA oCombo   AS OBJECT
        CLASSDATA oTabs    AS OBJECT

        VAR IsVar         AS LOGICAL   INIT .T.
        VAR IsObj         AS LOGICAL

        VAR xClient       AS OBJECT
        VAR cClient       AS CHARACTER
        VAR aMeth         AS ARRAY
        VAR aiVar         AS ARRAY

        MESSAGE New       METHOD NEW_     CONSTRUCTOR
        MESSAGE Select    METHOD SELECT_
        MESSAGE SetFocus  METHOD SETFOCUS_
        MESSAGE SendMsg   METHOD SENDMSG_
        MESSAGE KeyDown   METHOD KEYDOWN_
        MESSAGE Getvalue  METHOD GETVALUE_
        MESSAGE Edit      METHOD EDIT_
        MESSAGE Val2Char  METHOD VAL2CHAR_
        MESSAGE classtree METHOD Classtree

        MESSAGE Error     METHOD ERROR_

 END CLASS





/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  NEW() // Init TInspect Object                       ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD NEW_( oClient, cVar )


  LOCAL ;
     bx,;
     cx,;
     si,;
     di,;
     cProc,;
     aDict,;
     nLen ,;
     uData,;
     oError,;
     bError ,;
     aIVar := {},;
     aMeth := {}

 DEFAULT ;
     cVar := oClient:Classname

     ::IsObj := ( VALTYPE( oClient ) == "O" )
     ::xClient := oClient
     ::cClient := cVar


     CursorWait()

    /* --------------- */
    /* INIT CLASSDATAs  */
    /* --------------- */
     IF ::nAt == nil

        ::nAt := 0
        ::alBase  := {}
        ::aClient := {}
        ::aNames  := {}
        ::aStack  := {}

        cProc := ProcName( 2 )

       /* Browse headers */
        ::aHeaders :=  { { "&","Data","Value" },;
                         { "Message"},;
                         { "&", "Index","Value" },;
                         { "Stack: " + cProc } ;
                       }


       /* Retrieve Parameters */
        si := ParamCount( 2 )
        di := LocalCount( 2 )
        bx := 1

        ASIZE( ::alBase, si + di )
        ASIZE( ::aStack, si + di )

        FOR cx := 1 TO si
            ::aStack[cx] := GetParam( 2, cx )
            ::alBase[cx] := { VALTYPE( ::aStack[cx] ),;
                             "Param" + STR(cx),;
                              ::Val2Char( ::aStack[cx] )}
        NEXT


       /* Retrieve Locals, first == self ? */
        IF di > 0 .AND. ":"$cProc
           uData := GetLocal( 2, 1 )

          /* first local is self ? */
           IF VALTYPE( uData ) == "O"
              ::aStack[ si + 1 ] := uData
              ::alBase[ si + 1 ] := { "O", "self", uData:classname }
              bx++
              di--

           ENDIF
        ENDIF

        bx += si

       /* get the rest of the locals */
        FOR cx := 1 TO di

            ::aStack[ bx ] := GetLocal( 2, cx )
            ::alBase[ bx ] := { VALTYPE( ::aStack[ bx ] ),;
                              "Local" + STR( cx ),;
                               ::Val2Char( ::aStack[ bx ] )}
            bx++

        NEXT

     ENDIF


    /* --------------- */
    /* Browse an Array */
    /* --------------- */
     IF ! ::IsObj
        nLen := LEN( oClient )
        FOR cx := 1 TO nLen
            AADD( aiVar, { VALTYPE( oClient[cx] ),;
                            cVar + "[" + LTRIM( STR( cx )) + "]" ,;
                               ::Val2Char( oClient[cx] ) })
        NEXT

        ::cClient := (" " + cVar + "[1.." + ALLTRIM( STR( LEN( ::xClient ))) + "] " )


    /* ---------------- */
    /* Browse an Object */
    /* ---------------- */
     ELSE


        nLen := LEN( aDict := __classSel( oClient:ClassH ))


     /* Enclose in a custom ErrorBlock to catch OOP Errors */
        bError:= ERRORBLOCK( {|oError| ::Error( oError )} )
        BEGIN SEQUENCE


        FOR cx = 1 TO nLen

         /* ignore strings with a leading Underscore */
          IF !( StrChar( aDict[cx], 1) == '_')
            /* Method */
             IF ASCAN( aDict, LEFT( "_" + aDict[cx], 10 ) ) == 0
                AADD( aMeth, { aDict[cx] } )

            /* Var */
             ELSE

                uData = OSend( oClient, aDict[cx] )
                AADD ( aIvar, { VALTYPE( uData ), aDict[cx], ::Val2Char( uData )})

             ENDIF


           ENDIF
        NEXT
        RECOVER USING oError
           eval( bError, oError )

        END SEQUENCE
        ERRORBLOCK( bError )


        IF LEN( aIvar ) == 0
           AADD( aIvar, { "", "No insVars","" } )
        ENDIF
        IF LEN( aMeth ) == 0
           AADD( aMeth, { "No Methods" } )
        ENDIF

     ENDIF


     ::aIvar := aIvar
     ::aMeth := aMeth


    /* Register a new Instance  */
     IF( cx := ASCAN( ::aNames, ::cClient )) == 0
         AADD( ::aNames, ::cClient )
         AADD( ::aClient, self )

         ::nAt++
         IF ! ::oCombo == nil
            ::oCombo:add( ::cClient )
         ENDIF

     ENDIF

     CursorArrow()


 RETURN self



 METHOD ERROR_( oError )
     IF oError:subSystem = "Objects"
        RETURN oError:description
     ENDIF
 RETURN .F.




/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  SetFocus() // Inspect new Object/Array              ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD SETFOCUS_( nVar )
  LOCAL ;
     cx,;
     aList

  DEFAULT ;
     nVar := 1

    /* Set Tabs to var/methods */
     IF( ::IsVar :=  ( nVar == 1 ))
        aList := ::aIVar
        ::oList:aheaders := ::aHeaders[ IIF( ::IsObj,1,3)]

     ELSEIF nVar == 2
        aList := ::aMeth
        ::oList:aheaders := ::aHeaders[ 2 ]

     ELSE
        aList := ::alBase
        ::oList:aheaders := ::aHeaders[ 4 ]

     ENDIF
     ::oTabs:SetOption( nVar )


    /* Set new Self */
     oInspect := Self


    /* Set Browse Array */
     ::oList:SetArray( aList )
     ::oList:bLine := {||aList[::oList:nAt] }

     ::oList:GoTop()
     ::oList:Refresh()

     IF( cx := ASCAN( ::aNames, ::cClient )) != 0
        ::oCombo:select( cx )
        ::nAt := cx

     ENDIF

 RETURN self



/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ METHOD Select() // Edit/Select choosen item          ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD SELECT_()
  LOCAL ;
     aVar,;
     xData


    /* view Local stack ? */
     IF ::oTabs:nOption == 3
        aVar := ::alBase[ ::oList:nAt ]

    /* View Methods ? */
     ELSEIF ! ::IsVar
        ::SendMsg()

    /* View Array or Data */
     ELSE
        aVar := ::aIvar[ ::oList:nAt ]

     ENDIF


    /* Object or Array ? */
     IF aVar[VAR_TYPE] $ "AO"
        xData := ::getValue()

        IF VALTYPE( xData )$"AO" .AND. !( xData == ::xClient )
           TInspect():new( xData, aVar[VAR_MESS]):SetFocus()
        ENDIF

    /* All but a Block ? */
     ELSEIF aVar[VAR_TYPE] != "B" .AND. ::oTabs:nOption != 3
        ::Edit()

     ENDIF

 RETURN Self


/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  METHOD GetValue() // retrieve iVar contents         ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD GETVALUE_()
 LOCAL ;
    bError,;
    oError,;
    uData ,;
    cx := ::oList:nAt

   /* Stack */
    IF ::oTabs:nOption == 3
       uData := ::aStack[cx]

   /* Object */
    ELSEIF ::IsObj

       bError:= ERRORBLOCK( {|oError| ::Error( oError )} )
        BEGIN SEQUENCE

        uData := OSend(::xClient, ::aiVar[cx][VAR_MESS] )

        END SEQUENCE
        ERRORBLOCK( bError )


   /* Array */
    ELSE
       uData := ::xClient[cx]

    ENDIF

 RETURN uData




/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ METHOD KeyDown // Move backward through oClients     ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD KEYDOWN_( nKey )
  LOCAL ;
     cx ,;
     nLen


    /* exit key ? */
     IF nKey == VK_ESCAPE

       /* leave if buffer is empty */
        IF --::nAt == 0
           ::oWnd:end()

       /* decrease buffer to current position-1 */
        ELSE
           ASIZE( ::aClient, ::nAt )
           ASIZE( ::aNames,  ::nAt )

           WHILE LEN( ::oCombo:aItems ) > ::nAt
                 ::oCombo:del( ::nAt+1 )
           END

          /* SetFocus to Object */
           ::aClient[ ::nAt ]:SetFocus()

        ENDIF
        RETURN 1
     ENDIF

 RETURN 0




/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  SendMsg()// Send Message, capture retVal            ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD SENDMSG_()
  LOCAL ;
     cTxt := "Cancelled" ,;
     cMsg := ::aMeth[::oList:nAt][1]

     IF MsgYesNo( "Send Message " + cMsg + " ?" )
        cTxt := "Method returned:" + CRLF + ::Val2Char(oSend(::xClient, cMsg))
     ENDIF
     MsgInfo( cTxt )

 RETURN Self




/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  Edit()// Edit Instance Data                         ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD EDIT_()
 LOCAL ;
    cTyp,;
    aArray,;
    bAction,;
    uTemp := ::getValue() ,;
    cData := ::aiVar[::oList:nAt ][VAR_MESS]


    IF( cTyp := VALTYPE( uTemp )) == "U"
        uTemp := SPACE( 50 )

    ELSEIF cTyp == "C"
       uTemp = PADR( uTemp, 50 )

    ENDIF

    // nCol, uVar, cPicture, bValid, nClrFore, nClrBack, aItems, bAction )


    /* Edit iVar */
    IF ::oList:lEditCol(3,@uTemp,,,,, aArray, bAction )
       IF VALTYPE( uTemp ) == "C"
          uTemp = RTRIM( uTemp )
       ENDIF
       OSend( ::xClient, "_" + cData, uTemp )
       ::aiVar[::oList:nAt ][VAR_VALUE] := ::Val2Char( uTemp )

    ENDIF
    ::oList:DrawSelect()


 RETURN self


/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  FUNCTION val2Char ( uValue)                         ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD VAL2CHAR_( uValue )
  LOCAL ;
     cResult := "NIL" ,;
     cType := VALTYPE( uValue )


     DO CASE
        CASE cType == "A"
             cResult := "{ ... }"

        CASE cType == "C"
             cResult := '"' + uValue + '"'

        CASE cType == "D"
             cResult := DTOC( uValue )

        CASE cType == "L"
             cResult := IIF( uValue, ".T.", ".F." )

        CASE cType == "N"
             cResult := LTRIM( STR( uValue))

        CASE cType == "O"
             cResult := "Object"

        CASE cType == "B"
             cResult := "{ || ... }"

     ENDCASE

 RETURN cResult




/*
ﬁﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ›
ﬁ  ClassTree()                                         ›
ﬁ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹›*/

 METHOD ClassTree()
  LOCAL ;
     cx ,;
     nClassH,;
     cClasses := "Tree: " + CRLF

     cx := 1
     nClassH := ::xClient:ClassH

     WHILE cx < nClassH
*        IF !( ::xClient:childLevel( __CLASSINS( cx )) == 0 )
*           cClasses += __CLASSNAME( cx ) + CRLF
*        ENDIF
        cx++
     END
 RETURN MsgInfo( cClasses + ::xClient:ClassName() )


