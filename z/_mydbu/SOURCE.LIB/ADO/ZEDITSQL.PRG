#include 'fivewin.ch'

STATIC aSql := {}

FUNCTION zEditSql( cText, cTitle, nTop, nLeft, nBottom, nRight )

    local oFont, oDlg, oMemo, oBtnOk, oBtnCancel, oBtnHelp
    local uTemp := cText, oCbx, cCbx := "", lOk := .f.

    DEFAULT cText := ''

    IF Empty( cText )
       IF Len( aSql ) > 0
          uTemp := aSql[ Len(aSql) ]
         ELSE
          uTemp := 'select * from test'
       ENDIF
    ENDIF

    DEFAULT nTop    := 9    ,;
            nLeft   := 9    ,;
            nBottom := 22   ,;
            nRight  := 68.5 ,;
            cTitle  := "MemoEdit"

    DEFINE FONT oFont NAME "Courier" SIZE 0, -13 BOLD

    DEFINE DIALOG oDlg TITLE cTitle             ;
            FROM nTop, nLeft TO nBottom, nRight ;

    @ 04,  03 GET oMemo VAR uTemp MEMO UPDATE      ;
            OF oDlg PIXEL SIZE 100, 100 FONT oFont ;
            COLOR CLR_BLUE, CLR_WHITE

    @ 87,  03 COMBOBOX oCbx VAR cCbx ITEMS aSql    ;
            SIZE 150, 100 OF oDlg                  ;
            ON CHANGE (uTemp := cCbx, oMemo:SetText(cCbx))        ;
            PIXEL

    @ 78, 134 BUTTON oBtnOk     PROMPT "&Aceptar"  ;
            SIZE 36, 12 PIXEL                      ;
            ACTION (cText:=uTemp,lOk:=.t., Aadd( aSql, cText ), oDlg:End())

    @ 78, 176 BUTTON oBtnCancel PROMPT "&Cancelar" ;
            SIZE 36, 12 PIXEL                      ;
            ACTION oDlg:End()

    ACTIVATE DIALOG oDlg ;
            ON INIT ( oMemo:SetSize( ;
            oDlg:nWidth() - 17, oDlg:nHeight() - 69 ),;
            oBtnOk:nTop      := oDlg:nHeight() - 60,  ;
            oBtnOk:nLeft     := oDlg:nWidth() - 167,  ;
            oBtnCancel:nTop  := oDlg:nHeight() - 60,  ;
            oBtnCancel:nLeft := oDlg:nWidth() -  87 ) ;
            CENTERED

    RELEASE FONT oFont

RETU lOk

