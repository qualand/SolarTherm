within examples;

model ReceiverTestRig_Surrogate
  extends SolarTherm.Icons.ToDo;
  import SolarTherm.{Models,Media};
  import Modelica.SIunits.Conversions.from_degC;
  import SI = Modelica.SIunits;
  import nSI = Modelica.SIunits.Conversions.NonSIunits;
  import CN = Modelica.Constants;
  import CV = Modelica.SIunits.Conversions;
  import FI = SolarTherm.Models.Analysis.Finances;
  import Util = SolarTherm.Media.SolidParticles.CarboHSP_utilities;
  import Modelica.Math;
  import Modelica.Blocks;
  replaceable package Medium = SolarTherm.Media.SolidParticles.CarboHSP_ph "Medium props for Carbo HSP 40/70";
  // Design Condition
  parameter Real T_out_design = from_degC(800);
  parameter Real T_in_design = 803.15;
  parameter Real T_amb_design = 268.15;
  parameter SI.HeatFlowRate Q_in = 280e6;
  parameter Real H_drop = 23;
  parameter SI.Length H_drop_design(fixed = false);
  Modelica.Fluid.Sources.FixedBoundary source(redeclare package Medium = Medium, T = T_in_design, nPorts = 1, p = 1e5, use_T = true, use_p = false) annotation(
    Placement(visible = true, transformation(origin = {60, -14}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Fluid.Sources.FixedBoundary sink(redeclare package Medium = Medium, T = 300.0, d = 3300, nPorts = 1, p = 1e5, use_T = true) annotation(
    Placement(visible = true, transformation(extent = {{34, 22}, {14, 42}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow Heat(Q_flow = Q_in, T_ref = 298.15) annotation(
    Placement(visible = true, transformation(origin = {-78, 44}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.BooleanExpression Operation(y = true) annotation(
    Placement(visible = true, transformation(origin = {-78, -4}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression realExpression(y = T_amb_design) annotation(
    Placement(visible = true, transformation(origin = {-56, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  SolarTherm.Models.Fluid.Pumps.LiftSimple liftSimple(use_input = true) annotation(
    Placement(visible = true, transformation(origin = {22, -16}, extent = {{-16, -16}, {16, 16}}, rotation = 0)));
  SolarTherm.Models.CSP.CRS.Receivers.ParticleReceiver particleReceiver(H_drop_design = H_drop_design, redeclare package Medium = Medium, T_out = T_out_design,use_neural_network = true) annotation(
    Placement(visible = true, transformation(origin = {-23, 37}, extent = {{-21, -21}, {21, 21}}, rotation = 0)));
initial equation
  H_drop_design = H_drop;
equation
  connect(source.ports[1], liftSimple.fluid_a) annotation(
    Line(points = {{50, -14}, {27, -14}}, color = {0, 127, 255}));
  connect(liftSimple.fluid_b, particleReceiver.fluid_a) annotation(
    Line(points = {{16, -14}, {-20, -14}, {-20, 18}, {-18, 18}}, color = {0, 127, 255}));
  connect(Operation.y, particleReceiver.on) annotation(
    Line(points = {{-66, -4}, {-28, -4}, {-28, 18}, {-26, 18}}, color = {255, 0, 255}));
  connect(Heat.port, particleReceiver.heat) annotation(
    Line(points = {{-68, 44}, {-44, 44}, {-44, 44}, {-44, 44}}, color = {191, 0, 0}));
  connect(particleReceiver.fluid_b, sink.ports[1]) annotation(
    Line(points = {{-16, 48}, {2, 48}, {2, 32}, {14, 32}, {14, 32}}, color = {0, 127, 255}));
  connect(realExpression.y, particleReceiver.Tamb) annotation(
    Line(points = {{-44, 80}, {-18, 80}, {-18, 54}, {-18, 54}}, color = {0, 0, 127}));
  connect(realExpression.y, particleReceiver.Wspd) annotation(
    Line(points = {{-44, 80}, {-24, 80}, {-24, 54}, {-22, 54}}, color = {0, 0, 127}));
  connect(realExpression.y, particleReceiver.Wdir) annotation(
    Line(points = {{-44, 80}, {-28, 80}, {-28, 54}, {-28, 54}}, color = {0, 0, 127}));
protected
  annotation(
    uses(Modelica(version = "3.2.2"), SolarTherm(version = "0.2")),
    experiment(StartTime = 0, StopTime = 3.1536e7, Tolerance = 1e-06, Interval = 3600),
    __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"),
    Diagram);
end ReceiverTestRig_Surrogate;