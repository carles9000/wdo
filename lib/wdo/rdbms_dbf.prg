/*	---------------------------------------------------------
	File.......: rdbms_dbf.prg
	Description: Conexión a Dbf
	Author.....: Carles Aubia Floresvi
	Date:......: 26/07/2019
	--------------------------------------------------------- */
 

	
CLASS RDBMS_Dbf FROM RDBMS

	METHOD New() 						CONSTRUCTOR
	
	METHOD Connect() 

ENDCLASS

METHOD New( cRdd, cDbf, cCdx ) CLASS RDBMS_Dbf

	hb_default( @cDbf, '' )
	hb_default( @cCdx, '' )
	
	::cDbf		:= cDbf
	::cCdx		:= cCdx

	? 'RDBMS_Dbf', ::cDbf, ::cCdx
	
	//::Connect()
	

RETU SELF



METHOD Connect() CLASS RDBMS_Dbf

	? 'Connect from RDBMS_Dbf' 	

RETU NIL

