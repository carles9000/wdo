//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO - ADO
//	Date.......: 17/09/2019
//
//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}		//	Loading WDO lib
//	--------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	LOCAL hCfg 	:= Config_ADO()
		
		//o := WDO():ADO( hCfg, .T. )
		
		o := WDO():ADO( hCfg[ 'server' ], hCfg[ 'user' ], hCfg[ 'pwd' ], hCfg[ 'db' ], .T. )	//	.T. lAutoOpen, default .F.
		
		IF o:lConnect
		
			? 'Connected !'
			
		ELSE
		
			? 'Error: ', o:cError 
			
		ENDIF		

RETU NIL

{% memoread( HB_GETENV( 'PRGPATH' ) + "/cfg_ado.prg" ) %}
