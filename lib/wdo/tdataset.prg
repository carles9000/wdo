//	-----------------------------------------------------------	//

CLASS TDataset 

	DATA oDb 
	DATA cTable 
	DATA cIndex 
	DATA cFocus
	DATA cPath 							INIT ''
	DATA aFields 						INIT {=>}
	DATA hRow 							INIT {=>}
	
	DATA hCfg							INIT { 'wdo' => 'DBF' }


	METHOD  New() 						CONSTRUCTOR
	METHOD  Open()
	
	METHOD  ConfigDb( hCfg )
	
	METHOD  AddField( cField ) 			INLINE ::aFields[ cField ] := {}
   
	METHOD  RecCount()
	METHOD  GetId( cId )
	METHOD  Row()						INLINE ::hRow
	
	METHOD  Load()
	METHOD  Blank()
	METHOD  LoadPage( nRecs, nRecnoStart )
   
ENDCLASS

METHOD New() CLASS TDataset

	//::hCfg[ 'wdo' ] := 'DBF'

RETU SELF

METHOD Open( lExclusive ) CLASS TDataset


	__defaultNIL( @lExclusive, .F. )

	
	IF ::hCfg[ 'wdo' ] == 'DBF'
	
		IF ValType( ::oDb ) == 'O' .AND. ::oDb:lOpen
			::hRow := ::Load()	
			RETU NIL
		ENDIF

		::oDb := WDO():Dbf( ::cTable, ::cIndex , .F. )
			::oDb:lExclusive := lExclusive
			
		IF !empty( ::cPath )
			::oDb:cPath := ::cPath
		ENDIF
		
		::oDb:Open()

		::hRow := ::Load()	
	
	ELSE
	
		::oDb := WDO():Rdbms( ::hCfg[ 'wdo' ],;
								::hCfg[ 'server' ],;
								::hCfg[ 'user'] ,;
								::hCfg[ 'password' ],;
								::hCfg[ 'database' ],;
								::hCfg[ 'port' ] )
								

								
	
	ENDIF

RETU NIL

METHOD ConfigDb( hCfg ) CLASS TDataset

	::hCfg := hCfg 

RETU NIL

METHOD RecCount() CLASS TDataset

	LOCAL cSql, oRs, hRes, o
	LOCAL nTotal 

	IF ::hCfg[ 'wdo' ] == 'DBF'
	
		::nTotal := ::oDb:Count()
		
	ELSE
	
		cSql 	:= 'SELECT count(*) as total FROM ' + ::cTable 
		
		hRes 	:= ::oDb:Query( cSql )
		oRs  	:= ::oDb:Fetch_Assoc( hRes ) 
		
		nTotal	:= oRs[ 'total' ]	
		
	ENDIF
	
RETU nTotal


METHOD getId( cId ) CLASS TDataset

	LOCAL hReg 
	LOCAL lFound := .F.
	LOCAL cSql, hRes

	IF ::hCfg[ 'wdo' ] == 'DBF'	
		
		::oDb:Focus( ::cFocus )
		
		IF ( lFound := ::oDb:Seek( cId ) )
			::hRow := ::Load()
		ELSE
			::hRow := ::Blank()
		ENDIF	

	ELSE

		cSql 	:= 'SELECT * FROM ' + ::cTable + ' WHERE ' + ::cFocus + ' = ' + valtochar( cId )

		hRes 	:= ::oDb:Query( cSql )
		
		lFound	:= IF( ::oDb:Count( hRes ) > 0 , .T., .F. )
	
		IF lFound 
			::hRow 	:= ::oDb:Fetch_Assoc( hRes )
		ELSE
			::hRow	:= ''		
		ENDIF		
		
	ENDIF
	
RETU lFound

METHOD Load( lAssoc ) CLASS TDataset

	LOCAL nI, cField 
	LOCAL uReg 
	
	__defaultNIL( @lAssoc, .T. )
	
	IF lAssoc 		
		uReg := {=>}			
	ELSE			
		uReg := {}		
	ENDIF	

	FOR nI := 1 TO Len( ::aFields )
		
		cField := HB_HKeyAt( ::aFields, nI ) 	

		IF lAssoc 

			uReg[ cField ] :=  ::oDb:FieldGet( cField )
			
		ELSE

			Aadd( uReg, ::oDb:FieldGet( cField ) )
		
		ENDIF
		
	NEXT

RETU uReg

METHOD Blank( lAssoc ) CLASS TDataset

	LOCAL nI, cField 
	LOCAL uReg 
	
	__defaultNIL( @lAssoc, .T. )	
	
	::oDb:Last()
	::oDb:next()		//	EOF() + 1 

	uReg := ::Load( lAssoc )

RETU uReg


METHOD LoadPage( nRecs, nRecnoStart, lAssoc ) CLASS TDataset

	LOCAL nI		:= 0
	LOCAL aRows	:= {}
	LOCAL cSql, hRes

	__defaultNIL( @nRecs, 10 )
	__defaultNIL( @nRecnoStart, 0 )
	__defaultNIL( @lAssoc, .F. )	
	
	IF ::hCfg[ 'wdo' ] == 'DBF'	
	
		IF nRecnoStart > 0 
			
			::oDb:GoTo( nRecnoStart )
		
		ENDIF
		
		WHILE !::oDb:Eof() .AND. nI < nRecs 
		
			Aadd( aRows, ::Load( lAssoc ) )
			
			::oDb:Next()
			
			nI++
		
		END	

	ELSE
	
		cSql	:= 'Select * from ' + ::cTable + ' limit ' + str(nRecnoStart) + ', ' + str(nRecs)
	
		hRes	:= ::oDb:Query( cSql )		
		aRows	:= ::oDb:FetchAll( hRes )
	
	ENDIF

RETU aRows