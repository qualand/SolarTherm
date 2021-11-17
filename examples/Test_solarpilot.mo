within examples;
model Test_solarpilot
  Solarpilot sp_object = Solarpilot();
  String version;
equation
  version = get_sp_version(sp_object);

end Test_solarpilot;
