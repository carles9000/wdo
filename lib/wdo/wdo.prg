/*	---------------------------------------------------------
	File.......: wdo.prg
	Description: Base WDO. Conexión a Bases de Datos. 
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */
	
#define WDO_VERSION 		'0.1a'

CLASS WDO	

	METHOD Dbf( cDbf, cCdx )															CONSTRUCTOR
	METHOD Rdbms( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort ) 	CONSTRUCTOR					
	
ENDCLASS

METHOD Dbf( cDbf, cCdx, lOpen ) CLASS WDO
		
RETU RDBMS_Dbf():New( cDbf, cCdx, lOpen )

METHOD Rdbms( cRdbms, cServer, cUsername, cPassword, cDatabase, nPort ) CLASS WDO

	LOCAL oDb

	hb_default( @cRdbms, '' )
	
	cRdbms := upper( cRdbms )

	DO CASE
		CASE cRdbms == 'MYSQL'; 	oDb := RDBMS_MySql():New( cServer, cUsername, cPassword, cDatabase, nPort )
		//CASE cRdbms == 'SQLITE'; 	oDb := RDBMS_SQLite():New( cServer, cUsername, cPassword, cDatabase, nPort )
	ENDCASE

RETU oDb


