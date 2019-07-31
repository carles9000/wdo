

function main()

	LOCAL cFile := hb_getenv( 'PRGPATH' ) + '/data/customer.dbf'
	LOCAL lExclusive := .T.
	LOCAL lRead := .F.

	? time(), cFile
	
	//USE  (cFile)  SHARED NEW
	
	DbUseArea( .T., 'DBFCDX', cFile, 'CUSTO', ! lExclusive, lRead )
	
	? Alias()
	
	INDEX ON first TAG first
	
	? CUSTO->first

retu nil
