#include "FiveWin.ch"
#include "objects.ch"
#include "report.ch"


#define GRID_ABOVE      0
#define GRID_BELOW      1
#define GRID_ABOBEL     2

#define PORTRAIT        1
#define LANDSCAPE       2

#define TXT_CANCEL ;
      LoadString( GetResources(), 1 )
#define TXT_PRINTING_PAGE ;
      LoadString( GetResources(), 2 )
#define TXT_PREVIEW ;
      LoadString( GetResources(), 3 )
#define TXT_BUILDING_PAGE ;
      LoadString( GetResources(), 4 )
#define TXT_REPORT_WIDTH ;
      LoadString( GetResources(), 5 )
#define TXT_ATENTION ;
      LoadString( GetResources(), 6 )

#ifdef __XPP__
   #define New  _New
#endif

//----------------------------------------------------------------------------//

CLASS TReport

   DATA oDevice, oTitle, oHeader, oFooter, oRptWnd, oShdBrush, oPenHorz
   DATA aGroups, aColumns, aFont, aCols, aText, aData, aPen, ;
        aDataHeight, aClrText
   DATA bFor, bWhile, bInit, bEnd, bStartLine, bEndLine, bStartPage, ;
        bEndPage, bStartGroup, bEndGroup, bSkip, bStdFont, bPreview, ;
        bChange, bPostEnd, bPostPage, bPostGroup, bStartRecord
   DATA cRptFile, cResName, cFile, cName, cPageTotal, cGrandTotal,;
        cCharPattern
   DATA nWidth, nHeight, nMargin, nRow, nPage, nMaxTitle, nMaxData,;
        nSeparator, nLeftMargin, nRightMargin, nTopMargin, nDnMargin,;
        nTitleRow, nBottomRow, nStdLineHeight, nRptWidth, nLogPixX,;
        nLogPixY, nFirstdrow, nLastdrow, nTitleHeight, nCounter,;
        nTotalLine, nGroupLine, nTitleUpLine, nTitleDnLine, nClrShadow,;
        nDataLine
   DATA hOldRes
   DATA lSummary, lTotal, lFinish, lStable, lGroup, lPrinter, lScreen,;
        lFirstRow, lCreated, lBreak, lShadow, lGrid, lJoin, lSeparator,;
        lAutoLand, lIsNarrow, lBoxOnTotal, lNoCancel, lPageTotal
   DATA Cargo

   METHOD New( aTitle, aHead, aFoot, aFont, lSummary, cRptFile, ;
               cResName, lPrinter, lScreen, cFile, oDevice, ;
               cName, cTFmt, cHFmt, cFFmt ) CONSTRUCTOR

   //METHOD FromFile() CONSTRUCTOR   Not available yet!
   //METHOD Resource() CONSTRUCTOR   Not available yet!

   METHOD AddColumn( oColumn ) INLINE Aadd( ::aColumns,oColumn )

   METHOD DelColumn( nColumn ) INLINE Adel( ::aColumns,nColumn ),;
                ASize( ::aColumns, Len( ::aColumns )- 1 )

   METHOD InsColumn(oColumn,;
            nColumn ) INLINE Ains( ::aColumns,nColumn ),;
                   ::aColumns[ nColumn ]:= oColumn

   METHOD AddGroup( oGroup )   INLINE Aadd( ::aGroups,oGroup)

   METHOD DelGroup( nGroup )   INLINE Adel( ::aGroups,nGroup),;
                ASize( ::aGroups, Len( ::aGroups )- 1 )

   METHOD Stabilize()
   METHOD Skip( n )

   METHOD Init()
   METHOD End()

   METHOD StartLine( nHeight )
   METHOD EndLine( nHeight )
   METHOD StartGroup( nGroup)
   METHOD EndGroup( nGroup)
   METHOD StartPage()
   METHOD EndPage()
   METHOD NeedNewPage() INLINE ( ::nRow >= ::nBottomRow )

   METHOD NewLine( nHeight ) INLINE ( ::StartLine( nHeight ),;
                If( ! ::lFirstRow, ::EndLine( nHeight ),) )

   METHOD BackLine( nLine ) INLINE  ::nRow -= ::nStdLineHeight* ;
                If( nLine == nil, 1,nLine )


   METHOD ColTitle()
   METHOD TotalLine(cChar, nGrid)
   METHOD PageTotal()

   METHOD Activate( bFor, bWhile, bInit, bEnd, bStartPage, ;
                    bEndPage, bStartGroup, bEndGroup, ;
                    bStartLine, bEndLine, bChange, bPostEnd, bPostPage, bPostGroup )

   METHOD Play()

   METHOD Margin( nValue, nType, nScale )

   METHOD Say( nCol, xText, nFont, nPad, nRow )

   METHOD SayBitmap( nRow, nCol, cBitmap, nWidth, nHeight, nScale )
   METHOD Box( nRow, nCol, nBottom, nRight, nPen, nScale )
   METHOD Line( nTop, nLeft, nBottom, nRight, nPen, nScale )
   METHOD Shadow( nHeight )
   METHOD Grid( nHeight, nRow, cChar )
   METHOD Separator( nPen, nRow)

   METHOD CellView() INLINE ::lJoin      := .t.,;
              ::lSeparator  := .t.,;
              ::lBoxOnTotal := .t.,;
              AEval( ::aColumns, {|val| val:lGrid := .t.} )

   METHOD PhyWidth( nScale ) INLINE ;
         ( If( nScale == nil,nScale:=1,),;
           PrnGetSize( ::oDevice:hDC )[ 1 ] / ::nLogPixX * ;
           If( nScale == 1,1,2.54)            )

   METHOD PhyHeight( nScale ) INLINE ;
         ( If( nScale == nil,nScale:=1,),;
           PrnGetSize( ::oDevice:hDC )[ 2 ] / ::nLogPixY * ;
           If( nScale == 1,1,2.54)            )

   METHOD SetTxtColor( nColor,nFont ) INLINE            ;
         (If( nColor != nil .and.            ;
             nFont   > 0   .and.            ;
             nFont   <= Len( ::aClrText ),;
            ::aClrText[ nFont] := nColor, ) )

   METHOD SetShdColor( nColor ) INLINE ::nClrShadow := nColor

   METHOD SetPenColor( nColor )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( aTitle, aHead, aFoot, aFont, aPen, lSummary, cRptFile, ;
            cResName, lPrinter, lScreen, cFile, oDevice, cName,;
            cTFmt, cHFmt, cFFmt ) CLASS TReport

   local nFor, nTFmt, nHFmt, nFFmt

   local lFontDefined := .t.,;
      lPenDefined  := .t.

   #ifdef __XPP__
      #undef New
   #endif

   DEFAULT aTitle      := {{|| ""} },;
      aHead      := {{|| ""} },;
      aFoot      := {{|| ""} },;
      aFont      := {},;
      aPen       := {},;
      lSummary   := .f.,;
      cRptFile   := "",;
      cResName   := "",;
      lPrinter   := .f.,;
      lScreen    := .f.,;
      cFile      := "",;
      cTFmt      := "CENTER",;
      cHFmt      := "LEFT",;
      cFFmt      := "LEFT"

   ::aColumns   := {}
   ::aGroups    := {}
   ::bStdFont   := {|| 1 }
   ::bPreview   := {|oDevice| RPreview(oDevice ) }
   ::cRptFile   := cRptFile
   ::cResName   := cResName
   ::cPageTotal   := ""
   ::cGrandTotal  := ""
   ::cCharPattern := CHAR_PATTERN
   ::cFile      := cFile
   ::cName      := cName
   ::nRow       := 0
   ::nPage      := 0
   ::nSeparator := 0
   ::nCounter   := 0
   ::nTotalLine   := RPT_DOUBLELINE
   ::nGroupLine   := RPT_SINGLELINE
   ::nTitleUpLine := RPT_DOUBLELINE
   ::nTitleDnLine := RPT_DOUBLELINE
   ::nClrShadow   := CLR_LIGHTGRAY
   ::lSummary   := lSummary
   ::lStable    := .f.
   ::lPrinter   := lPrinter
   ::lScreen    := lScreen
   ::lFirstRow  := .t.
   ::lCreated   := .f.
   ::lBreak     := .f.
   ::lShadow    := .f.
   ::lJoin      := .f.
   ::lSeparator := .f.
   ::lAutoLand  := .t.
   ::lIsNarrow    := .f.
   ::lBoxOnTotal  := .f.
   ::lNoCancel    := .f.
   ::lPageTotal   := .t.

   if cTFmt == "LEFT"
      nTFmt = RPT_LEFT
   elseif cTFmt == "RIGHT"
      nTFmt = RPT_RIGHT
   elseif cTFmt == "CENTER" .or. cTFmt == "CENTERED"
      nTFmt = RPT_CENTER
   else
      nTFmt = RPT_CENTER
   endif

   if cHFmt == "LEFT"
      nHFmt = RPT_LEFT
   elseif cHFmt == "RIGHT"
      nHFmt = RPT_RIGHT
   elseif cHFmt == "CENTER" .or. cHFmt == "CENTERED"
      nHFmt = RPT_CENTER
   else
      nHFmt = RPT_LEFT
   endif

   if cFFmt == "LEFT"
      nFFmt = RPT_LEFT
   elseif cFFmt == "RIGHT"
      nFFmt = RPT_RIGHT
   elseif cFFmt == "CENTER" .or. cFFmt == "CENTERED"
      nFFmt = RPT_CENTER
   else
      nFFmt = RPT_LEFT
   endif

   /*
   Indicar device
   to indicate device
   */

   if oDevice <> nil
      ::oDevice  := oDevice
      ::lScreen  := oDevice:lMeta
      ::lPrinter := ! ::lScreen
   elseif ::lPrinter
      ::oDevice  := TPrinter():New( cName,.f. )
   elseif ::lScreen
      // Can add a 4th param as .t. ( lModal ) so preview screen
      // will be on top --  TPrinter():New(cName,.f.,.t.,.t.)
      ::oDevice := TPrinter():New( cName,.f.,.t. )
   elseif ! Empty( ::cFile )
      ::oDevice  := TRFile():New( ::cFile )
      ::lPrinter := .f.
   else
      ::oDevice  := TPrinter():New( cName,.f. )
      ::lPrinter := .t.
   endif

   /*
   Nombre del listado
   Name of report
   */

   if Empty( ::cName )
      if ! Empty( ::oDevice:cDocument )
         ::cName := ::oDevice:cDocument
      else
         ::cName := "Printing report"
      endif
   endif

   /*
   Control de que el device es correcto
   Determine if control by the device is correct
   */

   if Empty( ::oDevice:hDC )
      ::lCreated := .f.
      return nil
   else
      ::lCreated := .t.
   endif

   /*
   Pedir coordenadas del device
   Ask for the coordinates of the device
   */

   ::nWidth  := ::oDevice:nHorzRes()
   ::nHeight := ::oDevice:nVertRes()

   /*
   Calcular n§ de pixels por pulgada del device
   Calculation of pixels per inch of the device
   */

   ::nLogPixX := ::oDevice:nLogPixelX()
   ::nLogPixY := ::oDevice:nLogPixelY()

   /*
   Si no ha especificado font asignar ARIAL 10
   if no font specified, assign ARIAL 10
   */

   if Len( aFont ) == 0
      lFontDefined := .f.
      ASize( aFont,1 )
      DEFINE FONT aFont[ 1 ] NAME "ARIAL" SIZE 0, - 10
   endif

   /*
   Si no se ha especificado pen crearlo (por si acaso)
   if no pen specified, create it (just in case )
   */

   if Len( aPen ) == 0
      lPenDefined := .f.
      ASize( aPen,1 )
      DEFINE PEN aPen[ 1 ] STYLE 0 WIDTH 1 COLOR CLR_BLACK
   endif

   /*
   Crear pen para las lineas horizontales igual que el primero definido
   Create pen for horizontal lines equal to the default definition
   */

   DEFINE PEN ::oPenHorz   ;
      STYLE aPen[ 1 ]:nStyle ;
      WIDTH aPen[ 1 ]:nWidth * ::nLogPixX/72 ;
      COLOR aPen[ 1 ]:nColor

   /*
   Crear nuevos fonts basandonos en el Device para ajustar
   el tama¤o de los mismos al device elegido
   Create new fonts based on the Device, adjusting the size
   the same as the selected device
   */

   ::aFont := Array( Len( aFont ) )

   AEval( aFont,;
          { | val, elem | ;
          ::aFont[elem]:= TFont():New( val:cFaceName,;
          Int( val:nWidth* ::nLogPixX / 72 ),;
          Int( val:nHeight* ::nLogPixY / 72 ),;
          .f.,;
          val:lBold,;
          val:nEscapement,;
          val:nOrientation,;
          val:nWeight,;
          val:lItalic,;
          val:lUnderline,;
          val:lStrikeOut,;
          val:nCharSet,;
          val:nOutPrecision,;
          val:nClipPrecision,;
          val:nQuality ) } )

   if !lFontDefined
      aFont[ 1 ]:end()
   endif

   /*
   Crear nuevos Pens basandonos en el device
   Create new Pens based on the device
   */

   ::aPen := Array( Len( aPen ) )

   AEval( aPen, { | val, elem | ;
         ::aPen[elem] := TPen():New( val:nStyle,;
         Int( val:nWidth * ::nLogPixX / 72 ),;
         val:nColor ) } )

   if ! lPenDefined
      aPen[ 1 ]:End()
   endif

   /*
   Crear Matriz de colores para impresi¢n de texto
   Create Matrix of colors for the printing of text
   */

   ::aClrText := Array( Len( ::aFont ) )

   AEval( ::aClrText, {|val,elem| ::aClrText[ elem ] := CLR_BLACK } )

   /*
   Establecer margenes de impresi¢n a 0,2 pulgadas
   Establish default margins for printing at 0.2 inches all around
   */

   ::nLeftMargin  := Int( ::nLogPixX * 0.2 )
   ::nRightMargin := Int( ::nLogPixX * 0.2 )
   ::nTopMargin   := Int( ::nLogPixY * 0.2 )
   ::nDnMargin    := Int( ::nLogPixY * 0.2 )

   /*
   Crear objetos del listado
   Create objects for the report
   */

   ::oHeader := TrLine():New( aHead, Self, nHFmt )
   ::oTitle  := TrLine():New( aTitle, Self, nTFmt )
   ::oFooter := TrLine():New( aFoot, Self, nFFmt )

return Self   // Must return Self here cause 32 bits version

//----------------------------------------------------------------------------//

METHOD Margin( nValue, nType, nScale ) CLASS TReport

   DEFAULT nValue := .2,;
      nType  := RPT_LEFT,;
      nScale := RPT_INCHES

   if nScale == RPT_CMETERS
      nValue := nValue / 2.54
   endif

   do case
      case nType == RPT_TOP
           ::nTopMargin   := Int( ::nLogPixY * nValue )
      case nType == RPT_BOTTOM
           ::nDnMargin   := Int( ::nLogPixY * nValue )
      case nType == RPT_LEFT
           ::nLeftMargin  := Int( ::nLogPixX * nValue )
      case nType == RPT_RIGHT
           ::nRightMargin := Int( ::nLogPixX*nValue )
   endcase

   ::lStable := .f.

return nil

//----------------------------------------------------------------------------//

METHOD Say( nCol, xText, nFont, nPad, nRow ) CLASS TReport

   local nStartCol

   DEFAULT nCol := 1,;
      nFont := 1,;
      xText := "",;
      nRow  := ::nRow,;
      nPad  := RPT_LEFT

   if nCol < 1 .or. nCol > Len( ::aCols )
      nCol := 1
   endif

   if nFont < 1 .or. nFont > Len( ::aFont )
      nFont := 1
   endif

   do case
      case nPad == RPT_LEFT
           nStartCol := ::aCols[ nCol ]

      case nPad == RPT_RIGHT
           nStartCol := ::aCols[ nCol ]+ ;
           ::aColumns[ nCol ]:nWidth
           SetTextAlign( ::oDevice:hDCOut, 2 )

      case nPad == RPT_CENTER
           nStartCol := ::aCols[ nCol ] + ;
           Int( ::aColumns[ nCol ]:nWidth / 2 )
           SetTextAlign( ::oDevice:hDCOut,6)

      otherwise
           nStartCol := ::aCols[ nCol ]
   endcase

   ::oDevice:Say( nRow,;   // This Say() is in Printer.prg
                  nStartCol,;
                  Trim( cValToChar( xText ) ),; // cValToChar( xText ),;
                  ::aFont[ nFont ],;
                  nil,;
                  ::aClrText[ nFont ],,;
                  nPad - 1 )




return nil

//----------------------------------------------------------------------------//

METHOD SayBitmap( nRow, nCol, cBitmap, nWidth, nHeight, nScale ) CLASS TReport

   local nPixWidth, nPixHeight
   local aOffset

   DEFAULT nRow := 0.2,;
      nCol    := 0.2,;
      nWidth  := 1,;
      nHeight := 1,;
      nScale  := RPT_INCHES

   if nScale == RPT_CMETERS
      aOffset := ::oDevice:Cmtr2Pix( nRow, nCol )
      nWidth  := nWidth / 2.54
      nHeight := nHeight / 2.54
   else
      aOffset := ::oDevice:Inch2Pix( nRow, nCol )
   endif

   nPixWidth  := ::nLogPixY*nWidth
   nPixHeight := ::nLogPixX*nHeight

   ::oDevice:SayBitmap( aOffset[ 1 ], aOffset[ 2 ],;
                        cBitmap, nPixWidth, nPixHeight )

return nil

//----------------------------------------------------------------------------//

METHOD Box( nRow, nCol, nBottom, nRight, nPen, nScale ) CLASS TReport

   local aStart, aEnd

   DEFAULT nRow := 0.2,;
      nCol    := 0.2,;
      nBottom := 5,;
      nRight  := 5,;
      nPen    := 1,;
      nScale  := RPT_INCHES

   if nScale == RPT_CMETERS
      aStart := ::oDevice:Cmtr2Pix( nRow, nCol )
      aEnd   := ::oDevice:Cmtr2Pix( nBottom, nRight )
   else
      aStart := ::oDevice:Inch2Pix( nRow, nCol )
      aEnd   := ::oDevice:Inch2Pix( nBottom, nRight )
   endif

   ::oDevice:Box( aStart[ 1 ], aStart[ 2 ],;
                  aEnd[ 1 ], aEnd[ 2 ], ::aPen[ nPen ] )

return nil

//----------------------------------------------------------------------------//

METHOD Line( nRow, nCol, nBottom, nRight, nPen, nScale ) CLASS TReport

   local aStart, aEnd

   DEFAULT nRow  := 0.2,;
      nCol    := 0.2,;
      nBottom := 5,;
      nRight  := 5,;
      nPen    := 1,;
      nScale  := RPT_INCHES

   if nScale == RPT_CMETERS
      aStart := ::oDevice:Cmtr2Pix( nRow, nCol )
      aEnd   := ::oDevice:Cmtr2Pix( nBottom, nRight )
   else
      aStart := ::oDevice:Inch2Pix( nRow, nCol )
      aEnd   := ::oDevice:Inch2Pix( nBottom, nRight )
   endif

   ::oDevice:Line( aStart[ 1 ], aStart[ 2 ],;
                   aEnd[ 1 ], aEnd[ 2 ], ::aPen[ nPen ] )

return nil

//----------------------------------------------------------------------------//

METHOD Shadow ( nHeight ) CLASS TReport

   local nFor, nCols, nGrid

   if ! ::lShadow
      return nil
   endif

   nCols := Len( ::aColumns )

   if ::oShdBrush == nil
      DEFINE BRUSH ::oShdBrush COLOR ::nClrShadow
   endif

   for nfor := 1 to nCols
      if ::aColumns[ nFor ]:lShadow

         if ::aColumns[ nFor ]:lGrid
            nGrid := ::aPen[ ::aColumns[ nFor ]:nPen ]:nWidth * 2
         else
            nGrid := 0
         endif

         SetbkMode( ::oDevice:hDCOut, 1 )

         ::oDevice:FillRect( { ::nRow,;
                               ::aCols[ nFor ] - nGrid,;
                               ::nRow + nHeight,;
                               ::aCols[ nFor ] + ::aColumns[ nFor ]:nWidth + nGrid },;
                               ::oShdBrush )
      endif
   next

return nil

//----------------------------------------------------------------------------//

METHOD Grid ( nHeight, nRow, cChar ) CLASS TReport

   local nFor, nCols

   DEFAULT nHeight := ::nStdLineHeight,;
           nRow    := ::nRow

   if ! ::lGrid .or. Empty( nHeight )
      return nil
   endif

   nCols := Len( ::aColumns )

   if ::lScreen .or. ::lPrinter

      for nfor := 1 to nCols

         if ::aColumns[ nFor ]:lGrid

            SetbkMode( ::oDevice:hDCOut, 1 )

            ::oDevice:Line( nRow,;
                            ::aCols[ nFor ] - ( ::nSeparator / 2 ),;
                            nRow + nHeight,;
                            ::aCols[ nFor ] - ( ::nSeparator / 2 ),;
                            ::aPen[ ::aColumns[ nFor ]:nPen ] )
            ::oDevice:Line( nRow,;
                            ::aCols[ nFor ] + ::aColumns[ nFor ]:nWidth + ( ::nSeparator/ 2 ),;
                            nRow + nHeight,;
                            ::aCols[ nFor ] + ::aColumns[ nFor ]:nWidth + ( ::nSeparator/ 2 ),;
                            ::aPen[ ::aColumns[ nFor ]:nPen ] )
         endif
      next
   else
      if cChar == nil
         cChar := "³"
      endif

      for nfor := 1 to nCols
         if ::aColumns[ nFor ]:lGrid
            ::oDevice:Say( nRow,;
                           ::aCols[ nFor ] - ::nSeparator,;
                           Replicate(cChar, ::nSeparator ),;
                           ::aFont[eval( ::bStdFont ) ],;
                           ::nSeparator )

            ::oDevice:Say( nRow,;
                           ::aCols[ nFor ]+ ::aColumns[ nFor ]:nWidth,;
                           Replicate(cChar, ::nSeparator ),;
                           ::aFont[eval( ::bStdFont ) ],;
                           ::nSeparator )
         endif
      next
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Separator ( nPen, nRow) CLASS TReport

   local oPen
   local cSeparator
   local nLeft, nRight

   DEFAULT nRow := ::nRow, nPen := 1

   nLeft  := ::nMargin
   nRight := nLeft

   AEval( ::aColumns, { | v | nRight += v:nWidth } )

   nRight += ( ( Len( ::aColumns )- 1 ) * ::nSeparator )

   if ! ::lPrinter .and. ! ::lScreen

      cSeparator := ""
      AEval( ::aColumns,;
         {|val| cSeparator += Replicate( "Ä", Val:nWidth) + "Å" } )
      cSeparator := "Ã" + Substr( cSeparator,1, Len( cSeparator ) - 1 ) + "´"
      ::oDevice:Say( nRow, nLeft - ::nSeparator, cSeparator )
      ::Shadow( ::nStdLineHeight )
      ::nRow += ::nStdLineHeight
      return nil

   endif

   if ::aColumns[ 1 ]:lGrid
      nLeft -= Int( ::nSeparator/ 2 )
   endif

   if Atail( ::aColumns ):lGrid
      nRight += Int( ::nSeparator/ 2 )
   endif

   if nPen != nil .and. nPen > 0 .and. nPen < Len( ::aPen )
      oPen := ::aPen[ nPen ]
   else
      oPen := ::oPenHorz
   endif

   //::oDevice:Line( nRow, nLeft, nRow, nRight, oPen )
   AEval( ::aColumns, {|v| v:Separator( nRow) } )
   ::NewLine( oPen:nWidth * 4 )

return nil

//----------------------------------------------------------------------------//

METHOD SetPenColor( nColor ) CLASS TReport

   if nColor == nil
      return nil
   endif

   ::oPenHorz:End()

   DEFINE PEN ::oPenHorz ;
      STYLE 0 ;
      WIDTH Int( 1 * ::nLogPixX / 72 ) ;
      COLOR nColor

return nil

//----------------------------------------------------------------------------//

METHOD Activate( bFor, bWhile, bInit, bEnd, bStartPage, ;
                 bEndPage, bStartGroup, bEndGroup, ;
                 bStartLine, bEndLine, bChange, ;
                 bPostEnd, bPostPage, bPostGroup ;
               ) CLASS TReport


   local oPagina
   local hActWnd  := GetActiveWindow()
   LOCAL oApp     := ZApp():New()                    // CAF
   LOCAL cResFile := oApp:cDirDll + '\Prev32.dll'   // CAF

   DEFAULT bfor := {|| .t. }, bWhile := {|| ! Eof() }

   ::hOldRes := GetResources()
/*
   #ifdef __CLIPPER__
      SET RESOURCES to "preview.dll"
   #else
      SET RESOURCES to "prev32.dll"
   #endif
*/

*   SET RESOURCES TO cResFile         // CAF
*   if GetResources() < 32            // CAF
   if SetResources( cResFile ) < 32   // CAF
/*
      #ifdef __CLIPPER__
         MsgStop( "Preview.dll not found", "Error" )
      #else
         MsgStop( "Prev32.dll not found", "Error" )
      #endif
*/
      MsgStop( cResFile + " not found", "Error" )  // CAF
      SetResources( ::hOldRes )
      return nil
   endif

   DEFAULT ::bfor    := bfor,;
       ::bWhile      := bWhile,;
       ::bInit       := bInit,;
       ::bEnd        := bEnd,;
       ::bStartPage  := bStartPage,;
       ::bEndPage    := bEndPage,;
       ::bStartGroup := bStartGroup,;
       ::bEndGroup   := bEndGroup,;
       ::bStartLine  := bStartLine,;
       ::bEndLine    := bEndLine,;
       ::bChange     := bChange,;
       ::bPostEnd    := bPostEnd,;
       ::bPostPage   := bPostPage,;
       ::bPostGroup  := bPostGroup

   /*
   Si hay una condición for y ademas grupos entonces
   nos posicionamos en el primer registro válido
   if there is a condition for in addition to groups, then
   position us in the first valid record
   */

   if Len( ::aGroups ) > 0
      while Eval( ::bWhile ) .and. ! Eval( ::bFor )
         SysRefresh()
         ::Skip( 1 )
      end
   endif

   /*
   Estabilizar el listado
   Stabilize the report
   */

   if ! ::lCreated
      ::End()
      return nil
   endif

   ::Stabilize()

   if ::lIsNarrow
      ::oDevice:SetLandScape()
      ::nWidth  := ::oDevice:nHorzRes()
      ::nHeight := ::oDevice:nVertRes()
      ::Stabilize()
   endif

   if ! ::lStable
      ::End()
      return nil
   endif

   /*
   Creaci¢n de la ventana de impresi¢n
   Creation of the window for printing
   */

   if ! ::lScreen

      DEFINE DIALOG ::oRptWnd TITLE ::cName RESOURCE "PRINT_PROC"

      REDEFINE BUTTON ID IDCANCEL OF ::oRptWnd ;
         ACTION ( ::lBreak := .t., ::oRptWnd:End() ) ;
         WHEN ( ! ::lNoCancel )

      REDEFINE SAY oPagina VAR ::nPage ID 101 OF ::oRptWnd

      ::oRptWnd:bPainted := {|| If( ::nPage > 0,oPagina:Refresh(), ) }

      ::oRptWnd:bStart := {|| ::Play(), ::oRptWnd:End() }

      ACTIVATE DIALOG ::oRptWnd CENTER

   else

      DEFINE DIALOG ::oRptWnd TITLE ::cName RESOURCE "PREVIEW_PROC"

      REDEFINE BUTTON ID IDCANCEL OF ::oRptWnd ;
         ACTION ( ::lBreak := .t., ::oRptWnd:End() ) ;
         WHEN ( ! ::lNoCancel )

      REDEFINE SAY oPagina VAR ::nPage ID 101 OF ::oRptWnd

      ::oRptWnd:bPainted := {|| If( ::nPage> 0,oPagina:Refresh(), ) }

      ::oRptWnd:bStart := {|| ::Play(), ::oRptWnd:End() }

      ACTIVATE DIALOG ::oRptWnd CENTER

      Eval( ::bPreview, ::oDevice )

   endif

return nil

//----------------------------------------------------------------------------//

METHOD Play() CLASS TReport

   local nColumns, nGroups, nFor1, nFor2, nFor3, nTotalValue
   local lSeparator, lFor

   /*
   Inicializar variables
   Initialize variables
   */

   nColumns := Len( ::aColumns )
   nGroups  := Len( ::aGroups )

   /*
   Comienzo de la Impresi¢n
   Commence printing
   */

   ::StartPage()
   ::Init()

   /*
   Reset de totales por grupo
   Reset the totals of the group
   */

   #ifdef __CLIPPER__
      ASend( ::aGroups, "Reset" )
   #else
      ASend( ::aGroups, "Reset()" )
   #endif

   /*
   Start de grupo
   Start of group
   */

   AEval( ::aGroups, {| val, elem | ::StartGroup( elem ) } )

   /*
   Bucle de rastreo
   Loop of track
   */

   while ! ::lBreak .and. Eval( ::bWhile )

      /*
      Refresh
      */

      SysRefresh()

      /*
      Comprobar condición for
      Check condition of FOR
      */

      if ! Eval( ::bFor )
         ::Skip( 1 )
         LOOP
      endif

      /*
      Condición de Grupo
      Condition of group
      */

      #ifdef __CLIPPER__
         if ::lGroup
            ASend( ::aGroups, "Evaluate" )
         endif
      #else
         if ::lGroup
            ASend( ::aGroups, "Evaluate()" )
         endif
      #endif

      /*
      Cuerpo del Listado
      Body of the report
      */

      // si hay un code-block de evaluación por cada registro a procesar llamarlo
      // if there is a codeblock for evaluating each record, to process to name it

      if ::bStartRecord != nil
         Eval( ::bStartRecord, Self )
      endif

      for nFor1 := 1 to ::nMaxData

          ::nDataLine := nFor1

          if ! ::lSummary
             lSeparator := ( ::lSeparator .and. ;
             ! ::lFirstRow .and. ;
             nFor1 == 1 )
             ::StartLine( ::aDataHeight[ nFor1 ], lSeparator )
          endif

          for nFor2 := 1 to nColumns

             if ! ::lSummary
                ::aColumns[ nFor2 ]:SayData( ::nRow, ::aCols[ nFor2 ], nFor1 )
             endif

             /*
             Control Sumas
             Control sums
             */

             if ::lTotal .and. ;
             ::aColumns[ nFor2 ]:lTotal .and. ;
             ( ! ::aColumns[ nFor2 ]:lTotalExpr .or. ;
             Eval( ::aColumns[ nFor2 ]:bTotalExpr ) )

                nTotalValue := Eval( ::aData[ nFor2 ][ nFor1 ] )

                if ValType( nTotalValue ) == "N"

                   ::aColumns[ nFor2 ]:ntotal += nTotalValue

                   if ::lGroup
                      for nFor3 := 1 to nGroups
                          ::aGroups[ nFor3  ]:aTotal[ nFor2 ] += nTotalValue
                      next
                   endif
               endif
            endif
          next

          if ! ::lSummary
             ::EndLine( ::aDataHeight[ nFor1 ] )
          endif

      next

      /*
      Proximo registro o equivalente
      Near record or equivalent
      */

      ::Skip( 1 )

      /*
      Control Grupo
      Control group
      */

      if ::lGroup

         while Eval( ::bWhile ) .and. ! Eval( ::bFor )
            SysRefresh()
            ::Skip( 1 )
         end

         for nFor1 := nGroups to 1 step - 1
            if ::aGroups[ nFor1 ]:Check()
               ::EndGroup( nFor1 )
            endif
         next
         for nFor1 := 1 to nGroups
            if ::aGroups[ nFor1 ]:lNeedStart
               ::StartGroup( nFor1 )
            endif
         next
      endif
   end

   if ::lGroup
      for nFor1 := nGroups to 1 step - 1
          if ! Empty( ::aGroups[ nFor1 ]:nCounter )
             ::EndGroup( nFor1 )
          endif
      next
   endif

   ::End()

return nil

//----------------------------------------------------------------------------//

METHOD Stabilize() CLASS TReport

   local nColumns, nFor1, nFor2, nMaxHeight, nPrnWidth

   nColumns   := Len( ::aColumns )
   nMaxHeight := 0

   if nColumns == 0
      ::lCreated := .f.
      return nil            // No hay columnas
   endif

   /*
   Calculo del tama¤o del separador de columnas
   Calculation of the size of the separation of the columns
   */

   if Empty( ::nSeparator )
      ::nSeparator := ::oDevice:GetTextWidth( ::cCharPattern, ::aFont[ Eval( ::bStdFont ) ] )
   endif

   /*
   Cálculo del alto standard de una linea
   Calculation of the standard height of one line
   */

   ::nStdLineHeight := ::oDevice:GetTextHeight( ::cCharPattern, ::aFont[ Eval( ::bStdFont ) ] )

   /*
   Cálculo del número maximo de titulos y datos pasados a los objetos
   columna
   Calculation of the maximum number of titles and data passed to the column
   objects
   */

   ::nMaxTitle := 0
   ::nMaxData  := 0

   AEval( ::aColumns, {|Val| ::nMaxTitle := Max( Len( Val:aTitle ), ::nMaxTitle ) } )
   AEval( ::aColumns, {|Val| ::nMaxData  := Max( Len( Val:aData), ::nMaxData) } )

   /*
   Generar matriz de trabajo para titulos
   Generate matrix of text for titles
   */

   ::aText := Array( nColumns, ::nMaxTitle )

   for nFor1 := 1 to nColumns
      for nFor2 := 1 to ::nMaxTitle
         if Len( ::aColumns[ nFor1 ]:aTitle ) < nFor2
            ::aText[ nFor1 ][ nFor2 ] := {|| "" }
         else
            ::aText[ nFor1 ][ nFor2 ] := ::aColumns[ nFor1 ]:aTitle[ nFor2 ]
         endif
      next
   next

   /*
   Generar matrices de trabajo para datos de las columnas
   Generate matrices of text for data of the columns
   */

   ::aData := Array( nColumns, ::nMaxData)

   for nFor1 := 1 to nColumns
      for nFor2 := 1 to ::nMaxData
         if Len( ::aColumns[ nFor1 ]:aData) < nFor2
            ::aData[ nFor1 ][ nFor2 ] := {|| "" }
         else
            ::aData[ nFor1 ][ nFor2 ] := ::aColumns[ nFor1 ]:aData[ nFor2 ]
         endif
      next
   next

   /*
   Comprobar si hay grupos
   Check if any groups
   */

   ::lGroup := ( Len( ::aGroups ) > 0 )

   /*
   Estabilizar objetos
   Stabilize objects
   */

   ::oHeader:Stabilize()
   ::oFooter:Stabilize()
   ::oTitle:Stabilize()

   AEval( ::aGroups, {|val,elem| val:Stabilize( elem ) } )
   AEval( ::aColumns, {|val,elem| val:Stabilize( elem ) } )

   /*
   Comprobar si hay algun total
   Check if there is anything in the total
   */

   ::lTotal := .f.
   AEval( ::aColumns, {|Val| If( Val:lTotal, ::lTotal := .t., nil ) } )

   /*
   Comprobar si hay alguna columna con Sombra
   Check if there are any columns with a shadow
   */

   ::lShadow := .f.
   AEval( ::aColumns, {|Val| If( Val:lShadow, ::lShadow := .t., nil ) } )

   /*
   Comprobar si hay alguna columna con Grid
   Check if there are any columns with a grid
   */

   ::lGrid := .f.
   AEval( ::aColumns, {|Val| If( Val:lGrid, ::lGrid := .t., nil ) } )

   /*
   Cálculo del ancho del listado
   Calculation of the width of the report
   */

   ::nRptWidth := 0
   AEval( ::aColumns, {|Val| ::nRptWidth += Val:nWidth + ::nSeparator } )

   ::nRptWidth -= ::nSeparator

   ::nRptWidth := Max( ::nRptWidth, ::oTitle:nWidth )
   ::nRptWidth := Max( ::nRptWidth, ::oHeader:nWidth )
   ::nRptWidth := Max( ::nRptWidth, ::oFooter:nWidth )

   /*
   Si es a un fichero Ascii dimensionar su ancho
   if it is an Ascii file, what is the width
   */

   if ! ::lPrinter .and. ! ::lScreen
      ::oDevice:nWidth = ::nRptWidth+ ( ::nSeparator * 10 )
      ::nWidth = ::oDevice:nHorzRes()
   endif

   /*
   Si el listado es m s ancho que la p gina advertirlo
   if the report is wider than the page, give a warning
   */

   if ::nRptWidth > ::nWidth .and. ( ::lScreen .or. ::lPrinter )
      if ::lAutoLand .and. ;
         ! ::lIsNarrow .and. ;
         ::oDevice:GetOrientation() == PORTRAIT
         ::lStable   := .f.
         ::lIsNarrow := .t.
         return nil
      endif

      if ! MsgYesNo( TXT_REPORT_WIDTH, TXT_ATENTION )
         ::lStable := .f.
         return nil
      endif
   endif

   ::nRptWidth := Min( ::nRptWidth, ::nWidth )


   /*
   Margen del Listado
   Margin of the report
   */

   nPrnWidth := ::nWidth - ::nLeftMargin - ::nRightMargin
   ::nMargin := max(Int( ( nPrnWidth- ::nRptWidth ) / 2 ), 0 ) + ::nLeftMargin

   /*
   Calculo de las distintas coordenadas de las columnas del listado
   Calculation of the various coordinates of the report columns
   */

   ::aCols := Array( nColumns )

   ::aCols[ 1 ] := If( ::aColumns[ 1 ]:nCol> 0, ::aColumns[ 1 ]:nCol, ::nMargin )
   ::aColumns[ 1 ]:nCalCol := ::aCols[ 1 ]

   for nFor1 := 2 to nColumns
      if ::aColumns[ nFor1 ]:nCol> 0
         ::aCols[ nFor1 ] := ::aColumns[ nFor1 ]:nCol
      else
         ::aCols[ nFor1 ] := ::aCols[ nFor1- 1 ] + ;
         ::aColumns[ nFor1- 1 ]:nWidth + ::nSeparator
      endif
      ::aColumns[ nFor1 ]:nCalCol := ::aCols[ nFor1 ]
   next

   /*
   Estabilizar lineas fijas de nuevo indicando coordenadas
   Stabilize newly fixed line margin coordinates
   */

   ::oHeader:Stabilize( ::nTopMargin, ::nMargin )
   ::oTitle:Stabilize( ::oHeader:nHeight + ::nTopMargin, ::nMargin )
   ::oFooter:Stabilize( ::nHeight - ::nDnMargin - ::oFooter:nHeight, ::nMargin )

   /*
   Inicializar variables de coordenadas
   Initialize variables of the coordinates
   */

   AEval( ::aColumns,;
      {|val| nMaxHeight := Max( nMaxHeight, Val:nDataHeight ) } )

   ::nTitleRow := ::oHeader:nHeight + ::oTitle:nHeight + ::nTopMargin

   ::nBottomRow := ::nHeight - ::oFooter:nHeight - ::nDnMargin - ;
         If( ! ::lTotal,0, ::nStdLineHeight + nMaxHeight ) - ;
         If( ! ::lTotal .and. ::lSeparator, ::oPenHorz:nWidth*10,0 ) - ;
         If( ::lTotal .and. ::lBoxOnTotal, ::nStdLineHeight,0 )


   /*
   Calcular alto de los titulos
   Calculate height of the titles
   */

   nMaxHeight := 0
   ::nTitleHeight := 0

   for nFor1 := 1 to ::nMaxTitle
      for nFor2 := 1 to nColumns
         nMaxHeight := Max( nMaxHeight, ::aColumns[ nFor2 ]:nTitleHeight )
      next
      ::nTitleHeight += nMaxHeight
   next

   /*
   Calcular máximo alto de cada linea de datos
   Calculate maximum height of each line of data
   */

   ::aDataHeight := Afill( Array( ::nMaxData ), 0 )

   for nFor1 := 1 to ::nMaxData
      AEval( ::aColumns,;
      {|val| ::aDataHeight[ nFor1 ] := Max( ::aDataHeight[ nFor1 ],;
                      val:nDataHeight ) } )
   next

   /*
   Calcular coordenadas de impresi¢n de datos
   Calculate coordinates for printing of data
   */

   ::nFirstdRow := ::nTitleRow + ;
           If( ! Empty( ::nTitleUpLine ), ::nStdLineHeight, 0 ) + ;
            ::nTitleHeight + ;
           If( ! Empty( ::nTitleDnLine ), ::nStdLineHeight, 0 )

   ::nLastdRow  := ::nBottomRow - ;
           If( ::lTotal, ::nStdLineHeight/ 2,0 ) - ;
           If( ! ::lTotal .and. ::lSeparator, ::oPenHorz:nWidth * 10, 0 ) -;
           If( ::lTotal .and. ::lBoxOnTotal, ::nStdLineHeight, 0 )

   /*
   Indicar que ya esta estable
   Indicate if already is stable
   */

   ::lStable := .t.
   ::lFinish := .f.

return nil

//----------------------------------------------------------------------------//

METHOD Init() CLASS TReport

   if ::bInit != nil
      Eval( ::bInit, Self )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TReport

   ::lFinish := .t.

   if ! ::lCreated .or. ! ::lStable

      if ::oShdBrush != nil
         ::oShdBrush:end()
      endif

      #ifndef __XPP__
         ASend( ::aFont, "End" )
         ASend( ::aPen, "End" )
      #else
         ASend( ::aFont, "_End()" )
         ASend( ::aPen, "_End()" )
      #endif

      if ::oPenHorz != nil
         ::oPenHorz:End()
      endif

      ::oDevice:End()
      SetResources( ::hOldRes )
      return nil

   endif

   if ! ::lBreak .and. ::bEnd != nil
      Eval( ::bEnd, Self )
   endif

   ::EndPage()

   SetResources( ::hOldRes )

   if ! ::lScreen
      ::oDevice:End()
   endif


   if ::oShdBrush != nil
      ::oShdBrush:end()
   endif

   #ifndef __XPP__
      ASend( ::aFont, "End" )
      ASend( ::aPen, "End" )
   #else
      ASend( ::aFont, "_End()" )
      ASend( ::aPen, "_End()" )
   #endif

   ::oPenHorz:End()

return nil

//----------------------------------------------------------------------------//

METHOD Skip( n ) CLASS TReport

   static lRunning := .f.

   ::nCounter++

   if ::bChange != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bChange, Self )
      lRunning := .f.
   endif

   if ::bSkip != nil
      return Eval( ::bSkip, n )
   endif

return DbSkip( n )

//----------------------------------------------------------------------------//

METHOD StartPage() CLASS TReport

   static lRunning := .f.

   ::oDevice:StartPage()

   ::nPage++

   ::oRptWnd:Refresh()

   if ::bStartPage != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bStartPage, Self )
      lRunning := .f.
   endif

   ::oHeader:Say()
   ::oTitle:Say()
   ::ColTitle()
   ::lFirstRow := .t.

return nil

//----------------------------------------------------------------------------//

METHOD EndPage() CLASS TReport

   static lRunning := .f.

   if ::bEndPage != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bEndPage, Self )
      lRunning := .f.
   endif

   ::PageTotal()
   ::oFooter:Say()

   if ::bPostPage != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bPostPage, Self )
      lRunning := .f.
   endif

   if ! ::lBreak .and. ::lFinish .and. ::bPostEnd != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bPostEnd, Self )
      lRunning := .f.
   endif

   ::oDevice:EndPage()

   if ! ::lFinish
      ::StartPage()
   endif

return nil

//----------------------------------------------------------------------------//

METHOD StartLine( nHeight, lSeparator ) CLASS TReport

   static lRunning := .f.

   DEFAULT nHeight   := ::nStdLineHeight,;
      lSeparator := .f.

   if nHeight == 0
      return nil
   endif

   if ( nHeight + ::nRow) >= ::nBottomRow
      ::EndPage()
      lSeparator := .f.
   endif

   if lSeparator
      ::Separator()
   endif

   ::Shadow( nHeight )
   ::Grid( nHeight )

   if ::bStartLine != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bStartLine, Self )
      lRunning := .f.
   endif

return nil

//----------------------------------------------------------------------------//

METHOD EndLine( nHeight ) CLASS TReport

   static lRunning := .f.

   DEFAULT nHeight := ::nStdLineHeight

   if ::bEndLine != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bEndLine, Self)
      lRunning := .f.
   endif

   ::nRow      += nHeight
   ::lFirstRow := .f.

   if ::NeedNewPage()
      ::EndPage()
   endif

return nil

//----------------------------------------------------------------------------//

METHOD StartGroup( nGroup ) CLASS TReport

   static lRunning := .f.

   ::aGroups[ nGroup]:lNeedStart := .f.

   if ! Eval( ::bWhile ) // .or. ! Eval( ::bFor )
      return nil
   endif

   if ::bStartGroup != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bStartGroup, ::aGroups[ nGroup] )
      lRunning := .f.
   endif

   if ::aGroups[ nGroup]:lHeader
      ::StartLine( ::aGroups[ nGroup]:nHeaderHeight )
      ::aGroups[ nGroup]:Header( ::nRow)
      ::EndLine( ::aGroups[ nGroup]:nHeaderHeight )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD EndGroup( nGroup ) CLASS TReport

   static lRunning := .f.

   if ::bEndGroup != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bEndGroup, ::aGroups[ nGroup ] )
      lRunning := .f.
   endif

   if ! ::lSummary .and. ::lTotal
      ::StartLine( ::aGroups[ nGroup ]:nFooterHeight * 2 )
      ::TotalLine( ::nGroupLine, GRID_ABOVE )
   endif

   if ::aGroups[ nGroup ]:lFooter
      ::StartLine( ::aGroups[ nGroup ]:nFooterHeight )
      ::aGroups[ nGroup ]:Footer( ::nRow )
      ::EndLine( ::aGroups[ nGroup ]:nFooterHeight )
   endif

   if ::bPostGroup != nil .and. !lRunning
      lRunning := .t.
      Eval( ::bPostGroup, ::aGroups[ nGroup ] )
      lRunning := .f.
   endif

   if ! ::lFirstRow .and. ;
      ::aGroups[ nGroup]:lEject .and. ;
      Eval( ::bWhile ) .and. ;
      Eval( ::bFor )

      ::EndPage()
   endif

   ::aGroups[ nGroup]:Reset()
   ::aGroups[ nGroup]:lNeedStart := .t.

return nil

//----------------------------------------------------------------------------//

METHOD PageTotal() CLASS TReport

   local nFor, nColumns

   /*
   Si no hay ningun total no hacer nada (salvo separator )
   if there is no total, don't do anything (except for separator )
   */

   if ( ! ::lTotal ) .or. ( ! ::lPageTotal .and. ! ::lFinish )
      if ::lSeparator .or. ::lJoin
         ::TotalLine( ::nTotalLine, GRID_ABOVE )
      endif
      return ( nil )
   endif

   nColumns = Len( ::aColumns )

   /*
   Mostrar linea de totales
   to show line of totals
   */

   if ::lBoxOnTotal
      ::TotalLine( ::nTotalLine, GRID_ABOBEL )
      ::Grid()
   else
      ::TotalLine( ::nTotalLine, GRID_ABOVE )
   endif

   /*
   Imprimir leyenda de totales (si esta definida, ojo por defecto no esta)
   Print out the totals (if defined, check if don't exist )
   */

   if ::lFinish
      if ! Empty( ::cGrandTotal )
      ::oDevice:Say( ::nRow,;
            ::aCols[ 1 ],;
            ::cGrandTotal,;
            ::aFont[eval( ::bStdFont ) ],;
            nil,;
            ::aClrText[eval( ::bStdFont ) ],2 )
      endif
   else
      if ! Empty( ::cPageTotal )
      ::oDevice:Say( ::nRow,;
            ::aCols[ 1 ],;
            ::cPageTotal,;
            ::aFont[eval( ::bStdFont ) ],;
            nil,;
            ::aClrText[eval( ::bStdFont ) ],2 )
      endif
   endif

   /*
   Imprimir los totales para las columnas que lo lleven
   Print totals for the columns
   */

   for nfor := 1 to nColumns
      ::aColumns[ nFor ]:SayTotal( ::nRow, ::aCols[ nFor ] )
   next

   ::nRow += ::nStdLineHeight

   if ::lBoxOnTotal
      ::TotalLine( ::nTotalLine, GRID_ABOVE )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD ColTitle() CLASS TReport

   local nFor1, nFor2, nColumns, nMaxHeight, nBegRow, nEndRow

   nColumns   := Len( ::aColumns )
   nMaxHeight := 0

   ::nRow := ::nTitleRow

   /*
   Imprimir linea superior de titulos
   Print line above the titles
   */

   ::TotalLine( ::nTitleUpLine, GRID_BELOW )

   /*
   Descriptores de titulos de cada columna
   Descriptors of titles of each column
   */

   for nFor1 := 1 to ::nMaxTitle

      for nFor2 := 1 to nColumns

         ::aColumns[ nFor2 ]:saytitle( ::nRow,;
                   ::aCols[ nFor2 ],;
                   nFor1 )
         nMaxHeight := Max( nMaxHeight, ::aColumns[ nFor2 ]:nTitleHeight )
      next

      if ! Empty( ::nTitleUpLine )
         ::Grid( nMaxHeight )
      endif

      ::nRow += nMaxHeight
      nMaxHeight := 0

   next

   /*
   Imprimir linea inferior de titulos
   Print line below the titles
   */

   ::TotalLine( ::nTitleDnLine, GRID_ABOBEL )

   ::lFirstRow := .t.

return nil

//----------------------------------------------------------------------------//

METHOD TotalLine( nType, nGrid) CLASS TReport

   local nFor, nColumns, nJoin, nGridRow, nGridHeight, nHeight
   local cChar, cLeft, cRight

   if nType == nil .or. Empty( nType )
      return nil
   endif

   DEFAULT nGrid := GRID_ABOVE

   nJoin      := If( ::lJoin, ::nSeparator / 2, 0 )
   nGridRow   := 0
   nGridHeight := 0
   cChar      := "³"
   cLeft      := "À"
   cRight     := "Ù"

   nColumns = Len( ::aColumns )

   if nType == RPT_SINGLELINE

      if ::lScreen .or. ::lPrinter

         nHeight := Int( ::oPenHorz:nWidth*10 )

         do case
            case nGrid == GRID_ABOVE
                 nGridRow   := ::nRow
                 nGridHeight := Int( nHeight*.5 )

            case nGrid == GRID_BELOW
                 nGridRow   := ::nRow+Int( nHeight*.5 )
                 nGridHeight := Int( nHeight*.5 )

            case nGrid == GRID_ABOBEL
                 nGridRow   := ::nRow
                 nGridHeight := nHeight
         endcase

         ::Grid( nGridHeight, nGridRow, cChar )

         for nfor := 1 to nColumns
            ::oDevice:Line( ::nRow + Int( nHeight * 0.5 ),;
            ::aCols[ nFor ] - nJoin,;
            ::nRow + Int( nHeight * 0.5 ),;
            ::aCols[ nFor ]+ ::aColumns[ nFor ]:nWidth + nJoin,;
            ::oPenHorz )
         next

      else
         nHeight     = ::nStdLineHeight
         nGridRow    = ::nRow
         nGridHeight = nHeight

         do case
            case nGrid == GRID_ABOVE
                 cChar  := "Á"
                 cLeft  := "À"
                 cRight := "Ù"

            case nGrid == GRID_BELOW
                 cChar  := "Â"
                 cLeft  := "Ú"
                 cRight := "¿"

            case nGrid == GRID_ABOBEL
                 cChar  := "Å"
                 cLeft  := "Ã"
                 cRight := "´"
         endcase

         ::Grid( nGridHeight, nGridRow, cChar )

         for nfor := 1 to nColumns

            ::oDevice:Say( ::nRow,;
                           ::aCols[ nFor ],;
                           Replicate("Ä", ::aColumns[ nFor ]:nWidth),;
                           ::aFont[ Eval( ::bStdFont ) ],;
                           ::aColumns[ nFor ]:nWidth )

            if nfor == 1 .and. ::aColumns[ nFor ]:lGrid
               ::oDevice:Say( ::nRow,;
                              ::aCols[ nFor ] - 1,;
                              cLeft,;
                              ::aFont[eval( ::bStdFont ) ],1 )
            endif

            if nfor == nColumns .and. ::aColumns[ nFor ]:lGrid
               ::oDevice:Say( ::nRow,;
                              ::aCols[ nFor ]+ ::aColumns[ nFor ]:nWidth,;
                              cRight,;
                              ::aFont[ Eval( ::bStdFont ) ], 1 )
            endif
         next
      endif

   elseif nType == RPT_DOUBLELINE

      if ::lScreen .or. ::lPrinter

         nHeight := ::oPenHorz:nWidth*10

         do case
            case nGrid == GRID_ABOVE
                 nGridRow   := ::nRow
                 nGridHeight := Int( nHeight * 0.6 )

            case nGrid == GRID_BELOW
                 nGridRow   := ::nRow+Int( nHeight * 0.4 )
                 nGridHeight := Int( nHeight * 0.6 )

            case nGrid == GRID_ABOBEL
                 nGridRow   := ::nRow
                 nGridHeight := nHeight
         endcase

         ::Grid( nGridHeight, nGridRow, cChar )

         for nfor := 1 to nColumns

             ::oDevice:Line( ::nRow + Int( nHeight * .4 ),;
             ::aCols[ nFor ] - nJoin,;
             ::nRow + Int( nHeight * .4 ),;
             ::aCols[ nFor ]+ ::aColumns[ nFor ]:nWidth + nJoin,;
             ::oPenHorz )

            ::oDevice:Line( ::nRow+Int( nHeight*.6),;
                            ::aCols[ nFor ] - nJoin,;
                            ::nRow+Int( nHeight*.6),;
                            ::aCols[ nFor ] + ::aColumns[ nFor ]:nWidth + nJoin,;
                            ::oPenHorz )
         next

      else

         nHeight     = ::nStdLineHeight
         nGridRow    = ::nRow
         nGridHeight = nHeight

         do case
            case nGrid == GRID_ABOVE
                 cChar  := "Ï"
                 cLeft  := "Ô"
                 cRight := "¾"

            case nGrid == GRID_BELOW
                 cChar  := "Ñ"
                 cLeft  := "Õ"
                 cRight := "¸"

            case nGrid == GRID_ABOBEL
                 cChar  := "Ø"
                 cLeft  := "Æ"
                 cRight := "µ"
         endcase

         ::Grid( nGridHeight, nGridRow, cChar )

         for nfor := 1 to nColumns

            ::oDevice:Say( ::nRow,;
                           ::aCols[ nFor ],;
                           Replicate( "Í", ::aColumns[ nFor ]:nWidth ),;
                           ::aFont[ Eval( ::bStdFont ) ],;
                           ::aColumns[ nFor ]:nWidth )

            if nfor == 1 .and. ::aColumns[ nFor ]:lGrid
               ::oDevice:Say( ::nRow,;
                              ::aCols[ nFor ] - 1,;
                              cLeft,;
                              ::aFont[ Eval( ::bStdFont ) ], 1 )
            endif

            if nfor == nColumns .and. ::aColumns[ nFor ]:lGrid
               ::oDevice:Say( ::nRow,;
                              ::aCols[ nFor ]+ ::aColumns[ nFor ]:nWidth,;
                              cRight,;
                              ::aFont[ Eval( ::bStdFont ) ], 1 )
            endif
         next
      endif
   endif

   ::nRow += nHeight

return nil

//----------------------------------------------------------------------------//
