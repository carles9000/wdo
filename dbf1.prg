//	------------------------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) %}				//	Loading WDO lib
//	------------------------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	LOCAL oDb1, oDb2, oDbf3
	
	?? 'Init ' + time() + '<hr>'

	
	//	Config Sistema...
	
		o := WDO():Dbf()
			o:cDefaultPath 	:= hb_getenv( 'PRGPATH' ) + '/data'				
			o:cDefaultRdd 		:= 'DBFCDX'

	//	Open Tables
	
		oDb1 := WDO():Dbf( 'customer.dbf', 'customer.cdx' )				
		
		oDb2 := WDO():Dbf( 'states.dbf', 'states.cdx' )			
		
		oDb3 := WDO():Dbf( 'users.dbf', 'users.ntx', .F. )	//	3 param. Open
				oDb3:cRdd 	:= 'DBFNTX'		
				oDb3:Open()				
		
		? '<b>==> Open tables...</b>'
		
		
	//	Seek States...
	
		? '<br><b>==> Seek States...</b>'
	
		oDb2:Focus( 'CODE' )
		
		IF oDb2:Seek( 'MA' )
		
			? oDb2:FieldGet( 'code' ), oDb2:FieldGet( 'name' )
			
		ENDIF
		
	//	Info Customer...	
	
		? '<br><b>==> Info Customer...</b>'
	
		? oDb1:cDbf, oDb1:cRdd
		
		? 'lOpen', oDb1:lOpen
		? 'First()', oDb1:first()
		? 'Fieldget(1)', oDb1:FieldGet( 1 )
		? 'Fieldget( "first" )', oDb1:FieldGet( 'first' )
		? 'Count()', oDb1:Count()
		? 'Fieldname(1)', oDb1:FieldName( 1 )
		? 'Next(5)', oDb1:next( 5 ), oDb1:Recno(), oDb1:FieldGet( 1 )
		? 'Goto(7)', oDb1:goto(7), oDb1:Recno(), oDb1:FieldGet( 1 )
		? 'Prev(2)', oDb1:prev( 2 ), oDb1:Recno(), oDb1:FieldGet( 1 )
		? 'Last()', oDb1:last(), oDb1:FieldGet( 1 )
		? 'First()', oDb1:first(),oDb1:Recno(), oDb1:FieldPut( 'street', time() )
		? 'Street: ' , oDb1:FieldGet( 'street' ), oDb1:Recno()
		? '<hr>'		
		

RETU NIL