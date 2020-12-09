within SolarTherm.Utilities;

//******************* This calculator is to calculate the inner tower diameter such that the height of the bins + 30 m (assumed height needed to host the PB = 1/2 of the tower height

model TowerInnerDiameterCalculator_IntegratedG3P3Storage

parameter SI.Density rho_particle = 2153 "kg/m^3";
Real tan_30 = sqrt(3)/3;
Real tan_313 = 0.6080095302; 

import SI = Modelica.SIunits;

parameter SI.Power P_gross = 100e6 / 0.9 "Size of the PB";
parameter SI.Length H_tower = 200 "Height of the tower [m]";
parameter SI.Length Th_refractory = 0.6 "Insulation thickness [m]";
parameter SI.Mass m_max = 30e6 "Mass of the particles that must be hosted by the storage [kg]";
parameter SI.Length D_outlet = 0.21 "Manifold of the particle [m]";
parameter SI.Length PB_space_reference = 30 "Space inside the tower integrated-storage to host PB. We assume that 111.111 MWe needs 30 m, and scale proportionally [m]";
parameter SI.Efficiency packing_factor = 0.6 "Packing factor of the bulk particle";

Real pi = 3.1415926536;

SI.Length D_inner_tower(min=0,start=25,nominal=25);
SI.Volume V_bin;
SI.Length H_bin;
SI.Length D_bin(min=0,start=25,nominal=25);
SI.Length PB_space;
SI.Length monolithic_height "Bin heights + PB space";
SI.Length H_conical_main = tan_30 * (D_bin/2);
SI.Length H_conical_truncated = tan_30 * D_outlet/2;

equation
D_bin = D_inner_tower - Th_refractory * 2;
V_bin = (m_max/rho_particle) * packing_factor;

V_bin = pi * (D_bin/2)^2 * H_bin + 2 * pi * (D_bin/2)^2 * H_conical_main/3 - 2 * pi * (D_outlet/2)^2 * H_conical_truncated;

PB_space = PB_space_reference * P_gross / (100e6/0.9);

monolithic_height = H_bin + (H_conical_main-H_conical_truncated) * 2 + H_bin  + (H_conical_main - H_conical_truncated)  +  PB_space;

monolithic_height = 0.5 * H_tower;

end TowerInnerDiameterCalculator_IntegratedG3P3Storage;
