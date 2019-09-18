/*	---------------------------------------------------------
	File.......: ado.prg
	Description: Conexión a Bases de Datos via ADO
	Author.....: Carles Aubia Floresvi
	Date:......: 17/09/2019
	--------------------------------------------------------- */

#define VERSION_RDBMS_ADO						'ADO 0.1a'

#xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->

	
CLASS RDBMS_ADO FROM RDBMS

	DATA oCn 	
	DATA lInit									INIT .F.
	DATA lConnect								INIT .F.
	DATA adUseClient 							INIT 3
	DATA adOpenStatic 							INIT 3
	DATA adLockOptimistic						INIT 3
	DATA lShowError							INIT .F.
	DATA cError									INIT ''

	
	METHOD New() 								CONSTRUCTOR
	METHOD Open() 
	
	METHOD Query( cSql ) 																
	METHOD Close()								
	
	METHOD Version()							INLINE VERSION_RDBMS_ADO		
					
	
	DESTRUCTOR  Exit()	

ENDCLASS

METHOD New( cServer, cUsername, cPassword, cDatabase, lAutoOpen ) CLASS RDBMS_ADO

	LOCAL oCn, cStr
    LOCAL bErrorHandler 	:= { |oError | ADOErrorHandler(oError) }
	LOCAL bLastHandler 	:= ErrorBlock(bErrorHandler)
	LOCAL oError	

	__defaultNIL( @lAutoOpen, .F. )
	
	IF Valtype( cServer ) == 'H' 
	
		::cServer		:= HB_HGetDef( cServer, 'server' ) 
		::cUserName	:= HB_HGetDef( cServer, 'user' ) 
		::cPassword 	:= HB_HGetDef( cServer, 'pwd' ) 
		::cDatabase 	:= HB_HGetDef( cServer, 'db' ) 
		
		IF Valtype( cUserName ) == 'L'
			lAutoOpen := cUserName
		ENDIF	
	
	ELSE 

		hb_default( @cServer, '' )
		hb_default( @cUserName, '' )
		hb_default( @cPassword, '' )
		hb_default( @cDatabase, '' )
		hb_default( @lAutoOpen, .T. )
	
		::cServer		:= cServer
		::cUserName		:= cUserName
		::cPassword 	:= cPassword
		::cDatabase 	:= cDatabase
		
	ENDIF
	
	BEGIN SEQUENCE		
	
		::oCn 		:= win_oleCreateObject( "ADODB.Connection" )
		::lInit 	:= .T.
		
	RECOVER USING oError	
	
		::cError := 'Error ADODB'
		
		IF ::lShowError
			? ::cError 
		ENDIF
		
		RETU NIL
		
	END SEQUENCE		
	
	ErrorBlock(bLastHandler) // Restore handler 
	
	IF lAutoOpen
		::Open()
	ENDIF	
		
RETU SELF


METHOD Open() CLASS RDBMS_ADO

    LOCAL bErrorHandler 	:= { |oError | ADOErrorHandler(oError) }
	LOCAL bLastHandler 	:= ErrorBlock(bErrorHandler)
	LOCAL oError 
	LOCAL cStr  			:= 	"Provider=SQLOLEDB;" + ;
								"Data Source="     + ::cServer 		+ ";" + ;
								"Initial Catalog=" + ::cDatabase   	+ ";" + ;
								"User ID="         + ::cUserName   	+ ";" + ;
								"Password="        + ::cPassword   	+ ";"
				
	IF ::lConnect 
		RETU .T.
	ENDIF
						

	BEGIN SEQUENCE		
	
		WITH OBJECT ::oCn
			:ConnectionString := cStr
			:CursorLocation   := ::adUseClient
			:Open()
		END	
		
	RECOVER USING oError	

		::cError := oError:description

		IF ::lShowError
			? ::cError 
		ENDIF		
		
		RETU .F.
		
	END SEQUENCE		
	
	ErrorBlock(bLastHandler) // Restore handler    	

	::lConnect := .T.	
					
RETU .T.

STATIC FUNCTION ADOErrorHandler( oError )

	BREAK oError
	
RETU NIL


METHOD Query( cSql, nMaxRecords ) CLASS RDBMS_ADO

	LOCAL oRs


	oRs   := TOleAuto():new( "ADODB.RecordSet" )

	WITH OBJECT oRs
	
		:ActiveConnection    := ::oCn      
		:Source              := cSql
		:LockType            := ::adLockOptimistic
		:CursorLocation      := ::adUseClient            // adUseClient
		:CacheSize           := 100
		:CursorType          := ::adOpenStatic //nCursorType  // adOpenDynamic

		if HB_IsNumeric( nMaxRecords )
			:MaxRecords       := nMaxRecords
		endif
    

      TRY

		:Open()	 		 

      CATCH

      END
      
   END


return RecordSet():New( oRs	 )

METHOD Close() CLASS RDBMS_ADO

    IF ValType( ::oCn ) == "O"

		IF ::oCn:State > 0
			::oCn:Close()
		ENDIF
		
		::oCn := NIL
		::lConnect := .F.

	ENDIF

RETU NIL

METHOD Exit() CLASS RDBMS_ADO

	//? "ADO free Connection"
	::Close()
	
RETU NIL


//	---------------------------------------------------------------	//

CLASS RecordSet

	DATA oRs 	
	DATA hRow								INIT 	{=>}
	DATA nFields							INIT 0
	DATA aFields							INIT {}
	DATA lAssociative 						INIT .T.
	
	METHOD New( oRs ) 								CONSTRUCTOR
							
	METHOD Count()							INLINE ::oRs:RecordCount()										
	METHOD FCount( n )						INLINE ::nFields								
	METHOD Next( lAssociative )			INLINE ( ::oRs:MoveNext(), !::oRs:Eof() )	
	METHOD FieldName( n )					INLINE ::oRs:Fields( n - 1 ):Name 	//HB_HKeyAt( ::hRow, n )								
	METHOD FieldGet( n )					INLINE ::oRs:Fields( n - 1 ):Value	//HB_HValueAt( ::hRow, n )								
	METHOD Eof()							INLINE ::oRs:Eof							

	METHOD Row()							
	
	METHOD FetchAll( lAssociative )
	METHOD View( aData )
	METHOD Close()							INLINE ( ::oRs:Close(), ::oRs := NIL )
	
	DESTRUCTOR  Exit()

ENDCLASS

METHOD New( oRs ) CLASS RecordSet

	LOCAL nI, oField

	::oRs := oRs
	
	::nFields := ::oRs:Fields:Count()	
	
	FOR nI := 1 TO ::nFields
	
		oField := ::oRs:Fields( nI - 1 )
		Aadd( ::aFields, oField:Name )			
		
	NEXT		

RETU SELF

METHOD Row( lAssociative ) CLASS RecordSet

	LOCAL nI, oField
	
	__defaultNIL( @lAssociative, ::lAssociative )	

	IF lAssociative 
		::hRow := {=>}			
	ELSE
		::hRow := {}
	ENDIF


	
	FOR nI := 1 TO ::nFields
	
		oField := ::oRs:Fields( nI - 1 )
	
		IF lAssociative 

			::hRow[ oField:Name ] :=  oField:Value
			
		ELSE
		
			Aadd( ::hRow, oField:Value )
		
		ENDIF
		
	NEXT	

RETU ::hRow

METHOD FetchAll( lAssociative ) CLASS RecordSet

	LOCAL aData := {}
	local n := 0
	
	__defaultNIL( @lAssociative, ::lAssociative )	

	WHILE ! ::oRs:Eof

		Aadd( aData, ::Row( lAssociative ) )
		
		::Next()		
	
	END	
	
RETU aData


//	Para testear si carga datos...

METHOD View( aData ) CLASS RecordSet

	LOCAL nFields	:= len( aData )
	LOCAL cHtml 	:= ''
	LOCAL n, j, nLen
	LOCAL lAssociative
	
	IF nFields == 0
		? '<h3>No Data</h3>'
		RETU NIL
	ENDIF
	
	lAssociative := HB_IsHash( aData[1] )

	cHtml := '<h3>View table. Total ' + ltrim(str(nFields)) +'</h3>'	
	
	cHtml += '<style>'
	cHtml += '#mytable tr:hover {background-color: #ddd;}'
	cHtml += '#mytable tr:nth-child(even){background-color: #e0e6ff;}'
	cHtml += '#mytable { font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;border-collapse: collapse; width: 100%; }'
	cHtml += '#mytable thead { background-color: #425ecf;color: white;}'
	cHtml += '</style>'
	cHtml += '<table id="mytable" border="1" cellpadding="3" >'
	
	cHtml += '<thead><tr>'

	FOR n := 1 TO ::nFields
	
		cHtml += '<td>' + ::aFields[ n ] + '</td>'
		
	NEXT
	
	cHtml += '</tr></thead>'
	
	nLen := len( aData )
	
	cHtml += '<tbody>'
	
	? cHtml 
	
	FOR n := 1 to nLen 
	
		cHtml := '<tr>'
		
		IF lAssociative 
		
			FOR j := 1 to ::nFields		
				cHtml += '<td>' + valtochar( HB_HValueAt( aData[n] , j )) + '</td>'	
			NEXT
			
		ELSE
		
			FOR j := 1 to ::nFields		
				cHtml += '<td>' + valtochar( aData[n,j] ) + '</td>'					
			NEXT				
			
		ENDIF
		
		cHtml += '</tr>'
		
		?? cHtml
	
	NEXT
	
	?? '</tbody></table><hr>'

RETU NIL


METHOD Exit() CLASS RecordSet

    IF ValType( ::oRs ) == "O"
		//? "ADO free recordset"
		::oRs:Close()
    ENDIF 
	
RETU NIL