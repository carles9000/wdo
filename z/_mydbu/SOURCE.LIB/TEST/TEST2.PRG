#include 'fivewin.ch'
#include 'adodef.ch'  // in \fwh\include folder
#include 'ord.ch'
#include 'xbrowse.ch'

REQUEST DBFCDX

function Main()

   local oBrw, oDlg, uData
   local oFont

   SET EXCLUSIVE OFF
   SET DELETED ON
   SET OPTIMIZE ON

   SetGetColorFocus()

   uData    := OpenData()

   DEFINE FONT oFont NAME 'TAHOMA' SIZE 0,-12
   DEFINE DIALOG oDlg SIZE 640,460 PIXEL TITLE 'XBrowse Row Edit' ;
      FONT oFont

   @ 10,10 XBROWSE oBrw SIZE -10,-30 PIXEL OF oDlg ;
      COLUMNS 'First', 'City', 'Age', 'Salary' ;
      PICTURES nil, nil, '999', '99,999,999.99' ;
      OBJECT uData ;
      AUTOSORT CELL LINES NOBORDER ;
      ON DBLCLICK RowEdit( oBrw:CurrentRow() )

   WITH OBJECT oBrw
      :nStretchCol  := STRETCHCOL_WIDEST
      :CreateFromCode()
   END

   @ 210, 10 BUTTON 'Edit'  SIZE 40,14 PIXEL OF oDlg ACTION RowEdit( oBrw:CurrentRow() )
   @ 210,270 BUTTON 'Close' SIZE 40,14 PIXEL OF oDlg ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED
   RELEASE FONT oFont

   CloseData( uData )

return nil

static function RowEdit( oRow )

   LOCAL oDlg

   DEFINE DIALOG oDlg SIZE 300,200 PIXEL TITLE 'Edit Customer' ;
      FONT oRow:oBrw:oFont

   @  10, 10 SAY 'First' SIZE 40,10 PIXEL OF oDlg RIGHT
   @  10, 60 GET oRow:First SIZE 80,12 PIXEL OF oDlg UPDATE ;
            VALID ( oDlg:AEvalWhen(), .t. )

   @  25, 10 SAY 'City' SIZE 40,10 PIXEL OF oDlg RIGHT
   @  25, 60 GET oRow:City SIZE 80,12 PIXEL OF oDlg UPDATE ;
            VALID ( oDlg:AEvalWhen(), .t. )

   @  40, 10 SAY 'Age' SIZE 40,10 PIXEL OF oDlg RIGHT
   @  40, 60 GET oRow:Age ;
      SIZE oRow:oBrw:Age:nWidth / 2,12 PIXEL OF oDlg UPDATE ;
      PICTURE oRow:oBrw:Age:cEditPicture RIGHT ;
      VALID ( oDlg:AEvalWhen(), .t. )

   @  55, 10 SAY 'Salary' SIZE 40,10 PIXEL OF oDlg RIGHT
   @  55, 60 GET oRow:Salary ;
      SIZE oRow:oBrw:Salary:nWidth / 2,12 PIXEL OF oDlg UPDATE ;
      PICTURE oRow:oBrw:Salary:cEditPicture RIGHT ;
      VALID ( oDlg:AEvalWhen(), .t. )

   @  80, 10 BUTTON 'Undo'  SIZE 30,12 PIXEL OF oDlg ;
      WHEN oRow:Modified() ACTION ( oRow:Undo(), oDlg:Update() )

   @  80, 78 BUTTON 'Save'  SIZE 30,12 PIXEL OF oDlg ;
      WHEN oRow:Modified() ACTION ( oRow:Save(), oDlg:aEvalWhen() )

   @  80,110 BUTTON 'Close' SIZE 30,12 PIXEL OF oDlg ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED NOMODAL

return nil

// ----  DATA OPEN AND CLOSE FUNCTIONS ---- //

static function OpenData

   local uData, nDataType

   nDataType   := Max( 1, Alert( 'DataType', { 'DBFCDX', 'TDataBase', 'ADO' } ) )

   if nDataType > 2
      uData := OpenADO()
   else
      USE CUSTOMER NEW ALIAS CUST SHARED VIA 'DBFCDX'
      DATABASE uData

      if nDataType == 1
         uData := 'CUST'
      endif

   endif

return uData

static function OpenADO

   local oCn, oRs, cPath := CURDRIVE() + ':' + Chr(92) + CURDIR()

   oCn      := TOleAuto():New( 'ADODB.Connection' )
   WITH OBJECT oCn
      :ConnectionString := 'Driver={Microsoft dBASE Driver (*.dbf)};DriverID=277;Dbq=' + cPath
      :CursorLocation   := adUseClient
      :Open()
   END

   oRs      := TOleAuto():New( 'ADODB.RecordSet' )
   WITH OBJECT oRs
      :ActiveConnection := oCn
      :Source           := 'CUSTOMER'
      :LockType         := adLockOptimistic
      :Open()
   END

return oRs

static function CloseData( uData )

   local oCn

   if ValType( uData ) == 'O'
      if Upper( uData:ClassName ) = 'TOLEAUTO'
         oCn   := uData:ActiveConnection
         uData:Close()
         oCn:Close()
      else
         uData:Close()
      endif
   else
      CLOSE DATA
   endif

return nil
 