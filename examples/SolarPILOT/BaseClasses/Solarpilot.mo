within examples.SolarPILOT.BaseClasses;
class Solarpilot
  extends ExternalObject;

  function constructor
    output Solarpilot spObj;
    external "C" spObj = sp_data_create() annotation (
      Library = "solarpilot",
      Include = "#include \"CoPilot_API.h\"");
  end constructor;
  
  function destructor
    input Solarpilot spObj;
    external "C" sp_data_free(spObj) annotation (
      Library = "solarpilot",
      Include = "#include \"CoPilot_API.h\"");
  end destructor;
end Solarpilot;
