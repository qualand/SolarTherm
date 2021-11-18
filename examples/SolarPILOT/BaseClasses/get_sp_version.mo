within examples.SolarPILOT.BaseClasses;
function get_sp_version
  input Solarpilot spObj;
  output String version;
  external "C" version=sp_version(spObj)
    annotation (
      Library = "solarpilot",
      Include = "#include \"CoPilot_API.h\"");
end get_sp_version;
