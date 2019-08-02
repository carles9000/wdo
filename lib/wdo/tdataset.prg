//	-----------------------------------------------------------	//

CLASS TDataset 

	DATA oDb 
	DATA cTable 
	DATA cIndex 
	DATA cFocus
	DATA cPath 							INIT ''
	DATA aFields 						INIT {=>}
	DATA hRow 							INIT {=>}


	METHOD  New() CONSTRUCTOR
	METHOD  Open()
	METHOD  AddField( cField ) 		INLINE ::aFields[ cField ] := {}
   
	METHOD  GetId( cId )
	METHOD  Row()						INLINE ::hRow
	
	METHOD  Load()
	METHOD  Blank()
   
ENDCLASS

METHOD New() CLASS TDataset


RETU SELF

METHOD Open() CLASS TDataset

	::oDb := WDO():Dbf( ::cTable, ::cIndex , .F. )		
		
	IF !empty( ::cPath )
		::oDb:cPath := ::cPath
	ENDIF

	
	::oDb:Open()

	::hRow := ::Load()

RETU NIL

METHOD getId( cId ) CLASS TDataset

	LOCAL hReg 
	LOCAL lFound := .F.

	::oDb:Focus( ::cFocus )
	
	IF ( lFound := ::oDb:Seek( cId ) )
		::hRow := ::Load()
	ELSE
		::hRow := ::Blank()
	ENDIF	

RETU lFound

METHOD Load() CLASS TDataset

	LOCAL nI, cField 
	LOCAL hReg := {=>}

	FOR nI := 1 TO Len( ::aFields )
		
		cField := HB_HKeyAt( ::aFields, nI ) 			
		
		hReg[ cField ] :=  ::oDb:FieldGet( cField )
		
	NEXT

RETU hReg

METHOD Blank() CLASS TDataset

	LOCAL nI, cField 
	LOCAL hReg := {=>}
	
	::oDb:Last()
	::oDb:next()		//	EOF() + 1 

	FOR nI := 1 TO Len( ::aFields )
		
		cField := HB_HKeyAt( ::aFields, nI ) 			
		
		hReg[ cField ] :=  ::oDb:FieldGet( cField )
		
	NEXT

RETU hReg