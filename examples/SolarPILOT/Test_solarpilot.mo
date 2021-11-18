within examples.SolarPILOT;
model Test_solarpilot

  examples.SolarPILOT.BaseClasses.Solarpilot testObj=examples.SolarPILOT.BaseClasses.Solarpilot();
  String version;

equation
  version=examples.SolarPILOT.BaseClasses.get_sp_version(testObj);

end Test_solarpilot;
