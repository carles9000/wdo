//	--------------------------------------------------------------
//	Title......: WDO Web Database Objects
//	Description: Test WDO
//	Date.......: 28/07/2019
//	
//	Input for inyection test
//	--------------------------------------------------------------

function Main()

   TEMPLATE
<html>
  <head>
    <meta charset="utf-8">
    <title>Ejemplo inyeccion</title>
  </head>
  
  <h3>Ejemplo de inyección básica.</h3>
  <h4>El sistema es vulnerable si no evitamos inyecciones del tipo => ' OR ''='  </h4><hr>
  
  
  <body>
    <form action="sql7_srv.prg" method="post">
      User name:
      <br>
      <input type="text" name="user" value="demo">
      <br>
      Password: 
      <br>
      <input type="text" name="psw" value="1234">
      <br><br>
      <input type="submit" value="Send data">
    </form>
  </body>
</html>
   ENDTEXT

return nil
