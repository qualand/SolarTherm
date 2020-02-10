within SolarTherm.Models.Fluid.HeatExchangers.Utilities;
function Design_HX_noF
  import SI = Modelica.SIunits;
  import CN = Modelica.Constants;
  import MA = Modelica.Math;
  import SolarTherm.{Models,Media};
  import Modelica.Math.Vectors;
  import FI = SolarTherm.Models.Analysis.Finances;
  import SolarTherm.Types.Currency;
  
  input SI.HeatFlowRate Q_d "Design Heat Flow Rate";
  input SI.Temperature T_Na1 "Desing Sodium Hot Fluid Temperature";
  input SI.Temperature T_MS1 "Desing Molten Salt Cold Fluid Temperature";
  input SI.Temperature T_MS2 "Desing Molten Salt Hot Fluid Temperature";
  input SI.Length d_o "Outer Tube diameter";
  input SI.Length L "Tube length";
  input Integer N_p "Number of passes";
  input Integer N_sp "Number of passes";
  input Integer layout "Tube layout"; // if layout=1(one) is square, while if layout=2(two) it is triangular //
  input SI.Temperature T_Na2 "Sodium Cold Fluid Temperature";
  input SI.Pressure p_Na1 "Sodium Inlet Pressure";
  input SI.Pressure p_MS1 "Molten Salt Inlet Pressure";
  input FI.EnergyPrice_kWh c_e "Power cost";
  input Real r "Real interest rate";
  input Real H_y(unit= "h") "Operating hours";
  input Integer n(unit= "h") "Operating years";

  output SI.MassFlowRate m_flow_Na "Sodium mass flow rate";
  output SI.MassFlowRate m_flow_MS "Molten-Salt mass flow rate";
  output Real F(unit = "") "Temperature correction factor";
  output SI.ThermalConductance UA "UA";
  output Integer N_t "Number of tubes";
  output SI.CoefficientOfHeatTransfer U_calc "Heat tranfer coefficient";
  output SI.Area A_tot "Exchange Area";
  output SI.Pressure Dp_tube "Tube-side pressure drop";
  output SI.Pressure Dp_shell "Shell-side pressure drop";
  output FI.MoneyPerYear TAC "Total Annualized Cost";
  output SI.CoefficientOfHeatTransfer h_s "Shell-side Heat tranfer coefficient";
  output SI.CoefficientOfHeatTransfer h_t "Tube-side Heat tranfer coefficient";
  output SI.Length D_s "Shell Diameter";
  output Integer N_baffles "Number of baffles";
  output SI.Velocity v_Na "Sodium velocity in tubes";
  output SI.Velocity v_max_MS "Molten Salt velocity in shell";
  output SI.Volume V_HX "Heat-Exchanger Total Volume";
  output SI.Mass m_HX "Heat-Exchanger Total Mass";
  output SI.Mass m_material "Heat-Exchanger Material Mass";
  output FI.Money_USD C_BEC  "Bare cost @2018";
  output FI.MoneyPerYear C_pump  "Annual pumping cost";
  output Real ex_eff(unit="") "HX Exergetic Efficiency";
  output Real en_eff(unit="") "HX Energetic Efficiency";
  
  protected
  parameter SI.CoefficientOfHeatTransfer U_guess=1200 "Heat tranfer coefficient guess";
  parameter Real tol=0.01 "Heat transfer coefficient tollerance";
  Real condition "When condition";
  SI.CoefficientOfHeatTransfer U_calc_prev "Heat tranfer coefficient guess";
  SI.ThermalConductivity k_wall "Tube Thermal Conductivity";
  SI.Density rho_wall "HX material density";
  SI.Temperature Tm_wall "Mean Wall Temperature";
  parameter SI.Length t_tube=TubeThickness(d_o) "Tube thickness";
  parameter Currency currency = Currency.USD "Currency used for cost analysis";
  
  
  //Tube Side  
  parameter SI.Area A_st=CN.pi*d_o*L "Single tube exchange area";
  parameter SI.Length d_i=d_o-2*t_tube "Inner Tube diameter";
  Integer Tep(start=7962) "Tubes for each pass";
  
  //Shell Side
  Real KK1(unit= "",start=0.158) "Correlation coefficient";
  Real nn1(unit= "",start=2.263) "Correlation coefficient";
  SI.Length L_bb(start=0.0342502444061721) "Bundle-to-shell diametral clearance";
  SI.Length l_b "Baffle spacing";
  SI.Length D_b(start=4.42) "Bundle diameter";
  SI.Length t_baffle "Baffle thickness";
  SI.Length t_shell "Shell thickness";
  SI.Length D_s_out "Shell Outer Diameter";
  parameter Real B=0.25 "Baffle cut";  
  
  //Volume_and_Weight
  SI.Mass m_Na "Mass of Sodium";
  SI.Mass m_MS "Mass of Molten Salts";
  SI.Volume V_Na "Volume of Sodium";
  SI.Volume V_MS "Volume of Molten Salt";
  SI.Volume V_material "Volume of HX material";
  SI.Volume V_tubes "Tube Material Volume";
  SI.Volume V_baffles "Baffles Material Volume";
  SI.Volume V_ShellThickness "External Material Volume HX";  
  
  //Cost Functions
  parameter Real CEPCI_01=397 "CEPCI 2001";
  parameter Real CEPCI_18=603.1 "CEPCI 2018";
  parameter Real M_conv = if currency == Currency.USD then 1 else 0.9175 "Conversion factor";
  parameter Real eta_pump=0.75 "Pump efficiency";
  Real k1(unit= "") "Non dimensional factor";
  Real k2(unit= "") "Non dimensional factor";
  Real k3(unit= "") "Non dimensional factor";
  SI.Area A_cost "Area for cost function";
  FI.Money_USD C_BM  "Bare module cost @operating pressure and with material";
  FI.Money_USD C_p0  "Bare module cost @2001";
  Real C1(unit= "") "Non dimensional factor";
  Real C2(unit= "") "Non dimensional factor";
  Real C3(unit= "") "Non dimensional factor";
  Real B1(unit= "") "Non dimensional factor";
  Real B2(unit= "") "Non dimensional factor";
  Real f(unit= "") "Annualization factor";
  Real Fp(unit= "") "Cost pressure factor";
  Real Fm(unit= "") "Cost material factor";
  Boolean both "Condition for pressure factor correlation";
  SI.Pressure P_shell "Shell-side pressure";
  SI.Pressure P_tubes "Tube-side pressure";
  Real P_tube_cost(unit= "barg") "Tube pressure in barg";
  Real P_shell_cost(unit= "barg") "Shell pressure in barg";
  Real P_cost(unit= "barg") "HX pressure in barg";
  parameter FI.MassPrice material_sc=84*1.65/*4.38*/ "Material HX Specific Cost";
  parameter SI.Mass m_material_HX_ref=/*121857*//*248330*/209781 "Reference Heat-Exchanger Material Mass";
  parameter SI.Area A_ref=/*11914.5*//*22530.8*/21947.3 "Reference Heat-Exchanger Area";
  FI.Money_USD C_BEC_ref  "Bare cost @2018";
  
  //Fluid properties
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
  SI.SpecificEnthalpy h_Na1 "Sodium specific enthalpy @inlet temperature";
  SI.SpecificEnthalpy h_Na2 "Sodium specific enthalpy @outlet temperature";
  SI.SpecificEntropy s_Na1 "Sodium specific entropy @inlet temperature";
  SI.SpecificEntropy s_Na2 "Sodium specific entropy @outlet temperature";
  SI.SpecificEnthalpy h_MS1 "Molten Salt specific enthalpy @inlet temperature";
  SI.SpecificEnthalpy h_MS2 "Molten Salt specific enthalpy @outlet temperature";
  SI.SpecificEntropy s_MS1 "Molten Salt specific entropy @inlet temperature";
  SI.SpecificEntropy s_MS2 "Molten Salt specific entropy @outlet temperature";
  replaceable package Medium1 = Media.Sodium.Sodium_pT "Medium props for Sodium";
  replaceable package Medium2 = Media.ChlorideSalt.ChlorideSalt_pT "Medium props for Molten Salt";
  Medium1.ThermodynamicState state_mean_Na;
  Medium1.ThermodynamicState state_input_Na;
  Medium1.ThermodynamicState state_output_Na;
  Medium2.ThermodynamicState state_mean_MS;
  Medium2.ThermodynamicState state_wall_MS;
  Medium2.ThermodynamicState state_input_MS;
  Medium2.ThermodynamicState state_output_MS;
  //Temperature differences
  SI.TemperatureDifference DT1 "Sodium-Molten Salt temperature difference 1";
  SI.TemperatureDifference DT2 "Sodium-Molten Salt temperature difference 2";
  SI.TemperatureDifference LMTD "Logarithmic mean temperature difference";

  
algorithm
  Tm_Na:=(T_Na1+T_Na2)/2;
  Tm_MS:=(T_MS1+T_MS2)/2;
  Tm_wall:=(Tm_MS+Tm_Na)/2;
  
  //Sodium properties
  state_mean_Na:=Medium1.setState_pTX(p_Na1, Tm_Na);
  state_input_Na:=Medium1.setState_pTX(p_Na1, T_Na1);
  state_output_Na:=Medium1.setState_pTX(p_Na1, T_Na2);
  rho_Na:=Medium1.density(state_mean_Na);
  cp_Na:=Medium1.specificHeatCapacityCp(state_mean_Na);
  mu_Na:=Medium1.dynamicViscosity(state_mean_Na);
  mu_Na_wall:=mu_Na;
  k_Na:=Medium1.thermalConductivity(state_mean_Na);
  h_Na1:=Medium1.specificEnthalpy(state_input_Na);
  h_Na2:=Medium1.specificEnthalpy(state_output_Na);
  s_Na1:=Medium1.specificEntropy(state_input_Na);
  s_Na2:=Medium1.specificEntropy(state_output_Na);
  
  //Chloride Salt properties
  state_mean_MS:=Medium2.setState_pTX(Medium2.p_default, Tm_MS);
  state_wall_MS:=Medium2.setState_pTX(Medium2.p_default, Tm_Na);
  state_input_MS:=Medium2.setState_pTX(p_Na1, T_MS1);
  state_output_MS:=Medium2.setState_pTX(p_Na1, T_MS2);
  rho_MS:=Medium2.density(state_mean_MS);
  cp_MS:=Medium2.specificHeatCapacityCp(state_mean_MS);
  mu_MS:=Medium2.dynamicViscosity(state_mean_MS);
  mu_MS_wall:=Medium2.dynamicViscosity(state_wall_MS);
  k_MS:=Medium2.thermalConductivity(state_mean_MS);
  h_MS1:=Medium2.specificEnthalpy(state_input_MS);
  h_MS2:=Medium2.specificEnthalpy(state_output_MS);
  s_MS1:=Medium2.specificEntropy(state_input_MS);
  s_MS2:=Medium2.specificEntropy(state_output_MS); 
  
  DT1:=T_Na1-T_MS2;
  DT2:=T_Na2-T_MS1;
  if abs(DT1-DT2)<1e-6 then
    LMTD:=DT1;
  else
    LMTD:=(DT1-DT2)/MA.log(DT1 / DT2);
  end if;
  m_flow_Na:=Q_d/(cp_Na*(T_Na1-T_Na2));
  m_flow_MS:=Q_d/(cp_MS*(T_MS2 - T_MS1));
  F:=1;
  UA:=Q_d/(F*LMTD);
  ex_eff:=(m_flow_MS*((h_MS2-h_MS1)-(25+273.15)*cp_MS*(MA.log(T_MS2/T_MS1))))/(m_flow_Na*((h_Na1-h_Na2)-(25+273.15)*cp_Na*(MA.log(T_Na1/T_Na2))));
  if (cp_Na*m_flow_Na)>(cp_MS*m_flow_MS) then
    en_eff:=(T_MS2-T_MS1)./(T_Na1-T_MS1);
  else
    en_eff:=(T_Na1-T_Na2)./(T_Na1-T_MS1);
  end if;
  
  U_calc_prev:=U_guess;
  condition:=10;
  
while noEvent(condition>tol) loop
  A_tot:=UA/U_calc_prev;
  N_t:=integer(ceil(A_tot/A_st));
  Tep:=integer(ceil(N_t/N_p));
  N_t:=Tep*N_p;
  (U_calc, h_s, h_t):=HTCs(d_o=d_o, N_p=N_p, N_sp=N_sp, layout=layout, N_t=N_t, state_mean_Na=state_mean_Na, state_mean_MS=state_mean_MS, state_wall_MS=state_wall_MS, m_flow_Na=m_flow_Na, m_flow_MS=m_flow_MS, L=L);
  condition:=abs(U_calc-U_calc_prev)/U_calc_prev;
  U_calc_prev:=U_calc;
end while;

  (Dp_tube, Dp_shell, v_Na, v_max_MS, N_baffles):=Dp_losses(d_o=d_o, N_p=N_p, N_sp=N_sp, layout=layout, N_t=N_t, L=L, state_mean_Na=state_mean_Na, state_mean_MS=state_mean_MS, state_wall_MS=state_wall_MS, m_flow_Na=m_flow_Na, m_flow_MS=m_flow_MS);
  
  //Shell Diameter
  if layout==1 then
    if N_p==1 then
      KK1:=0.215;
      nn1:=2.207;
    elseif N_p==2 then
      KK1:=0.156;
      nn1:=2.291;
    elseif N_p==4 then
      KK1:=0.158;
      nn1:=2.263;
    elseif N_p==6 then
      KK1:=0.0402;
      nn1:=2.617;
    elseif N_p==8 then
      KK1:=0.0331;
      nn1:=2.643;
    end if;
  else
    if N_p==1 then
      KK1:=0.319;
      nn1:=2.142;
    elseif N_p==2 then
      KK1:=0.249;
      nn1:=2.207;
    elseif N_p==4 then
      KK1:=0.175;
      nn1:=2.285;
    elseif N_p==6 then
      KK1:=0.0743;
      nn1:=2.499;
    elseif N_p==8 then
      KK1:=0.0365;
      nn1:=2.675;
    end if;
  end if;
  
  D_b:=(N_t/KK1)^(1/nn1)*d_o;
  L_bb:=(12+5*(D_b+d_o))/995;
  D_s:=L_bb+D_b+d_o;
  l_b:=D_s;
  t_baffle:=BaffleThickness(D_s=D_s,l_b=l_b);
  l_b:=L/(N_baffles/N_sp+1)-t_baffle;
  t_baffle:=BaffleThickness(D_s=D_s,l_b=l_b);
  l_b:=L/(N_baffles/N_sp+1)-t_baffle;  
  t_shell:=ShellThickness(D_s);
  D_s_out:=D_s+2*t_shell;
  V_ShellThickness:=(D_s_out^2-(D_s^2))*CN.pi/4*L;
  V_tubes:=CN.pi*(d_o^2-d_i^2)/4*L*N_t;
  V_baffles:=(CN.pi*D_s^2)/4*(1-B)*N_baffles*t_baffle+t_baffle*D_s*L*(N_sp-1);
  V_material:=V_ShellThickness+V_tubes+V_baffles;
  V_Na:=CN.pi/4*(d_i^2)*L*N_t;
  V_MS:=(D_s^2-(d_o^2)*N_t)*CN.pi/4*L-V_baffles;
  V_HX:=V_material+V_MS+V_Na;
  (k_wall, rho_wall):=Haynes230_BaseProperties(Tm_wall);
  m_Na:=V_Na*rho_Na;
  m_MS:=V_MS*rho_MS;
  m_material:=V_material*rho_wall;
  m_HX:=m_material+m_MS+m_Na;
  
  //Cost function
  P_shell:=p_MS1;
  P_tubes:=p_Na1;
  P_tube_cost:=(P_tubes/10^5)-1;
  P_shell_cost:=(P_shell/10^5)-1;
  if ((P_tube_cost>5 and P_shell_cost>5)or(P_tube_cost<5 and P_shell_cost>5)) then
    both:=true;
    P_cost:=max(P_tube_cost,P_shell_cost);
    else
    both:=false;
    P_cost:=P_tube_cost;
  end if;
  k1:=4.3247;
  k2:=-0.3030;
  k3:=0.1634;
  if both then
        C1:=0.03881;
        C2:=-0.11272;
        C3:=0.08183;
    else
    if P_cost<5 then
      C1:=0;
      C2:=0;
      C3:=0;
      else
        C1:=-0.00164;
        C2:=-0.00627;
        C3:=0.0123;
    end if;
  end if;
  Fp:=10^(C1+C2*log10(P_cost)+C3*(log10(P_cost))^2);
  Fm:=3.7;
  B1:=1.63;
  B2:=1.66;
  if noEvent(A_tot>1000) then
    A_cost:=1000;
    elseif noEvent(A_tot<10) then
    A_cost:=10;    
    else
    A_cost:=A_tot;    
  end if;
  
  C_p0:=10^(k1+k2*log10(A_cost)+k3*(log10(A_cost))^2);
  C_BM:=C_p0*(CEPCI_18/CEPCI_01)*(B1+B2*Fm*Fp);
  C_BEC_ref:=material_sc*m_material_HX_ref;
  C_BEC:=C_BEC_ref*(A_tot/A_ref)^0.8;

  
  C_pump:=c_e*H_y/eta_pump*(m_flow_MS*Dp_shell/rho_MS+m_flow_Na*Dp_tube/rho_Na)/(1000);
  f:=(r*(1+r)^n)/((1+r)^n-1);
  if (v_max_MS<0.49 or v_max_MS>1.51 or v_Na<0.99 or v_Na>3 or L/D_s>10) then
    TAC:=10e10;
  else
    if noEvent(C_BEC>0) and noEvent(C_pump>0) then
      TAC:=f*C_BEC+C_pump;
    else
      TAC:=10e10;
    end if;
  end if;
end Design_HX_noF;
