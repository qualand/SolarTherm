within examples.SolarPILOT.BaseClasses;
function interpolateMyTable
  input MyTable table;
  input Real u;
  output Real y;
  external "C" y=interpolateMyTable(table, u)
    annotation (
      Include = "#include \"external.c\"");
end interpolateMyTable;
