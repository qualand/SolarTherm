within examples.SolarPILOT.BaseClasses;

class MyTable
  extends ExternalObject;

  function constructor
    input   String  fileName  = "";
    input   String  tableName  = ""; 
    output  MyTable table;
  
    external "C"  table = initMyTable(fileName, tableName);  annotation(
      Include = "#include \"external.c\"");
  end constructor;

  function destructor
    input MyTable table;
  
    external "C" closeMyTable(table) annotation(
      Include = "#include \"external.c\"");
  end destructor;
end MyTable;
