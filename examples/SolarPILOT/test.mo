within examples.SolarPILOT;
model test

  examples.SolarPILOT.BaseClasses.MyTable table = examples.SolarPILOT.BaseClasses.MyTable(fileName = "testTables.txt",
  tableName="table1");
  Real y;


equation
  y=examples.SolarPILOT.BaseClasses.interpolateMyTable(table, time);

end test;
