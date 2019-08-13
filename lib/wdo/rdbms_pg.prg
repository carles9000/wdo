/*	---------------------------------------------------------
	File.......: rdbms_PG.prg
	Description: Conexión a Bases de Datos PG 
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */
#include "hbdyn.ch"

#define VERSION_RDBMS_PG			'0.1a'
#define HB_VERSION_BITWIDTH  				17
#define NULL  								0  


	
CLASS RDBMS_PG FROM RDBMS

	DATA pLib
	DATA hPG
	DATA hConnection
	DATA lConnect								INIT .F.
	DATA cError 								INIT ''
	DATA aFields 								INIT {}
	DATA aLog 									INIT {}
	DATA hQuery
	
	METHOD New() 								CONSTRUCTOR
		
	METHOD Query( cSql )	
	METHOD Count( hRes )						INLINE ::PG_num_rows( hRes )
	METHOD FCount( hRes )						INLINE ::PG_num_fields( hRes )
	METHOD LoadStruct()					
	METHOD DbStruct()							INLINE ::aFields
	METHOD Fetch( hRes )	
	METHOD Fetch_Assoc( hRes )		
	METHOD FetchAll( hRes, lAssociative )
	METHOD Free_Result( hRes )				INLINE ::PG_free_result( hRes )	
	
	
	//	Wrappers (Antonio Linares)
	
	METHOD PG_init()
	METHOD PG_get_server_info()
	METHOD PG_real_connect( cServer, cUserName, cPassword, cDataBaseName, nPort )
	METHOD PG_error()
	METHOD PG_query( cQuery )
	METHOD PG_store_result()
	METHOD PG_num_rows( hRes )
	METHOD PG_num_fields( hRes ) 
	METHOD PG_fetch_field( hRes )
	METHOD PG_fetch_row( hRes )
	METHOD PG_free_result( hRes )	
	
	METHOD Version()							INLINE VERSION_RDBMS_PG

		
	
	DESTRUCTOR  Exit()
					

ENDCLASS

METHOD New( cServer, cUsername, cPassword, cDatabase, nPort ) CLASS RDBMS_PG

	hb_default( @cServer, '' )
	hb_default( @cUserName, '' )
	hb_default( @cPassword, '' )
	hb_default( @cDatabase, '' )
	hb_default( @nPort, 5432 )
	
	::cServer		:= cServer
	::cUserName	:= cUserName
	::cPassword 	:= cPassword
	::cDatabase 	:= cDatabase
	::nPort 		:= nPort	
	
	//	Cargamos lib PG
	
		::pLib 	:= hb_LibLoad( hb_SysPG() )	

		If ValType( ::pLib ) <> "P" 
			::cError := "Error (PG library not found)" 
			RETU Self
		ENDIF
	
	
	//	Server Info
	
		// "PG version: " + ::PG_get_server_info()  	

		
	//	Conexion a Base de datos	
		
		::hConnection := ::PG_real_connect( ::cServer, ::cUserName, ::cPassword, ::cDatabase, ::nPort )
		
		IF  ::hConnection == 0
			::cError := "Connection = (Failed connection) " + ::PG_error()
			RETU Self
		ENDIF
		
		::lConnect := .T.
		
RETU SELF

METHOD Query( cQuery ) CLASS RDBMS_PG

	LOCAL nRetVal
	LOCAL hRes			:= 0

    IF ::hConnection == 0
		RETU NIL
	ENDIF	
	
    ::hQuery := ::PG_query( cQuery )
	nRetVal:= hb_DynCall( { "PQntuples", ::pLib  }, ::hQuery ) 
	
	IF nRetVal == 0 
		hRes = ::PG_store_result(::hQuery)

		IF hRes != 0					//	Si Update/Delete hRes == 0
			::LoadStruct( hRes )
		ENDIF

	ELSE
		::cError := 'Error: ' + ::PG_error()
	ENDIF
   
RETU hRes

METHOD LoadStruct( hRes ) CLASS RDBMS_PG

	LOCAL n, hField	
     
    ::aFields = Array( ::FCount( hRes ) )
	
    FOR n = 1 to Len( ::aFields )
	
        hField := ::PG_fetch_field( hRes )
		
        if hField != 0
		
			::aFields[ n ] = Array( 4 )
            ::aFields[ n ][ 1 ] = PtrToStr( hField, 0 )
			
            do case
               case AScan( { 253, 254, 12 }, PtrToUI( hField, hb_SysMyTypePos() ) ) != 0
                    ::aFields[ n ][ 2 ] = "C"

               case AScan( { 1, 3, 4, 5, 8, 9, 246 }, PtrToUI( hField, hb_SysMyTypePos() ) ) != 0
                    ::aFields[ n ][ 2 ] = "N"

               case AScan( { 10 }, PtrToUI( hField, hb_SysMyTypePos() ) ) != 0
                    ::aFields[ n ][ 2 ] = "D"

               case AScan( { 250, 252 }, PtrToUI( hField, hb_SysMyTypePos() ) ) != 0
                    ::aFields[ n ][ 2 ] = "M"
            endcase 
			
        endif   
		 
	NEXT 

	  
RETU NIL

METHOD Fetch( hRes ) CLASS RDBMS_PG

	LOCAL hRow
	LOCAL aReg
	LOCAL m

	if ( hRow := ::PG_fetch_row( hRes ) ) != 0
	
		aReg := array( ::FCount( hRes ) )
	
		for m = 1 to ::FCount( hRes )
		   aReg[ m ] := PtrToStr( hRow, m - 1 )
		next
		
	endif
	
	//::PG_free_result( hRes )

RETU aReg


METHOD Fetch_Assoc( hRes ) CLASS RDBMS_PG

	LOCAL hRow
	LOCAL hReg		:= {=>}
	LOCAL m

	if ( hRow := ::PG_fetch_row( hRes ) ) != 0
	
		for m = 1 to ::FCount( hRes )
		   hReg[ ::aFields[m][1] ] := PtrToStr( hRow, m - 1 )
		next
		
	endif
	
	//::PG_free_result( hRes )

RETU hReg

METHOD FetchAll( hRes, lAssociative ) CLASS RDBMS_PG

	LOCAL oRs
	LOCAL aData := {}
	
	__defaultNIL( @lAssociative, .f. )
	
	IF lAssociative 
	
		WHILE ( !empty( oRs := ::Fetch_Assoc( hRes ) ) )
		
			Aadd( aData, oRs )
		
		END
		
	ELSE
	
		WHILE ( !empty( oRs := ::Fetch( hRes ) ) )
		
			Aadd( aData, oRs )
			
		END
		
	ENDIF
	
	
RETU aData


//	Wrappers...

METHOD PG_num_rows( hRes ) CLASS RDBMS_PG	
return hb_DynCall( { "PQnfields", ::pLib }, hRes )


METHOD PG_Init() CLASS RDBMS_PG
RETU 0 
				   
METHOD PG_get_server_info() CLASS RDBMS_PG	
RETU hb_DynCall( { ""PQserverVersion", ", ::pLib }, ::hPG )			   

				   
METHOD PG_real_connect( cServer, cUserName, cPassword, cDataBaseName, nPort ) CLASS RDBMS_PG	
    if nPort == nil
       nPort = 5432
     endif   
     cConn:="host="+cServer+' port='+str(nPort,4,0)+' user='+cUserName+' password='+cPassword+' dbname='+cDataBaseName 
RETU hb_DynCall( { "PQconnectdb", ::pLib}, cConn) 
				   

METHOD PG_error() CLASS RDBMS_PG	
RETU hb_DynCall( { "PG_error", ::pLib }, ::hPG )

				   

METHOD PG_query( cQuery ) CLASS RDBMS_PG	
local aRet:={}, _tuples, _rows, _row
hRes:=hb_DynCall( { "PQsendQuery", ::pLib  }, ::hConnection, cQuery ) 
hQuery:=hb_DynCall( { "PQgetResult", ::pLib  }, ::hConnection ) 
return hQuery 
				   


METHOD PG_store_result() CLASS RDBMS_PG	
local aRet:={}, _tuples, _rows, _row
nFields:=::PG_num_fields( ::hQuery)
for _tuples:=0 to nTuples 
	_row:={} 
	for _rows:=0 to nFields
		_tmp:=hb_DynCall( { "PQgetvalue", pLib, 0x0000101  }, hQuery, _tuples, _rows)
		aadd(_row, _tmp)
	next
	aadd(aRet, _row)
next
RETU aRet  


METHOD PG_num_fields( hRes ) CLASS RDBMS_PG	
RETU hb_DynCall( { "PQnfields", ::pLib}, ::hQuery )				   
				   
				   
METHOD PG_fetch_field( hRes ) CLASS RDBMS_PG	
RETU 0 
				   

	   
METHOD PG_fetch_row( hRes ) CLASS RDBMS_PG	
RETU 0 

METHOD PG_free_result( hRes ) CLASS RDBMS_PG	
RETU hb_DynCall( { "PQclear", ::pLib ) }, ::hQuery )

				   
				   
METHOD Exit() CLASS RDBMS_PG

    IF ValType( ::pLib ) == "P"
		//? "PG library properly freed: ", HB_LibFree( ::pLib )
    ENDIF 
	
RETU NIL


//	------------------------------------------------------------
function hb_SysLong()
return If( hb_OSIS64BIT(), HB_DYN_CTYPE_LLONG_UNSIGNED, HB_DYN_CTYPE_LONG_UNSIGNED )

//----------------------------------------------------------------//

function hb_SysCallConv()
return If( ! "Windows" $ OS(), HB_DYN_CALLCONV_CDECL, HB_DYN_CALLCONV_STDCALL )

//----------------------------------------------------------------//


function hb_SysMyTypePos()
return If( hb_version( HB_VERSION_BITWIDTH ) == 64,;
       If( "Windows" $ OS(), 26, 28 ), 19 )   

//----------------------------------------------------------------//


function hb_SysPG()
   local cLibName
   if ! "Windows" $ OS()
      if "Darwin" $ OS()
         cLibName = "/usr/local/Cellar/PG/8.0.16/lib/libPGclient.dylib"
      else   
         cLibName = If( hb_version( HB_VERSION_BITWIDTH ) == 64,;
                        "/usr/lib/x86_64-linux-gnu/libPGclient.so",; // libPGclient.so.20 for mariaDB
                        "/usr/lib/x86-linux-gnu/libPGclient.so" )
      endif                  
   else
		IF hb_version( HB_VERSION_BITWIDTH ) == 64
			IF !Empty( HB_GetEnv( 'WDO_PATH_PG' ) )
				cLibName = HB_GetEnv( 'WDO_PATH_PG' ) + 'libPG64.dll'
			ELSE
				cLibName = "c:/Apache24/htdocs/libPG64.dll"
			ENDIF
		ELSE
			IF !Empty( HB_GetEnv( 'WDO_PATH_PG' ) )
				cLibName = HB_GetEnv( 'WDO_PATH_PG' ) + 'libPG.dll'
			ELSE
				cLibName = "c:/Apache24/htdocs/libPG.dll"
			ENDIF		
		ENDIF
   endif
   cLibName:="/usr/lib/x86_64-linux-gnu/libpq.so"
return cLibName 
