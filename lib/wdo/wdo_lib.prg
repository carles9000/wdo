/*	----------------------------------------------------------------------------
	Name:			LIB WDO - Web Database Objects
	Description: 	Acceso a Base de Datos
	Autor:			Carles Aubia
	Date: 			26/07/19	
-------------------------------------------------------------------------------- */

//	Se han de definir estos comandos pues los usamos en algunos m├│dulos...
#xcommand ? [<explist,...>] => AP_RPuts( '<br>' [,<explist>] )
#xcommand ?? [<explist,...>] => AP_RPuts( [<explist>] )
#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] => #pragma __cstream | AP_RPuts( InlinePrg( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )
//	-------------------------------------------------------------------------------- 

#include "hbclass.ch" 
#include "hboo.ch"   
#include "hbhash.ch"

#include "wdo.prg" 					//	WDO
#include "rdbms.prg" 				//	Base RDBMS
#include "rdbms_mysql.prg" 			//	MySql
#include "rdbms_dbf.prg" 			//	Dbf
#include "tmodel.prg" 				//	Clase TModel
//	---------------------------------------------------------------------------- //
