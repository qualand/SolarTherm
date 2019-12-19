within SolarTherm.Models.Fluid.HeatExchangers;

model HX_wi_noF_modified
  extends SolarTherm.Interfaces.Models.HeatExchangerFluid;
  import SI = Modelica.SIunits;
  import CN = Modelica.Constants;
  import MA = Modelica.Math;
  import SolarTherm.{Models,Media};
  import Modelica.Math.Vectors;
  replaceable package Medium1 = Media.Sodium.Sodium_pT "Medium props for Sodium";
  replaceable package Medium2 = Media.ChlorideSalt.ChlorideSalt_pT "Medium props for Molten Salt";
  //Design Parameters
  parameter SI.HeatFlowRate Q_d_des = 50e6 "Design Heat Flow Rate";
  parameter SI.Temperature T_Na1_des = 740 + 273.15 "Desing Sodium Hot Fluid Temperature";
  parameter SI.Temperature T_MS1_des = 500 + 273.15 "Desing Molten Salt Cold Fluid Temperature";
  parameter SI.Temperature T_MS2_des = 720 + 273.15 "Desing Molten Salt Hot Fluid Temperature";
  parameter SI.Pressure p_Na1_des = 101325 "Design Sodium Inlet Pressure";
  parameter SI.Pressure p_MS1_des = 101325 "Design Molten Salt Inlet Pressure";
  
  //Auxiliary parameters
  parameter Boolean optimize_and_run = true;
  parameter Medium1.ThermodynamicState state_Na_in_0 = Medium1.setState_pTX(p_Na1_des, T_Na1_des);
  parameter Medium2.ThermodynamicState state_MS_in_0 = Medium2.setState_pTX(p_MS1_des, T_MS1_des);
  parameter SI.SpecificEnthalpy h_Na_in_0 = Medium1.specificEnthalpy(state_Na_in_0);
  parameter SI.SpecificEnthalpy h_MS_in_0 = Medium2.specificEnthalpy(state_MS_in_0);
  parameter Medium1.ThermodynamicState state_Na_out_0 = Medium1.setState_pTX(p_Na1_des, T_Na2_design);
  parameter Medium2.ThermodynamicState state_MS_out_0 = Medium2.setState_pTX(p_MS1_des, T_MS2_des);
  parameter SI.SpecificEnthalpy h_Na_out_0 = Medium1.specificEnthalpy(state_Na_out_0);
  parameter SI.SpecificEnthalpy h_MS_out_0 = Medium2.specificEnthalpy(state_MS_out_0);
  parameter SI.HeatFlowRate Q_small = 0.05 * Q_d_des "Design Heat Flow Rate";
  parameter Medium1.ThermodynamicState state_max_Na2 = Medium1.setState_pTX(p_Na1_des, 600 + 273.15);
  parameter SI.MassFlowRate m_flow_Na_min_des(fixed = false) "Sodium minimum mass flow rate";
  parameter SI.MassFlowRate m_flow_MS_min_des(fixed = false) "Molten-Salt minimum mass flow rate";
  //Input parameters
  parameter SI.Length d_o_input = 0.04128 "Optimal Outer Tube Diameter";
  parameter SI.Length L_input = 8 "Optimal Tube Length";
  parameter Integer N_p_input = 4 "Optimal Tube passes number";
  parameter Integer layout_input = 2 "Optimal Tube Layout";
  parameter SI.Temperature T_Na2_input = 670 + 273.15 "Optimal outlet sodium temperature";
  //Optimal Parameter Values
  parameter Real TAC(unit = "€/year", fixed = false) "Minimum Total Annualized Cost";
  parameter SI.Area A_HX(fixed = false) "Optimal Exchange Area";
  parameter SI.CoefficientOfHeatTransfer U_design(fixed = false) "Optimal Heat tranfer coefficient";
  parameter Integer N_t(fixed = false) "Optimal Number of tubes";
  parameter SI.Pressure Dp_tube_design(fixed = false) "Optimal Tube-side pressure drop";
  parameter SI.Pressure Dp_shell_design(fixed = false) "Optimal Shell-side pressure drop";
  parameter SI.CoefficientOfHeatTransfer h_s_design(fixed = false) "Optimal Shell-side Heat tranfer coefficient";
  parameter SI.CoefficientOfHeatTransfer h_t_design(fixed = false) "Optimal Tube-side Heat tranfer coefficient";
  parameter SI.Length D_s(fixed = false) "Optimal Shell Diameter";
  parameter SI.Velocity v_Na_design(fixed = false) "Optimal Sodium velocity in tubes";
  parameter SI.Velocity v_max_MS_design(fixed = false) "Optimal Molten Salt velocity in shell";
  parameter SI.Volume V_HX(fixed = false) "Optimal Heat-Exchanger Total Volume";
  parameter SI.Mass m_HX(fixed = false) "Optimal Heat-Exchanger Total Mass";
  parameter Real C_BEC_HX(unit = "€", fixed = false) "Optimal Bare cost @2018";
  parameter Real C_pump_design(unit = "€/year", fixed = false) "Optimal Annual pumping cost";
  parameter SI.Length d_o(fixed = false) "Optimal Outer Tube Diameter";
  parameter SI.Length L(fixed = false) "Optimal Tube Length";
  parameter Integer N_p(fixed = false) "Optimal Tube passes number";
  parameter Integer layout(fixed = false) "Optimal Tube Layout";
  parameter SI.Temperature T_Na2_design(fixed = false) "Optimal outlet sodium temperature";
  parameter SI.MassFlowRate m_flow_Na_design(fixed = false) "Optimal Sodium mass flow rate";
  parameter SI.MassFlowRate m_flow_MS_design(fixed = false) "Optimal Molten-Salt mass flow rate";
  parameter Real F_design(fixed = false) "Optimal Temperature correction factor";
  parameter SI.ThermalConductance UA_design(fixed = false) "Optimal UA";
  parameter Real ex_eff_design(fixed = false) "Optimal HX Exergetic Efficiency";
  parameter Real en_eff_design(fixed = false) "Optimal HX Energetic Efficiency";
  //Variables
  SI.MassFlowRate m_flow_Na(nominal = m_flow_Na_design) "Sodium mass flow rate";
  SI.MassFlowRate m_flow_MS(start = 0.23 * m_flow_MS_design, nominal = m_flow_MS_design) "Molten Salt mass flow rate";
  SI.Temperature T_Na1 "Sodium Hot Fluid Temperature";
  SI.Temperature T_MS1 "Molten Salt Cold Fluid Temperature";
  SI.Temperature T_MS2 "Molten Salt Hot Fluid Temperature";
  SI.Temperature T_Na2 "Sodium Cold Fluid Temperature";
  SI.Pressure p_Na1(start = p_Na1_des, nominal = p_Na1_des) "Sodium Inlet Pressure";
  SI.Pressure p_MS1(start = p_MS1_des, nominal = p_MS1_des) "Molten Salt Inlet Pressure";
  SI.Pressure p_Na2 "Sodium Outlet Pressure";
  SI.Pressure p_MS2 "Molten Salt Outlet Pressure";
  SI.CoefficientOfHeatTransfer U "Heat tranfer coefficient";
  SI.CoefficientOfHeatTransfer h_s "Shell-side Heat tranfer coefficient";
  SI.CoefficientOfHeatTransfer h_t "Tube-side Heat tranfer coefficient";
  SI.HeatFlowRate Q(start = Q_d_des, nominal = Q_d_des) "Design Heat Flow Rate";
  Real F "Temperature correction factor";
  SI.TemperatureDifference DT1 "Sodium-Molten Salt temperature difference 1";
  SI.TemperatureDifference DT2 "Sodium-Molten Salt temperature difference 2";
  SI.TemperatureDifference LMTD "Logarithmic mean temperature difference";
  SI.Pressure Dp_tube "Tube-side pressure drop";
  SI.Pressure Dp_shell "Shell-side pressure drop";
  SI.Velocity v_Na "Sodium velocity in tubes";
  SI.Velocity v_max_MS "Molten Salt velocity in shell";
  //parameter SI.Temperature T_Na2_min = T_MS1_des + 10 "Optimal outlet sodium temperature";
  //SI.HeatFlowRate Q_receiver "Design Heat Flow Rate";
  Boolean problema(start = false);
  Boolean problema2(start = false);
  
  //Fluid Properties
  SI.Temperature Tm_Na "Mean Sodium Fluid Temperature";
  SI.Temperature Tm_MS "Mean Molten Salts Fluid Temperature";
  SI.ThermalConductivity k_Na "Sodium Conductivity @mean temperature";
  SI.ThermalConductivity k_MS "Molten Salts Conductivity @mean temperature";
  SI.Density rho_Na "Sodium density @mean temperature";
  SI.Density rho_MS "Molten Salts density @mean temperature";
  SI.DynamicViscosity mu_Na "Sodium dynamic viscosity @mean temperature";
  SI.DynamicViscosity mu_MS "Molten Salts  dynamic viscosity @mean temperature";
  SI.DynamicViscosity mu_Na_wall "Sodium dynamic viscosity @wall temperature";
  SI.DynamicViscosity mu_MS_wall "Molten salts dynamic viscosity @wall temperature";
  SI.SpecificHeatCapacity cp_Na "Sodium specific heat capacity @mean temperature";
  SI.SpecificHeatCapacity cp_MS "Molten Salts specific heat capacity @mean temperature";
  Medium1.ThermodynamicState state_mean_Na;
  Medium1.ThermodynamicState state_input_Na;
  Medium1.ThermodynamicState state_output_Na;
  Medium2.ThermodynamicState state_mean_MS;
  Medium2.ThermodynamicState state_wall_MS;
  Medium2.ThermodynamicState state_input_MS;
  Medium2.ThermodynamicState state_output_MS;
  //Ports Variables
  SI.SpecificEnthalpy h_Na_in(start = h_Na_in_0, nominal = h_Na_in_0);
  SI.SpecificEnthalpy h_MS_in(start = h_MS_in_0);
  SI.SpecificEnthalpy h_MS_out(min = h_MS_in_0, start = h_MS_out_0, nominal = h_MS_out_0);
  SI.SpecificEnthalpy h_Na_out(start = h_Na_out_0, nominal = h_Na_out_0);
  
  //Real Input
  Modelica.Blocks.Interfaces.BooleanInput HF_on(start = true) annotation(
    Placement(visible = true, transformation(origin = {26, 46}, extent = {{-6, -6}, {6, 6}}, rotation = -90), iconTransformation(origin = {26, 46}, extent = {{-6, -6}, {6, 6}}, rotation = -90)));
initial algorithm
  if optimize_and_run == true then
    (TAC, A_HX, U_design, N_t, Dp_tube_design, Dp_shell_design, h_s_design, h_t_design, D_s, v_Na_design, v_max_MS_design, V_HX, m_HX, C_BEC_HX, C_pump_design, d_o, L, N_p, layout, T_Na2_design, m_flow_Na_design, m_flow_MS_design, F_design, UA_design, ex_eff_design, en_eff_design) := Find_Opt_Design_HX_noF(Q_d_des = Q_d_des, T_Na1_des = T_Na1_des, T_MS1_des = T_MS1_des, T_MS2_des = T_MS2_des, p_Na1_des = p_Na1_des, p_MS1_des = p_MS1_des);
  else
    d_o := d_o_input;
    L := L_input;
    N_p := N_p_input;
    layout := layout_input;
    T_Na2_design := T_Na2_input;
    (m_flow_Na_design, m_flow_MS_design, F_design, UA_design, N_t, U_design, A_HX, Dp_tube_design, Dp_shell_design, TAC, h_s_design, h_t_design, D_s, v_Na_design, v_max_MS_design, V_HX, m_HX, C_BEC_HX, C_pump_design, ex_eff_design, en_eff_design) := Design_HX(Q_d = Q_d_des, T_Na1 = T_Na1_des, T_MS1 = T_MS1_des, T_MS2 = T_MS2_des, d_o = d_o, L = L, N_p = N_p, layout = layout, T_Na2 = T_Na2_design, p_MS1 = p_MS1_des, p_Na1 = p_Na1_des, c_e = 0.13, r = 0.05, H_y = 4500);
  end if;
  m_flow_MS_min_des := 0.23 * m_flow_MS_design;
  m_flow_Na_min_des := 0.15 * m_flow_Na_design;
equation
//Mass conservation equations
  port_a_in.m_flow + port_a_out.m_flow = 0;
  port_b_in.m_flow + port_b_out.m_flow = 0;
  m_flow_Na = port_a_in.m_flow;
  m_flow_MS = port_b_in.m_flow;
//Fluids Enthalpies
  port_b_out.h_outflow = if HF_on then max(h_MS_out,h_MS_in_0) else h_MS_in;
  port_a_out.h_outflow = if HF_on then h_Na_out else h_Na_in;
  h_Na_in = inStream(port_a_in.h_outflow);
  h_MS_in = inStream(port_b_in.h_outflow);
//Shouldn't have reverse flows
  port_a_in.h_outflow = 0.0;
  port_b_in.h_outflow = 0.0;
//Other ports equations
  port_a_out.Xi_outflow = inStream(port_a_in.Xi_outflow);
  port_a_in.Xi_outflow = inStream(port_a_out.Xi_outflow);
  port_b_out.Xi_outflow = inStream(port_b_in.Xi_outflow);
  port_b_in.Xi_outflow = inStream(port_b_out.Xi_outflow);
  port_a_out.C_outflow = inStream(port_a_in.C_outflow);
  port_a_in.C_outflow = inStream(port_a_out.C_outflow);
  port_b_out.C_outflow = inStream(port_b_in.C_outflow);
  port_b_in.C_outflow = inStream(port_b_out.C_outflow);
//Fluid temperatures and pressures
  T_Na1 = Medium1.temperature(state_input_Na);
  T_Na2 = Medium1.temperature(state_output_Na);
  T_MS1 = Medium2.temperature(state_input_MS);
  T_MS2 = Medium2.temperature(state_output_MS);
  p_Na1 = port_a_in.p;
  p_MS1 = port_b_in.p;
  p_Na2 = port_a_out.p;
  p_MS2 = port_b_out.p;
  p_Na2 = p_Na1;
//-Dp_tube;
  p_MS2 = p_MS1;
//-Dp_shell;
//Molten Salt properties
  Tm_MS = (T_MS1 + T_MS2) / 2;
  state_mean_MS = Medium2.setState_pTX(p_MS1, Tm_MS);
  state_input_MS = Medium2.setState_phX(p_MS1, h_MS_in);
  state_output_MS = Medium2.setState_phX(p_MS1, port_b_out.h_outflow);
  state_wall_MS = Medium2.setState_pTX(p_MS1, Tm_Na);
  rho_MS = Medium2.density(state_mean_MS);
  cp_MS = Medium2.specificHeatCapacityCp(state_mean_MS);
  mu_MS = Medium2.dynamicViscosity(state_mean_MS);
  k_MS = Medium2.thermalConductivity(state_mean_MS);
  mu_MS_wall = Medium2.dynamicViscosity(state_wall_MS);
//Sodium properties
  Tm_Na = (T_Na1 + T_Na2) / 2;
  state_mean_Na = Medium1.setState_pTX(p_Na1, Tm_Na);
  state_input_Na = Medium1.setState_phX(p_Na1, h_Na_in);
  state_output_Na = Medium1.setState_phX(p_Na1, port_a_out.h_outflow);
  rho_Na = Medium1.density(state_mean_Na);
  cp_Na = Medium1.specificHeatCapacityCp(state_mean_Na);
  mu_Na = Medium1.dynamicViscosity(state_mean_Na);
  mu_Na_wall = mu_Na;
  k_Na = Medium1.thermalConductivity(state_mean_Na);

//Problem
  Q = max(1e-3, m_flow_Na) * (h_Na_in - h_Na_out);
//Q=max(1e-3, m_flow_MS)*(h_MS_out-h_MS_in);
//h_MS_out = max(h_MS_in+(Q/max(1e-3, m_flow_MS)),h_MS_in+Q_small/max(m_flow_MS_min_des, m_flow_MS));
//Q=if HF_on then max(Q/(h_MS_out-h_MS_in),5) else 0;
  m_flow_MS = /*if low_flow then onnn*max(m_flow_MS_min_des,Q /(h_MS_out - h_MS_in)) else*/ Q / (h_MS_out - h_MS_in);
/*if HF_on then max(1,Q/(h_MS_out - h_MS_in)) else*/
//h_MS_out = h_MS_in + Q/m_flow_MS;
  DT1 = T_Na1 - T_MS2;
  DT2 = T_Na2 - T_MS1;
  LMTD = if not HF_on then 0 else if noEvent(DT1 / DT2 <= 0 or DT1 == DT2) then 0 else (DT1 - DT2) / MA.log(DT1 / DT2);
  F = 1;
  (U, h_s, h_t) = HTCs(d_o = d_o, N_p = N_p, layout = layout, N_t = N_t, state_mean_Na = state_mean_Na, state_mean_MS = state_mean_MS, state_wall_MS = state_wall_MS, m_flow_Na = m_flow_Na, m_flow_MS = m_flow_MS);
  Q = U * A_HX * F * LMTD;
  (Dp_tube, Dp_shell, v_Na, v_max_MS) = Dp_losses(d_o = d_o, N_p = N_p, layout = layout, N_t = N_t, L = L, state_mean_Na = state_mean_Na, state_mean_MS = state_mean_MS, state_wall_MS = state_wall_MS, m_flow_Na = m_flow_Na, m_flow_MS = m_flow_MS);
  problema = if m_flow_MS <= 0 and HF_on then true else false;
  problema2 = if port_b_out.h_outflow <= 0 then true else false;
  assert(problema == false, "Mass Flow Rate zero", level = AssertionLevel.error);
  assert(problema2 == false, "Enthalpy_out zero", level = AssertionLevel.error);
//  when not HF_on then
//     reinit(T_MS2, T_MS2_des);
//  end when;
end HX_wi_noF_modified;