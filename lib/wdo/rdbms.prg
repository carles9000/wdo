/*	---------------------------------------------------------
	File.......: wdo.prg
	Description: Base WDO. Conexión a Bases de Datos. 
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */
	
CLASS RDBMS	

	DATA  cType
	
	DATA  cRdbms
	DATA  cServer
	DATA  cUsername
	DATA  cDatabase
	DATA  cPassword
	DATA  nPort
	DATA  hConnection 
	
	
	DATA  cRdd		
	DATA  cDbf		
	DATA  cIndex	

	DATA lShowError						INIT .T.	

	METHOD New() 						CONSTRUCTOR


ENDCLASS

METHOD New() CLASS RDBMS

	? 'RDBMS New()'

RETU SELF
