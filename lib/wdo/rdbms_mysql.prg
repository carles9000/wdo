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

	METHOD New() 						CONSTRUCTOR
	
	METHOD Connect() 
	
	METHOD MySql_Init()
	METHOD MySql_Close()
	METHOD MySql_Real_Connect()
	METHOD MySql_Query( cQuery )
	METHOD MySql_Use_Result()
	METHOD MySql_Store_Result()
	METHOD MySql_Free_Result( hMyRes )
	METHOD MySql_Fetch_Row( hMyRes )
	METHOD MySql_Num_Rows( hMyRes )
	METHOD MySql_Num_Fields( hMyRes )
	METHOD MySql_Fetch_Field( hMyRes )
	METHOD MySql_Get_Server_Info()
	METHOD MySql_Error()
					

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

	AP_RPUTS( 'RDBMS_MySql New()' )
	
	::Connect()
	

RETU SELF



METHOD Connect() CLASS RDBMS_MySql

	AP_RPUTS( 'Connect from RDBMS_MySql' )
	
	 ::pLib = hb_LibLoad( hb_SysMySQL() )
	 
	 AP_RPUTS( 'A1' )
	 
	 if ! Empty( ::pLib )
	 AP_RPUTS( 'A2' )	 
		::hMySQL = ::mysql_init()
	 AP_RPUTS( 'A3' )		
		if ::hMySQL != 0
	 AP_RPUTS( 'A4' )		
		   ::hConnection = ::mysql_real_connect( ::cServer, ::cUsername, ::cPassword, ::cDatabase, ::nPort )
		   if ::hConnection != ::hMySQL
		   
			  	 AP_RPUTS( "Error on connection to server " + ::cServer )
			 else
				AP_RPUTS( 'CONECTAT!!!!' )
		   endif   
		endif 
	 else
		AP_RPUTS ( hb_SysMySQL() + " not available"  )
	 endif  	

RETU NIL


METHOD MySql_Init() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_init", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ) }, NULL )




//----------------------------------------------------------------//
METHOD MySql_Close() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_close", ::pLib,;
                   hb_SysCallConv(), hb_SysLong() }, ::hMySQL )

//----------------------------------------------------------------//
METHOD MySql_Real_Connect() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_real_connect", ::pLib, hb_bitOr( hb_SysLong(),;
                     hb_SysCallConv() ), hb_SysLong(),;
                     HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR, HB_DYN_CTYPE_CHAR_PTR,;
                     HB_DYN_CTYPE_LONG, HB_DYN_CTYPE_LONG, HB_DYN_CTYPE_LONG },;
                     ::hMySQL, ::cServer, ::cUserName, ::cPassword, ::cDataBase, ::nPort, 0, 0 )
                     
//----------------------------------------------------------------//
METHOD MySql_Query( cQuery ) CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_query", ::pLib, hb_bitOr( HB_DYN_CTYPE_INT,;
                   hb_SysCallConv() ), hb_SysLong(), HB_DYN_CTYPE_CHAR_PTR },;
                   ::hConnection, cQuery )

//----------------------------------------------------------------//
METHOD MySql_Use_Result() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_use_result", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ), hb_SysLong() }, ::hMySQL )

//----------------------------------------------------------------//
METHOD MySql_Store_Result() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_store_result", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ), hb_SysLong() }, ::hMySQL )

//----------------------------------------------------------------//
METHOD MySql_Free_Result( hMyRes ) CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_free_result", ::pLib,;
                   hb_SysCallConv(), hb_SysLong() }, hMyRes )

//----------------------------------------------------------------//
METHOD MySql_Fetch_Row( hMyRes ) CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_fetch_row", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ), hb_SysLong() }, hMyRes )

//----------------------------------------------------------------//
METHOD MySql_Num_Rows( hMyRes ) CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_num_rows", ::pLib, hb_bitOr( hb_SysLong(),;
                  hb_SysCallConv() ), hb_SysLong() }, hMyRes )

//----------------------------------------------------------------//
METHOD MySql_Num_Fields( hMyRes ) CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_num_fields", ::pLib, hb_bitOr( HB_DYN_CTYPE_LONG_UNSIGNED,;
                   hb_SysCallConv() ), hb_SysLong() }, hMyRes )

//----------------------------------------------------------------//
METHOD MySql_Fetch_Field( hMyRes ) CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_fetch_field", ::pLib, hb_bitOr( hb_SysLong(),;
                   hb_SysCallConv() ), hb_SysLong() }, hMyRes )

//----------------------------------------------------------------//
METHOD MySql_Get_Server_Info() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_get_server_info", ::pLib, hb_bitOr( HB_DYN_CTYPE_CHAR_PTR,;
                   hb_SysCallConv() ), hb_SysLong() }, ::hMySql )

//----------------------------------------------------------------//
METHOD MySql_Error() CLASS RDBMS_MySql

RETU hb_DynCall( { "mysql_error", ::pLib, hb_bitOr( HB_DYN_CTYPE_CHAR_PTR,;
                   hb_SysCallConv() ), hb_SysLong() }, ::hMySql )

//----------------------------------------------------------------//

function hb_SysLong()

return If( hb_OSIS64BIT(), HB_DYN_CTYPE_LLONG_UNSIGNED, HB_DYN_CTYPE_LONG_UNSIGNED )   

//----------------------------------------------------------------//

function hb_SysCallConv()

return If( ! "Windows" $ OS(), HB_DYN_CALLCONV_CDECL, HB_DYN_CALLCONV_STDCALL )

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
                     "c:/xampp/htdocs/libmysql64.dll",;
                     "c:/xampp/htdocs/libmysql.dll" )
   endif

return cLibName    

//----------------------------------------------------------------//

function hb_SysMyTypePos()

return If( hb_version( HB_VERSION_BITWIDTH ) == 64,;
       If( "Windows" $ OS(), 26, 28 ), 19 )   

//----------------------------------------------------------------//