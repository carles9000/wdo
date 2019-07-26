/*	---------------------------------------------------------
	File.......: wdo.prg
	Description: Base WDO. Conexión a Bases de Datos. 
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */
	
#define WDO_VERSION 		0.1	

CLASS WDO	

	DATA  oDb
	DATA  cRdbms
	DATA  cRdbms 		
	DATA  cServer		
	DATA  cUserName	
	DATA  cPassword 	
	DATA  cDatabase 	
	DATA  nPort 		


	METHOD New( cRdbms ) 						CONSTRUCTOR
			
	
	METHOD Connect()

	METHOD Version()							INLINE WDO_VERSION
	
	DESTRUCTOR  Close() 						

ENDCLASS

METHOD New( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort ) CLASS WDO

	hb_default( @cRdbms , 'DBF' )
	hb_default( @cServer, '' )
	hb_default( @cUserName, '' )
	hb_default( @cPassword, '' )
	hb_default( @cDatabase, '' )
	hb_default( @nPort, 0 )
	
	::cRdbms 		:= Upper( cRdbms )
	::cServer		:= cServer
	::cUserName	:= cUserName
	::cPassword 	:= cPassword
	::cDatabase 	:= cDatabase
	::nPort 		:= nPort

	AP_RPUTS( 'WDO New()' )
	AP_RPUTS( ::cRdbms )

RETU SELF



METHOD Connect() CLASS WDO

	DO CASE
		CASE ::cRdbms == 'DBF'		
		CASE ::cRdbms == 'MYSQL'	; ::oDb := RDBMS_MySql():New( ::cServer, ::cUsername, ::cPassword, ::cDatabase, ::nPort )
	ENDCASE

	AP_RPUTS( '<hr>Connect ' + ::cRdbms )

RETU NIL


METHOD Close() CLASS WDO

	AP_RPUTS( '<hr>WDO Close()' )

RETU SELF