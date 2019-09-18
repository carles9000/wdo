//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO - ADO
//	Date.......: 17/09/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}		//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL hCfg 	:= Config_ADO()
	LOCAL o, oRs
	
		?? 	"<h3>Paginacion con MS SQL</h3>"
		?	"Sql: ", "SELECT *, ROW_NUMBER() OVER (ORDER BY FIRST) AS RowNum FROM CUSTOMER WHERE STATE = 'NY' ORDER BY FIRST"
	
		o := WDO():ADO( hCfg, .T. )		
		
		oRs := o:Query( "SELECT *, ROW_NUMBER() OVER (ORDER BY FIRST) AS RowNum FROM CUSTOMER WHERE STATE = 'NY' ORDER BY FIRST" ) 
		
		oRs:View( oRs:FetchAll() )
		
		? '<hr>'
		
		oRs := o:Query( "SELECT *, ROW_NUMBER() OVER (ORDER BY FIRST) AS RowNum FROM CUSTOMER WHERE STATE = 'NY' ORDER BY FIRST OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY" ) 
		
		oRs:View( oRs:FetchAll() )
		
		? '<hr>'	

		oRs := o:Query( "SELECT *, ROW_NUMBER() OVER (ORDER BY FIRST) AS RowNum FROM CUSTOMER WHERE STATE = 'NY' ORDER BY FIRST OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY" ) 
		
		oRs:View( oRs:FetchAll() )
		
		? '<hr>'

		oRs := o:Query( "SELECT *, ROW_NUMBER() OVER (ORDER BY FIRST) AS RowNum FROM CUSTOMER WHERE STATE = 'NY' ORDER BY FIRST OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY" ) 
		
		oRs:View( oRs:FetchAll() )		
		
		
RETU NIL

{% memoread( HB_GETENV( 'PRGPATH' ) + "/cfg_ado.prg" ) %}
