/*	---------------------------------------------------------
	File.......: rdbms_mysql.prg
	Description: Conexión a Bases de Datos MySql 
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */
#include "hbdyn.ch"

#define HB_VERSION_BITWIDTH  17
#define NULL  0  

	
CLASS RDBMS_MySql FROM RDBMS

	DATA pLib
	DATA hMySql
	DATA hConnection
	DATA aFields 							INIT {}

	METHOD New() 							CONSTRUCTOR
	
	METHOD Query( cSql )
	METHOD Count( hRes )					INLINE ::mysql_num_rows( hRes )
	METHOD FCount( hRes )					INLINE ::mysql_num_fields( hRes )
	METHOD DbStruct()						
	METHOD Fetch( hRes )
	METHOD Fetch_Assoc( hRes )	
	METHOD Free_Result( hRes )			INLINE ::mysql_free_result( hRes )	
	
	
	//	Wrappers (Antonio Linares)
	
	METHOD mysql_init()
	METHOD mysql_get_server_info()
	METHOD mysql_real_connect( cServer, cUserName, cPassword, cDataBaseName, nPort )
	METHOD mysql_error()
	METHOD mysql_query( cQuery )
	METHOD mysql_store_result()
	METHOD mysql_num_rows( hRes )
	METHOD mysql_num_fields( hRes ) 
	METHOD mysql_fetch_field( hRes )
	METHOD mysql_fetch_row( hRes )
	METHOD mysql_free_result( hRes )	

		
	
	DESTRUCTOR  Exit()
					

ENDCLASS

METHOD New( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort ) CLASS RDBMS_MySql

	hb_default( @cServer, '' )
	hb_default( @cUserName, '' )
	hb_default( @cPassword, '' )
	hb_default( @cDatabase, '' )
	hb_default( @nPort, 3306 )
	
	::cServer		:= cServer
	::cUserName	:= cUserName
	::cPassword 	:= cPassword
	::cDatabase 	:= cDatabase
	::nPort 		:= nPort	

	? hb_SysMySQL()
	
	::pLib 	:= hb_LibLoad( hb_SysMySQL() )
	


    If ValType( ::pLib ) == "P" 
		? "(MySQL library properly loaded)"
	ELSE
		? "Error (MySQL library not found)" 
		RETU NIL
	ENDIF


    ::hMySQL = ::mysql_init()
	
	IF ::hMySQL != 0 
		? "hMySQL = " + Str( ::hMySQL ) + " (MySQL library properly initalized)"
	ELSE
		? "hMySQL = " + Str( ::hMySQL ) + " (MySQL library failed to initialize)"
		RETU NIL
	ENDIF
	
    ? "MySQL version: " + ::mysql_get_server_info()  	

	
      ? "Connection = "
      ?? ::hConnection := ::mysql_real_connect( "localhost", "harbour", "password", "dbHarbour", 3306 )
      ?? If( ::hConnection != ::hMySQL, " (Failed connection)", " (Successfull connection)" )
    ?  If( ::hConnection != ::hMySQL, "Error: " + ::mysql_error(), "" )	


RETU SELF

METHOD Query( cQuery ) CLASS RDBMS_MySql

	LOCAL nRetVal
	LOCAL hRes			:= 0

    IF ::hConnection == 0
		RETU NIL
	ENDIF	
	
    nRetVal := ::mysql_query( cQuery )
	
      ? "MySQL query " + If( nRetVal == 0, "succeeded", "failed" )
      if nRetVal != 0
         ? "error: " + Str( nRetVal )
      endif
	  
	IF nRetVal == 0 
		hRes = ::mysql_store_result()
		::DbStruct( hRes )
	ENDIF
   
RETU hRes

METHOD DbStruct( hRes ) CLASS RDBMS_MySql

	LOCAL n, hField	
     
    ::aFields = Array( ::FCount( hRes ) )
	
    FOR n = 1 to Len( ::aFields )
	
        hField := ::mysql_fetch_field( hRes )
		
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

METHOD Fetch( hRes ) CLASS RDBMS_MySql

	LOCAL hRow
	LOCAL aReg
	LOCAL m

	if ( hRow := ::mysql_fetch_row( hRes ) ) != 0
	
		aReg := array( ::FCount( hRes ) )
	
		for m = 1 to ::FCount( hRes )
		   aReg[ m ] := PtrToStr( hRow, m - 1 )
		next
		
	endif
	
	::mysql_free_result( hRes )

RETU aReg


METHOD Fetch_Assoc( hRes ) CLASS RDBMS_MySql

	LOCAL hRow
	LOCAL hReg		:= {=>}
	LOCAL m

	if ( hRow := ::mysql_fetch_row( hRes ) ) != 0
	
		for m = 1 to ::FCount( hRes )
		   hReg[ ::aFields[m][1] ] := PtrToStr( hRow, m - 1 )
		next
		
	endif
	
	::mysql_free_result( hRes )

RETU hReg

METHOD mysql_num_rows( hRes ) CLASS RDBMS_MySql	

return hb_DynCall( { "mysql_num_rows", ::pLib, hb_bitOr( hb_SysLong(),;
                  hb_SysCallConv() ), hb_SysLong() }, hRes )




METHOD mysql_Init() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_init", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ) }, NULL )
				   
METHOD mysql_get_server_info() CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_get_server_info", ::pLib, hb_bitOr( HB_DYN_CTYPE_CHAR_PTR,;
                   hb_SysCallConv() ), hb_SysLong() }, ::hMySql )			   


				   
METHOD mysql_real_connect( cServer, cUserName, cPassword, cDataBaseName, nPort ) CLASS RDBMS_MySql	

    if nPort == nil
       nPort = 3306
    endif   

RETU hb_DynCall( { "mysql_real_connect", ::pLib, hb_bitOr( hb_SysLong(),;
                     hb_SysCallConv() ), hb_SysLong(),;
                     HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR,;
                     HB_DYN_CTYPE_LONG, HB_DYN_CTYPE_LONG, HB_DYN_CTYPE_LONG },;
                     ::hMySQL, cServer, cUserName, cPassword, cDataBaseName, nPort, 0, 0 )
                     				   
				   

METHOD mysql_error() CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_error", ::pLib, hb_bitOr( HB_DYN_CTYPE_CHAR_PTR,;
                   hb_SysCallConv() ), hb_SysLong() }, ::hMySql )

				   

METHOD mysql_query( cQuery ) CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_query", ::pLib, hb_bitOr( HB_DYN_CTYPE_INT,;
                   hb_SysCallConv() ), hb_SysLong(), HB_DYN_CTYPE_CHAR_PTR },;
                   ::hConnection, cQuery )				   
				   


METHOD mysql_store_result() CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_store_result", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ), hb_SysLong() }, ::hMySQL )



METHOD mysql_num_fields( hRes ) CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_num_fields", ::pLib, hb_bitOr( HB_DYN_CTYPE_LONG_UNSIGNED,;
                   hb_SysCallConv() ), hb_SysLong() }, hRes )				   
				   
				   
METHOD mysql_fetch_field( hRes ) CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_fetch_field", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ), hb_SysLong() }, hRes )	
				   

	   
METHOD mysql_fetch_row( hRes ) CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_fetch_row", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ), hb_SysLong() }, hRes )	  



METHOD mysql_free_result( hRes ) CLASS RDBMS_MySql	

RETU hb_DynCall( { "mysql_free_result", ::pLib,;
                   hb_SysCallConv(), hb_SysLong() }, hRes )

				   
				   
METHOD Exit() CLASS RDBMS_MySql

    IF ValType( ::pLib ) == "P"
      ? "MySQL library properly freed: ", HB_LibFree( ::pLib )
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




function hb_SysMySQL()

   local cLibName

   if ! "Windows" $ OS()
      if "Darwin" $ OS()
         cLibName = "/usr/local/Cellar/mysql/8.0.16/lib/libmysqlclient.dylib"
      else   
         cLibName = If( hb_version( HB_VERSION_BITWIDTH ) == 64,;
                        "/usr/lib/x86_64-linux-gnu/libmysqlclient.so",; // libmysqlclient.so.20 for mariaDB
                        "/usr/lib/x86-linux-gnu/libmysqlclient.so" )
      endif                  
   else
      cLibName = If( hb_version( HB_VERSION_BITWIDTH ) == 64,;
                     "c:/Apache24/htdocs/libmysql64.dll",;
                     "c:/xampp/htdocs/libmysql.dll" )
   endif

return cLibName 
