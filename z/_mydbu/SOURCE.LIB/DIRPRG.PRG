

FUNCTION DirPrg()
RETURN cPathNoSlash(cFilePath(GetModuleFileName(GetInstance())))

FUNCTION cPathNoSlash(cPath)
RETURN iif(Right(cPath,1)=="\",Substr(cPath,1,len(cPath)-1) ,cPath )

FUNCTION ExeName()
RETURN cFileNoExt(GetModuleFileName(GetInstance()))
