#include "FiveWin.ch"

#define DEVICE      oWnd:cargo

#define GO_POS      0
#define GO_UP       1
#define GO_DOWN     2
#define GO_LEFT     1
#define GO_RIGHT    2
#define GO_PAGE    .T.

#define VSCROLL_RANGE  20 * ::nZFactor
#define HSCROLL_RANGE  20 * ::nZFactor

#define TXT_FIRST    LoadString( GetResources(), 07 )
#define TXT_PREVIOUS LoadString( GetResources(), 08 )
#define TXT_NEXT     LoadString( GetResources(), 09 )
#define TXT_LAST     LoadString( GetResources(), 10 )
#define TXT_ZOOM     LoadString( GetResources(), 11 )
#define TXT_UNZOOM   LoadString( GetResources(), 12 )
#define TXT_TWOPAGES LoadString( GetResources(), 13 )
#define TXT_ONEPAGE  LoadString( GetResources(), 14 )
#define TXT_PRINT    LoadString( GetResources(), 15 )
#define TXT_EXIT     LoadString( GetResources(), 16 )
#define TXT_FILE     LoadString( GetResources(), 17 )
#define TXT_PAGE     LoadString( GetResources(), 18 )
#define TXT_PREVIEW  LoadString( GetResources(), 03 )
#define TXT_PAGENUM  LoadString( GetResources(), 19 )

#define TXT_A_WINDOW_PREVIEW_IS_ALLREADY_RUNNING ;
        LoadString( GetResources(), 20 )
#define TXT_GOTO_FIRST_PAGE ;
        LoadString( GetResources(), 21 )
#define TXT_GOTO_PREVIOUS_PAGE ;
        LoadString( GetResources(), 22 )
#define TXT_GOTO_NEXT_PAGE ;
        LoadString( GetResources(), 23 )
#define TXT_GOTO_LAST_PAGE ;
        LoadString( GetResources(), 24 )
#define TXT_ZOOM_THE_PREVIEW ;
        LoadString( GetResources(), 25 )
#define TXT_UNZOOM_THE_PREVIEW ;
        LoadString( GetResources(), 26 )
#define TXT_PREVIEW_ON_TWO_PAGES ;
        LoadString( GetResources(), 27 )
#define TXT_PREVIEW_ON_ONE_PAGE ;
        LoadString( GetResources(), 28 )
#define TXT_PRINT_CURRENT_PAGE ;
        LoadString( GetResources(), 29 )
#define TXT_EXIT_PREVIEW ;
        LoadString( GetResources(), 30 )
#define TXT_FACTOR ;
        LoadString( GetResources(), 31 )
#define TXT_ZOOM_FACTOR ;
        LoadString( GetResources(), 32 )

#define MK_MBUTTON            16

static l2007 := .F.

//----------------------------------------------------------------------------//

CLASS TPreview

   DATA   oWnd, oBar, oFont, oImageList
   DATA   oDevice
   DATA   oHand, oCursor 
   DATA   oMeta1, oMeta2, oSay, oFactor
   DATA   oPage, oTwoPages, oZoom
   DATA   oMenuZoom, oMenuTwoPages, oMenuUnZoom, oMenuOnePage
   DATA   cResFile
   DATA   aFactor, nPage, nZFactor
   DATA   lTwoPages, lZoom, lExit
   DATA   cPageNum

   CLASSDATA oWndMain

   METHOD New( oDevice ) 
   METHOD Activate()
   METHOD BuildButtonBar()
   METHOD BuildWindow()
   METHOD BuildMenu()
   METHOD PaintMeta()
   METHOD NextPage()
   METHOD PrevPage()
   METHOD TopPage()
   METHOD BottomPage()
   METHOD TwoPages( lMenu )
   METHOD Zoom( lMenu )
   METHOD VScroll( nType, lPage, nSteps )
   METHOD HScroll( nType, lPage, nSteps )
   METHOD SetOrg1( nX, nY )
   METHOD SetOrg2( nX, nY )
   METHOD CheckKey( nKey, nFlags )
   METHOD CheckMouseWheel( nKeys, nDelta, nXPos, nYPos )
   METHOD SetFactor( nValue )
   METHOD PrintPage()
   METHOD PrintPrv( oDlg, nOption, nPageIni, nPageEnd )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oDevice ) CLASS TPreview

   if oDevice == nil
      PRINTER oDevice PREVIEW
         PAGE
         ENDPAGE
         MsgInfo( oDevice:aMeta[ 1 ] )
      // ENDPRINTER
   endif   

   ::oDevice   := oDevice
   ::nPage     := 1
   ::nZFactor  := 1
   ::lTwoPages := .F.
   ::lZoom     := .F.
   ::lExit     := .F.
    
   ::BuildWindow()

return Self

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TPreview

   ACTIVATE WINDOW ::oWnd MAXIMIZED ;
      ON RESIZE    ::PaintMeta()                  ;
      ON UP        ::VScroll( GO_UP )             ;
      ON DOWN      ::VScroll( GO_DOWN )           ;
      ON PAGEUP    ::VScroll( GO_UP, GO_PAGE)     ;
      ON PAGEDOWN  ::VScroll( GO_DOWN, GO_PAGE)   ;
      ON LEFT      ::HScroll( GO_LEFT )           ;
      ON RIGHT     ::HScroll( GO_RIGHT )          ;
      ON PAGELEFT  ::HScroll( GO_LEFT, GO_PAGE )  ;
      ON PAGERIGHT ::HScroll( GO_RIGHT, GO_PAGE ) ;
      VALID        ( ::oWnd:oIcon := nil       ,;
                     ::oFont:End()             ,;
                     ::oMeta1:End()            ,;
                     ::oMeta2:End()            ,;
                     ::oDevice:End()           ,;
                     ::oHand:End()             ,;
                     ::oWnd := nil             ,;
                     If( IsAppThemed() .and. ! l2007, ::oImageList:End(),),;
                     ::lExit := .T.            ,;
                     .T. )
                     
     if ::oDevice:lPrvModal
        StopUntil( { || ::lExit } )
     endif   

return nil

//----------------------------------------------------------------------------//

METHOD BuildButtonBar() CLASS TPreview

   local oImageList, oReBar, oBar, oHand, oWndMain
   local l97Look  := ::oWndMain != nil .and. ::oWndMain:oBar != nil .and. ;
                     Len( ::oWndMain:oBar:aControls ) > 0 .and. ;
                     ::oWndMain:oBar:aControls[ 1 ]:l97Look   

   DEFINE CURSOR ::oHand HAND

   if WndMain() != nil
      if WndMain():oBar != nil
         oBar = WndMain():oBar
         if oBar != nil .and. Upper( oBar:ClassName() ) == "TBAR" .and. oBar:l2007
            l2007 = .T.
         endif
      endif      
   endif   

   if IsAppThemed() .and. ! l2007
      DEFINE IMAGELIST oImageList SIZE 16, 16

      oImageList:AddMasked( TBitmap():Define( "top2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "previous2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "next2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "bottom2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "zoom2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "two_pages2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "printer2",, ::oWnd ), nRGB( 255, 0, 255 ) )    
      oImageList:AddMasked( TBitmap():Define( "exit2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "unzoom2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      oImageList:AddMasked( TBitmap():Define( "one_page2",, ::oWnd ), nRGB( 192, 192, 192 ) )    
      ::oImageList = oImageList
     
      oReBar = TReBar():New( ::oWnd )
    
      DEFINE TOOLBAR oBar OF oReBar SIZE 25, 25 IMAGELIST oImageList  
        
      ::oBar = oBar  
      oReBar:InsertBand( oBar )

      oBar:nHeight -= 2 

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::TopPage() ;
         TOOLTIP Strtran( TXT_FIRST, "&", "" ) ;
         MESSAGE TXT_GOTO_FIRST_PAGE

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::PrevPage() ;
         TOOLTIP Strtran( TXT_PREVIOUS, "&", "" ) ;
         MESSAGE TXT_GOTO_PREVIOUS_PAGE       

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::NextPage() ;
         TOOLTIP Strtran( TXT_NEXT, "&", "" ) ;
         MESSAGE TXT_GOTO_NEXT_PAGE       

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::BottomPage() ;
         TOOLTIP Strtran( TXT_LAST, "&", "" ) ;
         MESSAGE TXT_GOTO_LAST_PAGE         
           
      DEFINE TBSEPARATOR OF oBar   

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::Zoom() ;
         TOOLTIP Strtran( TXT_ZOOM, "&", "" ) ;
         MESSAGE TXT_ZOOM_THE_PREVIEW                 

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::TwoPages() ;
         TOOLTIP StrTran( Strtran( TXT_TWOPAGES, "&", "" ), "á", "a" ) ;
         MESSAGE TXT_PREVIEW_ON_TWO_PAGES       

      DEFINE TBSEPARATOR OF oBar   

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::PrintPage() ;
         TOOLTIP Strtran(TXT_PRINT,"&","") ;
         MESSAGE TXT_PRINT_CURRENT_PAGE            

      DEFINE TBSEPARATOR OF oBar   

      DEFINE TBBUTTON OF oBar ;
         ACTION  ::oWnd:End() ;
         TOOLTIP Strtran( TXT_EXIT, "&", "" ) ;
         MESSAGE TXT_EXIT_PREVIEW               

   else   

      if oBar != nil .and. oBar:l2007
         DEFINE BUTTONBAR oBar SIZE 26, If( LargeFonts(), 30, 26 ) OF ::oWnd 2007
         oBar:bPainted = { || oBar:Say( 7, 285, "Factor:",,, ::oFont, .T., .T. ),;
                              If( Len( ::oDevice:aMeta ) > 1,;
                              oBar:Say( 7, 380, ::cPageNum + LTrim( Str( ::nPage, 4, 0 ) ) + " / " + ;
                              LTrim( Str( Len( ::oDevice:aMeta ) ) ),,, ::oFont, .T., .T. ),;
                              oBar:Say( 7, 380, ::cPageNum + LTrim( Str( ::nPage, 4, 0 ) ),;
                              ,,, ::oFont, .T., .T. ) ) }
      else   
         DEFINE BUTTONBAR oBar _3D SIZE 26, If( LargeFonts(), 30, 26 ) OF ::oWnd
      endif   

      ::oBar = oBar

      if l97Look
         DEFINE BUTTON RESOURCE "Top" OF oBar ;
            MESSAGE TXT_GOTO_FIRST_PAGE     ;
            ACTION  ::TopPage()                ;
            TOOLTIP Strtran( TXT_FIRST, "&", "" ) NOBORDER

         DEFINE BUTTON RESOURCE "Previous" OF oBar ;
            MESSAGE TXT_GOTO_PREVIOUS_PAGE       ;
            ACTION  ::PrevPage()                 ;
            TOOLTIP Strtran( TXT_PREVIOUS, "&", "" ) NOBORDER

         DEFINE BUTTON RESOURCE "Next" OF oBar ;
            MESSAGE TXT_GOTO_NEXT_PAGE       ;
            ACTION  ::NextPage()             ;
            TOOLTIP Strtran( TXT_NEXT, "&", "" ) NOBORDER

         DEFINE BUTTON RESOURCE "Bottom" OF oBar ;
            MESSAGE TXT_GOTO_LAST_PAGE         ;
            ACTION  ::BottomPage()             ;
            TOOLTIP Strtran( TXT_LAST, "&", "" ) NOBORDER

         DEFINE BUTTON ::oZoom RESOURCE "Zoom" OF oBar GROUP ;
            MESSAGE TXT_ZOOM_THE_PREVIEW                 ;
            ACTION  ::Zoom()                             ;
            TOOLTIP Strtran( TXT_ZOOM, "&", "" ) NOBORDER

         DEFINE BUTTON ::oTwoPages RESOURCE "Two_Pages" OF oBar  ;
            MESSAGE TXT_PREVIEW_ON_TWO_PAGES       ;
            ACTION  ::TwoPages()                   ;
            TOOLTIP Strtran( TXT_TWOPAGES, "&", "" ) NOBORDER

         DEFINE BUTTON RESOURCE "Printer" OF oBar GROUP ;
            MESSAGE TXT_PRINT_CURRENT_PAGE            ;
            ACTION  ::PrintPage()                     ;
            TOOLTIP Strtran( TXT_PRINT, "&", "" ) NOBORDER

         DEFINE BUTTON RESOURCE "Exit" OF oBar GROUP ;
            MESSAGE TXT_EXIT_PREVIEW               ;
            ACTION  ::oWnd:End()                   ;
            TOOLTIP Strtran( TXT_EXIT, "&", "" ) NOBORDER
    else
         DEFINE BUTTON RESOURCE "Top2" OF oBar ;
            MESSAGE TXT_GOTO_FIRST_PAGE     ;
            ACTION  ::TopPage()             ;
            TOOLTIP Strtran( TXT_FIRST, "&", "" )

         DEFINE BUTTON RESOURCE "Previous2" OF oBar ;
            MESSAGE TXT_GOTO_PREVIOUS_PAGE       ;
            ACTION  ::PrevPage()                 ;
            TOOLTIP Strtran( TXT_PREVIOUS, "&", "" )

         DEFINE BUTTON RESOURCE "Next2" OF oBar ;
            MESSAGE TXT_GOTO_NEXT_PAGE       ;
            ACTION  ::NextPage()             ;
            TOOLTIP Strtran( TXT_NEXT, "&", "" )

         DEFINE BUTTON RESOURCE "Bottom2" OF oBar ;
            MESSAGE TXT_GOTO_LAST_PAGE         ;
            ACTION  ::BottomPage()             ;
            TOOLTIP Strtran( TXT_LAST, "&", "" )

         DEFINE BUTTON ::oZoom RESOURCE "Zoom2" OF oBar GROUP ;
            MESSAGE TXT_ZOOM_THE_PREVIEW                 ;
            ACTION  ::Zoom()                             ;
            TOOLTIP Strtran( TXT_ZOOM, "&", "" )

         DEFINE BUTTON ::oTwoPages RESOURCE "Two_Pages2" OF oBar  ;
            MESSAGE TXT_PREVIEW_ON_TWO_PAGES       ;
            ACTION  ::TwoPages()                   ;
            TOOLTIP Strtran( TXT_TWOPAGES, "&", "" )

         DEFINE BUTTON RESOURCE "Printer2" OF oBar GROUP ;
            MESSAGE TXT_PRINT_CURRENT_PAGE            ;
            ACTION  ::PrintPage()                     ;
            TOOLTIP Strtran( TXT_PRINT, "&", "" )

         DEFINE BUTTON RESOURCE "Exit2" OF oBar GROUP ;
            MESSAGE TXT_EXIT_PREVIEW               ;
            ACTION  ::oWnd:End()                   ;
            TOOLTIP Strtran( TXT_EXIT, "&", "" )
     endif

     AEval( oBar:aControls, { | o | o:oCursor := ::oHand } )
   endif  

return nil

//----------------------------------------------------------------------------//

METHOD BuildWindow() CLASS TPreview

   local oIcon, cTitle := "FiveWin Printing Preview", oCursor
   local hOldRes := GetResources(), oThis := Self
   LOCAL oApp := ZApp():New()

   DEFAULT ::oWndMain := WndMain()
   
/*
   #ifdef __CLIPPER__
      ::cResFile := "Preview.dll"
   #else
      if ! IsWin64()
         ::cResFile := "Prev32.dll"
      else
         ::cResFile = "Prev64.dll"
      endif      
   #endif
*/

   ::cResFile := oApp:cDirDll + '\Prev32.dll'   // CAF

   if SetResources( ::cResFile ) < 32
      MsgStop( ::cResFile + " not found, imposible to continue",;
               "FiveWin Printing Error" )
      return nil
   endif
   
   if ::oDevice != nil
      cTitle = ::oDevice:cDocument
   endif   

   if ::oWndMain != nil
      oIcon = ::oWndMain:oIcon
   else
      DEFINE ICON oIcon RESOURCE "Print"   
   endif

   DEFINE FONT ::oFont NAME GetSysFont() SIZE 0, -12

   if ::oWndMain != nil .and. Upper( ::oWndMain:ClassName() ) == "TMDIFRAME"
      DEFINE WINDOW ::oWnd ;
         TITLE cTitle ;
         COLOR CLR_BLACK,CLR_LIGHTGRAY      ;
         ICON  oIcon                        ;
         VSCROLL HSCROLL MDICHILD
   else      
      DEFINE WINDOW ::oWnd FROM 0, 0 TO 24, 80  ;
         TITLE cTitle ;
         COLOR CLR_BLACK,CLR_LIGHTGRAY      ;
         ICON  oIcon                        ;
         VSCROLL HSCROLL MENU ::BuildMenu()
   endif      

   ::oWnd:SetFont( ::oFont ) 

   ::oWnd:oVScroll:SetRange( 0, 0 )
   ::oWnd:oHScroll:SetRange( 0, 0 )

   ::cPageNum = TXT_PAGENUM 
   ::BuildButtonBar()

   #ifdef __CLIPPER__
      SET MESSAGE OF ::oWnd TO TXT_PREVIEW CENTERED ;
         NOINSET CLOCK DATE KEYBOARD
   #else
      if l2007
         SET MESSAGE OF ::oWnd TO TXT_PREVIEW CENTERED ;
            NOINSET CLOCK DATE KEYBOARD 2007
      else      
         DEFINE STATUSBAR OF ::oWnd PROMPT "  " + TXT_PREVIEW
      endif   
   #endif         
   
   ::oMeta1 := TMetaFile():New( 0, 0, 0, 0,;
                                ::oDevice:aMeta[ 1 ],;
                                ::oWnd,;
                                CLR_BLACK,;
                                CLR_WHITE,;
                                ::oDevice:nHorzRes(),;
                                ::oDevice:nVertRes() )

   DEFINE CURSOR ::oCursor RESOURCE "Lupa"
   
   ::oMeta1:oCursor := ::oCursor
   ::oMeta1:blDblClick := { | nRow, nCol, nKeyFlags | ;
                            ::SetOrg1( nCol, nRow, nKeyFlags ) }

   ::oMeta1:bKeyDown := { | nKey, nFlags | ::CheckKey( nKey, nFlags ) }
   ::oMeta1:bMouseWheel := { | nKeys, nDelta, nXPos, nYPos | ;
                             ::CheckMouseWheel( nKeys, nDelta, nXPos, nYPos ) }                            

   #ifndef __XPP__ // XBPP bug. Warning: don't change this into #ifdef __CLIPPER__
      ::oMeta2 := TMetaFile():New( 0, 0, 0, 0, "",;
                                   ::oWnd, CLR_BLACK, CLR_WHITE, ::oDevice:nHorzRes(),;
                                   ::oDevice:nVertRes() )
   #else
      ::oMeta2 := TMetaFile():New():_New( 0, 0, 0, 0, "",;
                                          ::oWnd, CLR_BLACK, CLR_WHITE, ::oDevice:nHorzRes(),;
                                          ::oDevice:nVertRes() )
   #endif

   ::oMeta2:oCursor = ::oCursor
   ::oMeta2:blDblClick := { | nRow, nCol, nKeyFlags | ;
                            ::SetOrg2( nCol, nRow, nKeyFlags ) }

   ::oMeta2:hide()
  
   ::SetFactor()
   
   if ! l2007
      @ 7, 285 SAY ::oSay PROMPT "Factor:" ;
         SIZE 45, 15 PIXEL OF ::oBar FONT ::oFont
      
      ::oSay:lTransparent = .T.   
   endif   
        
   @ 3, 325 COMBOBOX ::oFactor VAR ::nZFactor ;
      ITEMS { "1", "2", "3", "4", "5", "6", "7", "8", "9" } ;
      OF ::oBar FONT ::oFont PIXEL SIZE 35,200 ;
      ON CHANGE oThis:SetFactor( oThis:nZFactor )

   if ! l2007
      if Len( ::oDevice:aMeta ) > 1 
         @ 7, 370 SAY ::oPage PROMPT TXT_PAGENUM + LTrim( Str( ::nPage, 4, 0 ) ) + " / " + ;
            LTrim( Str( Len( ::oDevice:aMeta ) ) ) ;
            SIZE 180, 15 PIXEL OF ::oBar FONT ::oFont
      else   
         @ 7, 370 SAY ::oPage PROMPT TXT_PAGENUM + LTrim( Str( ::nPage, 4, 0 ) ) ;
            SIZE 180, 15 PIXEL OF ::oBar FONT ::oFont
      endif   
      ::oPage:lTransparent = .T.  
   endif   

   if IsAppThemed() .or. l2007
      FixSays( ::oBar:hWnd )
   endif   

   #ifndef __XPP__
      ::oFactor:Set3dLook()
   #endif

   SetResources( hOldRes )

   ::oWnd:oHScroll:bPos := { | nPos | ::HScroll( GO_POS, .f., nPos ) }
   ::oWnd:oVScroll:bPos := { | nPos | ::VScroll( GO_POS, .f., nPos ) }   
   
return nil

//----------------------------------------------------------------------------//

METHOD BuildMenu() CLASS TPreview

   local nFor, oMenu
   local lThemed := IsAppThemed()
   local cPrinter   := If( lThemed, "Printer2", "Printer" )
   local cTop       := If( lThemed, "Top2", "Top" )
   local cPrevious  := If( lThemed, "Previous2", "Previous" )
   local cNext      := If( lThemed, "Next2", "Next" )
   local cBottom    := If( lThemed, "Bottom2", "Bottom" )
   local cZoom      := If( lThemed, "Zoom2", "Zoom" )
   local cUnZoom    := If( lThemed, "UnZoom2", "UnZoom" )
   local cOne_Page  := If( lThemed, "One_page2", "One_page" )
   local cTwo_Pages := If( lThemed, "Two_pages2", "Two_pages" )
   local cExit      := If( lThemed, "Exit2", "Exit" )

   ::aFactor := Array( 9 )

   MENU oMenu
      MENUITEM TXT_FILE
      MENU
         MENUITEM TXT_PRINT ACTION ::PrintPage() ;
            MESSAGE TXT_PRINT_CURRENT_PAGE RESOURCE cPrinter

         SEPARATOR

         MENUITEM TXT_EXIT ACTION ::oWnd:End() ;
            MESSAGE TXT_EXIT_PREVIEW RESOURCE cExit
      ENDMENU

      MENUITEM TXT_PAGE
      MENU
         MENUITEM TXT_FIRST ACTION ::TopPage() ;
            MESSAGE TXT_GOTO_FIRST_PAGE RESOURCE cTop

         MENUITEM TXT_PREVIOUS ACTION ::PrevPage() ;
            MESSAGE TXT_GOTO_PREVIOUS_PAGE RESOURCE cPrevious

         MENUITEM TXT_NEXT ACTION ::NextPage() ;
            MESSAGE TXT_GOTO_NEXT_PAGE RESOURCE cNext

         MENUITEM TXT_LAST ACTION ::BottomPage() ;
            MESSAGE TXT_GOTO_LAST_PAGE RESOURCE cBottom

         SEPARATOR

         MENUITEM ::oMenuZoom PROMPT TXT_ZOOM ACTION ::Zoom( .T. ) ;
            MESSAGE TXT_ZOOM_THE_PREVIEW RESOURCE cZoom

         MENUITEM ::oMenuUnZoom PROMPT TXT_UNZOOM ACTION ::Zoom( .T. ) ;
            MESSAGE TXT_UNZOOM_THE_PREVIEW RESOURCE cUnZoom

         MENUITEM "&Factor" MESSAGE TXT_ZOOM_FACTOR
         MENU
            for nFor := 1 to Len( ::aFactor )
               MENUITEM ::aFactor[ nFor ]                  ;
                  PROMPT "&" + LTrim( Str( nFor ) )        ;
                  MESSAGE "Factor " + LTrim( Str( nFor ) ) ;
                  ACTION ( ::oFactor:Set( oMenuItem:nHelpId ),;
                           Eval( ::oFactor:bChange ) )

            next
         ENDMENU
        
         SEPARATOR

         MENUITEM ::oMenuTwoPages PROMPT TXT_TWOPAGES ACTION ::TwoPages( .T. ) ;
            ENABLED ;
            MESSAGE TXT_PREVIEW_ON_TWO_PAGES RESOURCE cTwo_Pages

         MENUITEM ::oMenuOnePage PROMPT TXT_ONEPAGE ACTION ::TwoPages(.T.) ;
            MESSAGE TXT_PREVIEW_ON_ONE_PAGE RESOURCE cOne_Page

      ENDMENU
   ENDMENU

   ::oMenuUnZoom:Disable()
   ::oMenuOnePage:Disable()     

return oMenu

//----------------------------------------------------------------------------//

METHOD PaintMeta() CLASS TPreview

   local oCoors1, oCoors2
   local aFiles := ::oDevice:aMeta  // DEVICE
   local nWidth, nHeight, nFactor, nMetaWidth

   if ::oWnd != nil .and. IsIconic( ::oWnd:hWnd )
      return nil
   endif

   do case
      case ! ::lTwoPages

           if ! ::lZoom

             if ::oDevice:nHorzSize() >= ;   // landscape (apaisado)  // DEVICE
                ::oDevice:nVertSize()
                nFactor := .8 // .4
             else
                nFactor := .40 // .25
             endif

          else
             nFactor := .47
          endif

          if ::oWnd != nil
             nWidth  = ::oWnd:nWidth() - If( ::lZoom, 20, 0 )
             nHeight = ::oWnd:nHeight() - If( ::lZoom .and. ::nZFactor > 1, 20, 0 ) - 10 - ;
                       If( LargeFonts(), 100, 80 )
          
             if ! ::lZoom
                nMetaWidth = ( nHeight - 40 ) * nFactor         
             else   
                nMetaWidth = nWidth * nFactor         
             endif
                    
             oCoors1 := TRect():New( 40,;
                                     Max( ( nWidth / 2 ) - nMetaWidth, 10 ),;
                                     nHeight,;
                                     Min( ( nWidth / 2 ) + nMetaWidth, nWidth - 20 ) )

             ::oMeta2:Hide()
             ::oMeta1:SetCoors( oCoors1 )
             ::oMeta1:Refresh()
          endif   

      case ::lTwoPages

          nFactor := .4
          aFiles  := ::oDevice:aMeta  // DEVICE

          nWidth  := ::oWnd:nWidth()
          nHeight := ::oWnd:nHeight() - 10 - If( LargeFonts(), 100, 80 )

          nMetaWidth = Min( ( nHeight - 40 ) * nFactor, ( nWidth - 60 ) / 4 )
          
          oCoors1 := TRect():New( 40,;
                                  ( nWidth / 4 ) - nMetaWidth,;
                                  nHeight,;
                                  ( nWidth / 4 ) + nMetaWidth )
          oCoors2 := TRect():New( 40,;
                                  ( nWidth / 4 ) - nMetaWidth + ( nWidth / 2 ),;
                                  nHeight,;
                                  ( nWidth / 4 ) + nMetaWidth + ( nWidth / 2 ) )

          if ::nPage == Len( aFiles )
             ::oMeta2:SetFile( "" )
          else
             ::oMeta2:SetFile( aFiles[ ::nPage + 1 ] )
          endif

          ::oMeta1:SetCoors( oCoors1 )
          ::oMeta2:SetCoors( oCoors2 )
          ::oMeta1:Refresh()
          ::oMeta2:Show()

   endcase

   ::oMeta1:SetFocus()

return nil

//----------------------------------------------------------------------------//

METHOD NextPage() CLASS TPreview

   local hOldRes := GetResources()
   local aFiles  := ::oDevice:aMeta  // DEVICE

   if ::nPage >= Len( aFiles )
      MsgBeep()
      return nil
   endif

   ::nPage++

   SET RESOURCES TO ::cResFile

   ::oMeta1:SetFile( aFiles[ ::nPage ] )
   if ! l2007
      ::oPage:SetText( TXT_PAGENUM + LTrim( Str( ::nPage, 4, 0 ) ) + " / " + ;
                                     LTrim( Str( Len( aFiles ) ) ) )
   endif
                                     
   ::oBar:Refresh()
   ::oMeta1:Refresh()

   if ::lTwoPages
      if Len( aFiles ) >= ::nPage + 1
         ::oMeta2:SetFile( aFiles[ ::nPage + 1 ] )
      else
         ::oMeta2:SetFile( "" )
      endif
      ::oMeta2:Refresh()
   endif

   ::oMeta1:SetFocus()
   SetResources( hOldRes )

return nil

//----------------------------------------------------------------------------//

METHOD PrevPage() CLASS TPreview

   local hOldRes := GetResources()
   local aFiles  := ::oDevice:aMeta  // DEVICE

   if ::nPage == 1
      MsgBeep()
      return nil
   endif

   ::nPage--

   SET RESOURCES TO ::cResFile

   ::oMeta1:SetFile( aFiles[ ::nPage ] )
   if ! l2007
      ::oPage:SetText( TXT_PAGENUM + LTrim( Str( ::nPage, 4, 0 ) ) + " / " + ;
                                     LTrim( Str( Len( aFiles ) ) ) )
   endif                                  
   ::oBar:Refresh()
   ::oMeta1:Refresh()

   if ::lTwoPages
      if Len( aFiles ) >= ::nPage + 1
         ::oMeta2:SetFile( aFiles[ ::nPage + 1 ] )
      else
         ::oMeta2:SetFile( "" )
      endif
      ::oMeta2:Refresh()
   endif

   ::oMeta1:SetFocus()
   SetResources( hOldRes )

return nil

//----------------------------------------------------------------------------//

METHOD TopPage() CLASS TPreview

   local hOldRes := GetResources()
   local aFiles  := ::oDevice:aMeta  // DEVICE

   if ::nPage == 1
      MsgBeep()
      return nil
   endif

   ::nPage = 1

   SET RESOURCES TO ::cResFile

   ::oMeta1:SetFile( aFiles[ ::nPage ] )
   if ! l2007
      ::oPage:SetText( TXT_PAGENUM + LTrim( Str( ::nPage, 4, 0 ) ) + " / " + ;
                                     LTrim( Str( Len( aFiles ) ) ) )
   endif                                  
   ::oBar:Refresh()
   ::oMeta1:Refresh()

   if ::lTwoPages
      if Len( aFiles ) >= ::nPage + 1
         ::oMeta2:SetFile( aFiles[ ::nPage + 1 ] )
      else
         ::oMeta2:SetFile( "" )
      endif
      ::oMeta2:Refresh()
   endif

   ::oMeta1:SetFocus()
   SetResources( hOldRes )

return nil

//----------------------------------------------------------------------------//

METHOD BottomPage() CLASS TPreview

   local hOldRes := GetResources()
   local aFiles  := ::oDevice:aMeta  // DEVICE

   if ::nPage == Len( aFiles )
      MsgBeep()
      return nil
   endif

   ::nPage = Len( aFiles )

   SET RESOURCES TO ::cResFile

   ::oMeta1:SetFile( aFiles[ ::nPage ] )
   if ! l2007
      ::oPage:SetText( TXT_PAGENUM + LTrim( Str( ::nPage, 4, 0 ) ) + " / " + ;
                                     LTrim( Str( Len( aFiles ) ) ) )
   endif                                  
   ::oBar:Refresh()
   ::oMeta1:Refresh()

   if ::lTwoPages
      ::oMeta2:SetFile( "" )
      ::oMeta2:Refresh()
   endif

   ::oMeta1:SetFocus()
   SetResources( hOldRes )

return nil

//----------------------------------------------------------------------------//

METHOD TwoPages( lMenu ) CLASS TPreview

   local hOldRes := GetResources()

   SET RESOURCES TO ::cResFile

   DEFAULT lMenu := .F.

   ::lTwoPages := ! ::lTwoPages

   if ::lTwoPages

      if Len( ::oDevice:aMeta) == 1 // solo hay una pagina   // DEVICE
         ::lTwoPages := ! ::lTwoPages
         MsgBeep()
         SetResources( hOldRes )
         return nil
      endif

      if ::oDevice:nHorzSize() >= ;        // Apaisado  // DEVICE
         ::oDevice:nVertSize()  // DEVICE   
         ::lTwoPages := ! ::lTwoPages
         MsgBeep()
         SetResources( hOldRes )
         return nil
      endif

      if ::lZoom
         ::Zoom( .T. )
      endif

      if ! IsAppThemed() .or. Upper( ::oBar:ClassName() ) == "TBAR"
         ::oTwoPages:FreeBitmaps()
         ::oTwoPages:LoadBitmaps( "One_Page2" )
         ::oTwoPages:cMsg := TXT_PREVIEW_ON_ONE_PAGE
         ::oTwoPages:cTooltip := StrTran( TXT_ONEPAGE, "&", "" )
      else
         ::oBar:ChangeBitmap( 6, 10 )
         ::oBar:SetTooltip( 6, StrTran( TXT_ONEPAGE, "&", "" ) )
         ::oBar:SetMessage( 6, TXT_PREVIEW_ON_ONE_PAGE ) 
      endif
                
      if ::oWnd:oMenu != nil           
         ::oMenuTwoPages:Disable()
         ::oMenuOnePage:Enable()
      endif   

   else

      if ! IsAppThemed() .or. Upper( ::oBar:ClassName() ) == "TBAR"
         ::oTwoPages:FreeBitmaps()
         ::oTwoPages:LoadBitmaps( "Two_Pages2" )
         ::oTwoPages:cMsg := TXT_PREVIEW_ON_TWO_PAGES
         ::oTwoPages:cTooltip := StrTran( TXT_TWOPAGES, "&", "" )
      else
         ::oBar:ChangeBitmap( 6, 6 )
         ::oBar:SetTooltip( 6, StrTran( TXT_TWOPAGES, "&", "" ) )
         ::oBar:SetMessage( 6, TXT_PREVIEW_ON_TWO_PAGES )
      endif
             
      if ::oWnd:oMenu != nil           
         ::oMenuTwoPages:Enable()
         ::oMenuOnePage:Disable()
      endif   

   endif

   if lMenu .and. ! IsAppThemed()
      ::oTwoPages:Refresh()
   endif

   ::oWnd:Refresh()
   ::PaintMeta()
   SetResources( hOldRes )

return nil

//----------------------------------------------------------------------------//

METHOD Zoom( lMenu ) CLASS TPreview

   local hOldRes := GetResources()

   SET RESOURCES TO ::cResFile

   DEFAULT lMenu := .F.

   ::lZoom := ! ::lZoom

   if ::lZoom

      if ::lTwoPages
         ::TwoPages( .T. )
      endif

      if ! IsAppThemed() .or. l2007
         ::oZoom:FreeBitmaps()
         ::oZoom:LoadBitmaps( "Unzoom2" )
         ::oZoom:cMsg := TXT_UNZOOM_THE_PREVIEW
         ::oZoom:cTooltip := StrTran( TXT_UNZOOM, "&", "" )
      else
         ::oBar:ChangeBitmap( 5, 9 )
         ::oBar:SetTooltip( 5, StrTran( TXT_UNZOOM, "&", "" ) )
         ::oBar:SetMessage( 5, TXT_UNZOOM_THE_PREVIEW )
      endif

      if ::oWnd:oMenu != nil
         ::oMenuZoom:Disable()
         ::oMenuUnZoom:Enable()
      endif   

      ::oWnd:oVScroll:SetRange( 1, VSCROLL_RANGE )

      if ::nZFactor > 1  
         ::oWnd:oHScroll:SetRange( 1, HSCROLL_RANGE )
      endif   

      ::oMeta1:ZoomIn()

   else

      if ! IsAppThemed() .or. l2007
         ::oZoom:FreeBitmaps()
         ::oZoom:LoadBitmaps( "Zoom2" )
         ::oZoom:cMsg := TXT_ZOOM_THE_PREVIEW
         ::oZoom:cTooltip := StrTran( TXT_ZOOM, "&", "" )
      else
         ::oBar:ChangeBitmap( 5, 5 )
         ::oBar:SetTooltip( 5, StrTran( TXT_ZOOM, "&", "" ) )
         ::oBar:SetMessage( 5, TXT_ZOOM_THE_PREVIEW )
      endif   
             
      if ::oWnd:oMenu != nil       
         ::oMenuZoom:Enable()
         ::oMenuUnZoom:Disable()
      endif   

      ::oWnd:oVScroll:SetRange( 0, 0 )
      ::oWnd:oHScroll:SetRange( 0, 0 )

      ::oMeta1:ZoomOut()
      ::nZFactor = 1
      if ::oWnd:oMenu != nil
         AEval( ::aFactor, { | val, elem | val:SetCheck( ( elem == 1 ) ) } )
      endif   
      ::oFactor:Set( 1 )

   endif

   if lMenu .and. ! IsAppThemed()
      ::oZoom:Refresh()
   endif

   ::PaintMeta()
   SetResources( hOldRes )

return nil

//----------------------------------------------------------------------------//

METHOD VScroll( nType, lPage, nSteps ) CLASS TPreview

   local nYfactor, nYorig, nStep

   DEFAULT lPage := .F.

   if nType == GO_UP
      if ::oWnd:oVScroll:GetPos() <= ::oWnd:oVScroll:nMin
         return nil
      endif
   else
      if ::oWnd:oVScroll:GetPos() > ::oWnd:oVScroll:nMax
         return nil
      endif   
   endif              

   nYfactor := Int( ::oDevice:nVertRes() / ::oWnd:oVScroll:nMax )  // DEVICE
 
   if nSteps != nil
      nStep := nSteps
   elseif lPage
      nStep := ::oWnd:oVScroll:nMax / 10
   else
      nStep := 1
   endif

   if nType == GO_UP
      nStep := -nStep
   elseif nType == GO_POS
      ::oWnd:oVscroll:SetPos( nSteps )
      nStep := 0
   endif

   nYorig := nYfactor * ( ::oWnd:oVScroll:GetPos() + nStep - 1 )

   if nYorig > ::oDevice:nVertRes()    // DEVICE
      nYorig := ::oDevice:nVertRes()   // DEVICE
   endif

   if nYorig < 0
      nYorig := 0
   endif

   #ifdef __CLIPPER__ 
      ::oMeta1:SetOrg( nil, nYorig )
   #else
      ::oMeta1:SetOrg( nil, nYorig / ::oDevice:nVertRes() * 10 )  // DEVICE
   #endif       

   ::oMeta1:Refresh()

return nil

//----------------------------------------------------------------------------//

METHOD HScroll( nType, lPage, nSteps ) CLASS TPreview

   local nXfactor, nXorig, nStep

   DEFAULT lPage := .F.

   if nType == GO_UP
      if ::oWnd:oHScroll:GetPos() <= ::oWnd:oHScroll:nMin
         return nil
      endif
   else
      if ::oWnd:oHScroll:GetPos() > ::oWnd:oHScroll:nMax
         return nil
      endif   
   endif              

   nXfactor := Int( ::oDevice:nHorzRes() / ::oWnd:oHScroll:nMax )  // DEVICE
 
   if nSteps != nil
      nStep := nSteps
   elseif lPage
      nStep := ::oWnd:oHScroll:nMax/10
   else
      nStep := 1
   endif

   if nType == GO_LEFT
      nStep := -nStep
   elseif nType == GO_POS
      ::oWnd:oHscroll:SetPos( nSteps )
      nStep := 0
   endif

   nXorig := nXfactor * ( ::oWnd:oHScroll:GetPos() + nStep - 1 )

   if nXorig > ::oDevice:nHorzRes()     // DEVICE
      nXorig := ::oDevice:nHorzRes()    // DEVICE
   endif

   if nXorig < 0
      nXorig := 0
   endif

   #ifdef __CLIPPER__
      ::oMeta1:SetOrg( nXorig, nil )
   #else
      ::oMeta1:SetOrg( nXorig / ::oDevice:nHorzRes() * 10, nil )  // DEVICE
   #endif   

   ::oMeta1:Refresh()

return nil

//----------------------------------------------------------------------------//

METHOD SetOrg1( nX, nY ) CLASS TPreview

   local oCoors
   local nXStep, nYStep, nXFactor, nYFactor,;
         nWidth, nHeight, nXOrg

   if ::lZoom
      ::Zoom( .T. )
      return nil
   endif

   oCoors   := ::oMeta1:GetRect()
   nWidth   := oCoors:nRight - oCoors:nLeft + 1
   nHeight  := oCoors:nBottom - oCoors:nTop + 1
   
   if .f.
      nXStep   := Max( Int( nX / nWidth * HSCROLL_RANGE ) - 9, 0 )
      nXFactor := Int( ::oDevice:nHorzRes() / HSCROLL_RANGE )  // DEVICE
   endif
   
   if .f.
      nYStep   := Max( Int( nY / nHeight * VSCROLL_RANGE ) - 9, 0 )
      nYFactor := Int( ::oDevice:nVertRes() / VSCROLL_RANGE )  // DEVICE
   endif   

   ::Zoom( .T. )

   if ! Empty( nXStep )
      ::HScroll( 2,, nxStep )
      ::oWnd:oHScroll:SetPos( nxStep )
   endif

   if ! Empty( nYStep )
      ::VScroll( 2,, nyStep )
      ::oWnd:oVScroll:SetPos( nyStep )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SetOrg2( nX, nY ) CLASS TPreview

   local oCoors
   local aFiles
   local nXStep, nYStep, nXFactor, nYFactor,;
         nWidth, nHeight, nXOrg

   if ::oMeta2:cCaption == ""
      return nil
   endif

   if ::lZoom
      ::Zoom( .T. )
      return nil
   endif

   oCoors := ::oMeta2:GetRect()
   nWidth   := oCoors:nRight - oCoors:nLeft + 1
   nHeight  := oCoors:nBottom - oCoors:nTop + 1
   
   if .f.
      nXStep   := Max( Int( nX / nWidth * HSCROLL_RANGE ) - 9, 0 )
      nXFactor := Int( ::oDevice:nHorzRes() / HSCROLL_RANGE )
   endif
   
   if .f.
      nYStep   := Max( Int( nY / nHeight * VSCROLL_RANGE ) - 9, 0 )
      nYFactor := Int( ::oDevice:nVertRes() / VSCROLL_RANGE )  // DEVICE
   endif   

   ::oMeta1:SetFile( ::oMeta2:cCaption )

   aFiles := ::oDevice:aMeta  // DEVICE

   if ::nPage = Len( aFiles )
      ::oMeta2:SetFile( "" )
   else
      ::oMeta2:SetFile( aFiles[ ++::nPage ] )
   endif

   ::oPage:Refresh()

   ::Zoom( .T. )

   if ! Empty( nXStep )
      ::HScroll( 2,, nxStep )
      ::oWnd:oHScroll:SetPos( nxStep )
   endif

   if ! Empty( nYStep )
      ::VScroll( 2,, nyStep )
      ::oWnd:oVScroll:SetPos( nyStep )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD CheckKey( nKey, nFlags ) CLASS TPreview

   if ! ::lZoom
      do case
         case nKey == VK_HOME
              ::TopPage()
              
         case nKey == VK_END
              ::BottomPage()
              
         case nKey == VK_PRIOR
              ::PrevPage()
              
         case nKey == VK_NEXT
              ::NextPage()
              
      endcase
   else
      do case
         case nKey == VK_UP
              ::oWnd:oVScroll:GoUp()
              
         case nKey == VK_PRIOR
              ::oWnd:oVScroll:PageUp()
              
         case nKey == VK_DOWN
              ::oWnd:oVScroll:GoDown()
              
         case nKey == VK_NEXT
              ::oWnd:oVScroll:PageDown()
              
         case nKey == VK_LEFT
              ::oWnd:oHScroll:GoUp()
              
         case nKey == VK_RIGHT
              if ::oWnd:oHScroll != nil .and. ::oWnd:oHScroll:nMax > 0
                 ::oWnd:oHScroll:GoDown()
              endif   
              
         case nKey == VK_HOME
              ::oWnd:oVScroll:GoTop()
              ::oWnd:oHScroll:GoTop()
              ::oMeta1:SetOrg( 0, 0 )
              ::oMeta1:Refresh()
              
         case nKey == VK_END
              ::oWnd:oVScroll:GoBottom()
              ::oWnd:oHScroll:GoBottom()
              ::oMeta1:SetOrg( .8 * ::oDevice:nHorzRes(), .8 * ::oDevice:nVertRes() )  // DEVICE
              ::oMeta1:Refresh()
      endcase
   endif

return nil

//----------------------------------------------------------------------------//

METHOD CheckMouseWheel( nKeys, nDelta, nXPos, nYPos ) CLASS TPreview

   if ! ::lZoom
      if lAnd( nKeys, MK_MBUTTON )
         if nDelta > 0
            ::TopPage()
         else
            ::BottomPage()
         endif
      else
         if nDelta > 0
            ::PrevPage()
         else
            ::NextPage()
         endif
      endif
   else
      if lAnd( nKeys, MK_MBUTTON )
         if nDelta > 0
            if ::oWnd:oVScroll:GetPos() > ::oWnd:oVScroll:nMin
               ::oWnd:oVScroll:PageUp()
            endif   
         else
            if ::oWnd:oVScroll:GetPos() < ::oWnd:oVScroll:nMax
               ::oWnd:oVScroll:PageDown()
            endif   
         endif
      else
         if nDelta > 0
            if ::oWnd:oVScroll:GetPos() > ::oWnd:oVScroll:nMin
               ::oWnd:oVScroll:GoUp()
            endif   
         else
            if ::oWnd:oVScroll:GetPos() < ::oWnd:oVScroll:nMax
               ::oWnd:oVScroll:GoDown()
            endif   
         endif
      endif
   endif   

return nil

//----------------------------------------------------------------------------//

METHOD SetFactor( nValue ) CLASS TPreview

   local lInit := .F.

   if nValue == nil .and. ::oWnd:oMenu != nil
      AEval( ::aFactor, { | v, e | v:nHelpId := e } )
      nValue := ::nZFactor
      lInit  := .T.
   endif

   if ::oWnd:oMenu != nil
      AEval( ::aFactor, { | val, elem | val:SetCheck( elem == nValue ) } )
   endif   

   ::oMeta1:SetZoomFactor( ::nZFactor, ::nZFactor * 2 )

   if ! ::lZoom .and. ! lInit
      // ::Zoom( .T. )    A.L. 08 Oct 2007
   endif

   if ::lZoom
      ::oWnd:oVScroll:SetRange( 1, VSCROLL_RANGE )
      if ::nZFactor > 1
         ::oWnd:oHScroll:SetRange( 1, HSCROLL_RANGE )
      else   
         ::oWnd:oHScroll:SetRange( 0, 0 )
      endif   
   endif

   ::oMeta1:SetFocus()

return nil

//----------------------------------------------------------------------------//

METHOD PrintPage() CLASS TPreview

   local hOldRes := GetResources()
   local hMeta   := ::oMeta1:hMeta
   local oDlg, oRad, oPageIni, oPageFin
   local nOption := 1, nFirst := 1, nLast := Len( ::oDevice:aMeta )  // DEVICE
   local oThis := Self

   if nLast == 1
      ::PrintPrv( nil, nOption, nFirst, nLast )
      return nil
   endif

   SET RESOURCES TO ::cResFile

   DEFINE DIALOG oDlg RESOURCE "PRINT"

   REDEFINE BUTTON ID 101 OF oDlg ;
      ACTION oThis:PrintPrv( oDlg, nOption, nFirst, nLast )

   REDEFINE BUTTON ID 102 OF oDlg ACTION oDlg:End()

   REDEFINE RADIO oRad VAR nOption ID 103, 104, 105 OF oDlg ;
      ON CHANGE If( nOption==3 ,;
                    ( oPageIni:Enable(), oPageFin:Enable() ),;
                    ( oPageIni:Disable(), oPageFin:Disable() ) )

   REDEFINE GET oPageIni ;
      VAR nFirst ID 106 PICTURE "@K 99999" ;
      VALID If( nFirst < 1 .or. nFirst > nLast, ( MsgBeep(), .F. ), .T. ) ;
      OF oDlg

   REDEFINE GET oPageFin ;
      VAR nLast ID 107 PICTURE "@K 99999" ;
      VALID If( nLast < nFirst .or. nLast > Len( ::oDevice:aMeta ), ;  // DEVICE
                ( MsgBeep(),.F. ), .T.) OF oDlg

   oPageIni:Disable()
   oPageFin:Disable()

   SetResources( hOldRes )

   ACTIVATE DIALOG oDlg

return nil

//----------------------------------------------------------------------------//

METHOD PrintPrv( oDlg, nOption, nPageIni, nPageEnd ) CLASS TPreview

   local oDevice := ::oDevice   // DEVICE
   local aFiles  := oDevice:aMeta
   local hMeta   := ::oMeta1:hMeta
   local nFor

   CursorWait()

   StartDoc( oDevice:hDC, oDevice:cDocument )

   do case

      case nOption == 1                           // All

          for nFor := 1 to Len( aFiles )
              #ifdef __CLIPPER__
                 StartPage( oDevice:hDC )
                 hMeta := GetMetaFile( aFiles[ nFor ] )
                 PlayMetaFile( oDevice:hDC, hMeta )
                 DeleteMetafile( hMeta )
                 EndPage( oDevice:hDC )
              #else
                 StartPage( oDevice:hDC )
                 hMeta := GetEnhMetaFile( aFiles[ nFor ] )
                 PlayEnhMetaFile( oDevice:hDC, hMeta,, .t. )
                 DeleteEnhMetafile( hMeta )
                 EndPage( oDevice:hDC )               
              #endif   
          next

     case nOption == 2                           // Current page

          StartPage( oDevice:hDC )
          hMeta := ::oMeta1:hMeta
          #ifdef __CLIPPER__
             PlayMetaFile( oDevice:hDC, hMeta )
          #else   
             PlayEnhMetaFile( oDevice:hDC, hMeta,, .t. )
          #endif   
          EndPage( oDevice:hDC )

     case nOption == 3                           // Range

          for nFor := nPageIni to nPageEnd
               StartPage( oDevice:hDC )
               #ifdef __CLIPPER__
                  hMeta := GetMetaFile( aFiles[ nFor ] )
                  PlayMetaFile( oDevice:hDC, hMeta )
                  DeleteMetafile( hMeta )
               #else   
                  hMeta := GetEnhMetaFile( aFiles[ nFor ] )
                  PlayEnhMetaFile( oDevice:hDC, hMeta,, .t. )
                  DeleteEnhMetafile( hMeta )
               #endif   
               EndPage( oDevice:hDC )
          next

     endcase

     EndDoc( oDevice:hDC )

     CursorArrow()

     if oDlg != nil
        oDlg:End()
     endif

return nil

//----------------------------------------------------------------------------//

function RPreview( oDevice )

   local oPreview := TPreview():New( oDevice )

   oPreview:Activate()
   
return nil   

//----------------------------------------------------------------------------//

#ifdef __CLIPPER__

static function IsAppThemed()

return .f.

static function TToolBar()

return nil

static function TRebar()

return nil

#endif

//----------------------------------------------------------------------------//
