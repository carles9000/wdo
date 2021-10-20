//	------------------------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//
//	{% LoadHRB( '/lib/wdo/wdo.hrb' ) %}		//	Loading WDO lib
//	------------------------------------------------------------------------------

FUNCTION Main()

	LOCAL o
	LOCAL oDb1, oDb2, oDb3, oDb4
	
	?? 'Init ' + time() + '<hr>'

	
	//	Config Sistema...
	
		o := WDO():Dbf()
			o:cDefaultPath 	:= hb_getenv( 'PRGPATH' ) + '/data'				
			o:cDefaultRdd 		:= 'DBFCDX'

	//	Open Tables
	
		oDb1 := WDO():Dbf( 'customer.dbf', 'customer.cdx' )				
		
		oDb2 := WDO():Dbf( 'states.dbf', 'states.cdx' )		
		
		oDb3 := WDO():Dbf( 'vendors.dbf', 'vendors.cdx', .F. )	
				oDb3:cPath 	:= hb_getenv( 'PRGPATH' ) + '/data/sales'			
				oDb3:Open()			
		
		oDb4 := WDO():Dbf( 'users.dbf', 'users.ntx', .F. )	//	3 param. Open
				oDb4:cRdd 	:= 'DBFNTX'		
				oDb4:Open()				
		
		? '<b>==> Open tables...</b>'
		
		
	//	Seek States...
	
		? '<br><b>==> Seek States...</b>'
	
		oDb2:Focus( 'CODE' )
		
		IF oDb2:Seek( 'MA' )
		
			? oDb2:FieldGet( 'code' ), oDb2:FieldGet( 'name' )
			
		ENDIF
		
	//	List Vendors...
	
		? '<br><b>==> List Vendors...</b>'
	
		oDb3:First()
		
		WHILE !oDb3:Eof()

			? oDb3:FieldGet( 'id' ), oDb3:FieldGet( 'name' ),  oDb3:FieldGet( 'phone' ) 
			oDb3:next()
		END
	
		
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
		? 'First()', oDb1:first(),oDb1:Recno()
		
		IF oDb1:Rlock()
		   oDb1:FieldPut( 'street', time() )
		ENDIF
		
		? 'Street: ' , oDb1:FieldGet( 'street' ), oDb1:Recno()
		? '<hr>'		
		

RETU NIL