/*	---------------------------------------------------------
	File.......: wdo.prg
	Description: Base WDO. Conexión a Bases de Datos. 
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */
	
#define WDO_VERSION 		0.1	

CLASS WDO	

	DATA  cType
	
	DATA  oDb
	DATA  cRdbms
	DATA  cRdbms 		
	DATA  cServer		
	DATA  cUserName	
	DATA  cPassword 	
	DATA  cDatabase 	
	DATA  nPort
	
	DATA  cRdd		
	DATA  cDbf		
	DATA  cCdx		

	
	METHOD Rdbms( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort ) 	CONSTRUCTOR
	METHOD Rdd( cRdbms, cDbf, cCdx )												CONSTRUCTOR
			
	
	METHOD Connect()

	METHOD Version()							INLINE WDO_VERSION
	
	DESTRUCTOR  Close() 						

ENDCLASS

METHOD Rdd( cRdd, cDbf, cCdx ) CLASS WDO

	hb_default( @cRdd , 'DBFCDX' )
	hb_default( @cDbf, '' )
	hb_default( @cCdx, '' )
	
	::cType 		:= 'DBF'
	
	::cRdd 			:= Upper( cRdd )
	::cDbf			:= cDbf
	::cCdx			:= cCdx	

RETU Self


METHOD Rdbms( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort ) CLASS WDO

	hb_default( @cRdbms , 'MYSQL' )
	hb_default( @cServer, '' )
	hb_default( @cUserName, '' )
	hb_default( @cPassword, '' )
	hb_default( @cDatabase, '' )
	hb_default( @nPort, 0 )
	
	::cType 		:= 'RDBMS'	
	
	::cRdbms 		:= Upper( cRdbms )
	::cServer		:= cServer
	::cUserName	:= cUserName
	::cPassword 	:= cPassword
	::cDatabase 	:= cDatabase
	::nPort 		:= nPort

	
	? 'WDO New()', ::cRdbms


RETU SELF



METHOD Connect() CLASS WDO

	? '<hr>Connect ' + ::cRdbms 
	
	DO CASE
		CASE ::cType == 'DBF'		; ::oDb := RDBMS_Dbf():New( ::cRdd, ::cDbf, ::cCdx )
		CASE ::cType == 'RDBMS'		; ::oDb := RDBMS_MySql():New( ::cServer, ::cUsername, ::cPassword, ::cDatabase, ::nPort )
	ENDCASE


RETU NIL


METHOD Close() CLASS WDO

	AP_RPUTS( '<hr>WDO Close()' )

RETU SELF