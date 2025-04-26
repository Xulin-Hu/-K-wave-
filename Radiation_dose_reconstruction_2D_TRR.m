% 2D Time Reversal Reconstruction For A Line Sensor Example
%
% This example demonstrates the use of k-Wave for the time-reversal
% reconstruction of a two-dimensional photoacoustic wave-field recorded
% over a linear array of sensor elements. The sensor data is simulated and
% then time-reversed using kspaceFirstOrder2D. It builds on the 2D FFT 
% Reconstruction For A Line Sensor Example. 
%
% author: Bradley Treeby
% date: 6th July 2009
% last update: 25th July 2019
%  
% This function is part of the k-Wave Toolbox (http://www.k-wave.org)
% Copyright (C) 2009-2019 Bradley Treeby

% This file is part of k-Wave. k-Wave is free software: you can
% redistribute it and/or modify it under the terms of the GNU Lesser
% General Public License as published by the Free Software Foundation,
% either version 3 of the License, or (at your option) any later version.
% 
% k-Wave is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
% more details. 
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave. If not, see <http://www.gnu.org/licenses/>. 

clearvars;
close all;

% =========================================================================
% SIMULATION
% =========================================================================
load('Acoustic_pressure.mat')
% create the computational grid
PML_size = 10;              % size of the PML in grid points
Nx = 140 - 2 * PML_size;    % number of grid points in the x direction
Ny = 140 - 2 * PML_size;    % number of grid points in the y direction
dx = 2.5e-3;                 % grid point spacing in the x direction [m]
dy = 2.5e-3;                % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% define the properties of the propagation medium
% medium.sound_speed = 1500;	% [m/s]
Water_density = 1000; % 水的密度 1000 kg /m3
Water_sound = 1500;    % 水的传播声速为 1500 m /s
% Water_thermal_expansion_coefficient = 210 * 1e-6; % 水的体积热膨胀系数为 210 * 1e-6
% Water_specific_heat_capacity = 4181; % 水的比热容 4181 J/( kg·K)

% Bone
Lead_density = 11343.7; % 密度 kg /m3
Lead_sound = 1960; % 传播声速为 m /s
% Lead_thermal_expansion_coefficient = 87 * 1e-6;% 体积热膨胀系数K-1
% Lead_specific_heat_capacity = 1300; % 比热容  J/(kg·K)

Density_matrix=ones(120, 120)*1000; % 定义一个维度为120*120的全1矩阵
Density_matrix(54:67,21:100)=Density_matrix(54:67,21:100)*11.3437;  % 铅杆区域密度为11.3437千克/立方米
medium.density = Density_matrix;

Sound_matrix=ones(120, 120)*1500; % 定义一个维度为120*120的全1矩阵
Sound_matrix(54:67,21:100)=(Sound_matrix(54:67,21:100)/1500)*1960;  % 铅杆区域声速为11.3437千克/立方米
medium.sound_speed = Sound_matrix;

% % % % % create initial pressure distribution using makeDisc
% % % % disc_magnitude = 5;         % [Pa]
% % % % disc_x_pos = 60;            % [grid points]
% % % % disc_y_pos = 140;           % [grid points]
% % % % disc_radius = 5;            % [grid points]
% % % % disc_2 = disc_magnitude * makeDisc(Nx, Ny, disc_x_pos, disc_y_pos, disc_radius);
% % % % 
% % % % disc_x_pos = 30;            % [grid points]
% % % % disc_y_pos = 110;           % [grid points]
% % % % disc_radius = 8;            % [grid points]
% % % % disc_1 = disc_magnitude * makeDisc(Nx, Ny, disc_x_pos, disc_y_pos, disc_radius);
% % % % 
% % % % % smooth the initial pressure distribution and restore the magnitude
% % % % p0 = smooth(disc_1 + disc_2, true);

% assign to the source structure
source.p0 = Acoustic_pressure;

% define a binary line sensor
sensor.mask = zeros(Nx, Ny);
sensor.mask(1, 1:120) = 1;  % 传感器数量 216个
% sensor.mask(1:120, 1) = 1;  % 传感器数量 216个
% sensor.mask(1:120, 120) = 1;  % 传感器数量 216个
% sensor.mask(120, 1:120) = 1;  % 传感器数量 216个


% create the time array
kgrid.makeTime(medium.sound_speed);

% set the input arguements: force the PML to be outside the computational
% grid; switch off p0 smoothing within kspaceFirstOrder2D
input_args = {'PMLInside', false, 'PMLSize', PML_size, 'Smooth', false, 'PlotPML', false};

% run the simulation
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

% reset the initial pressure
source.p0 = 0;

% assign the time reversal data
sensor.time_reversal_boundary_data = sensor_data;

% run the time reversal reconstruction
p0_recon = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

% add first order compensation for only recording over a half plane
p0_recon = 2 * p0_recon;

% % repeat the FFT reconstruction for comparison
% p_xy = kspaceLineRecon(sensor_data.', dy, kgrid.dt, medium.sound_speed, ...
%     'PosCond', true, 'Interp', '*linear');
% 
% % define a second k-space grid using the dimensions of p_xy
% [Nx_recon, Ny_recon] = size(p_xy);
% kgrid_recon = kWaveGrid(Nx_recon, kgrid.dt * medium.sound_speed, Ny_recon, dy);
% 
% % resample p_xy to be the same size as source.p0
% p_xy_rs = interp2(kgrid_recon.y, kgrid_recon.x - min(kgrid_recon.x(:)), p_xy, kgrid.y, kgrid.x - min(kgrid.x(:)));

% =========================================================================
% VISUALISATION
% =========================================================================

% plot the initial pressure and sensor distribution
figure;
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, Acoustic_pressure + sensor.mask*5,[-1, 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;
colorbar;
scaleFig(1, 0.65);

% plot the reconstructed initial pressure 
figure;
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, p0_recon,[-1, 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;
colorbar;
scaleFig(1, 0.65);

% apply a positivity condition
p0_recon(p0_recon < 0) = 0;

% plot the reconstructed initial pressure with positivity condition
figure;
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, p0_recon,[-1, 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;
colorbar;
scaleFig(1, 0.65);

% % plot a profile for comparison
% figure;
% plot(kgrid.y_vec * 1e3, source.p0(disc_x_pos, :), 'k-', ...
%      kgrid.y_vec * 1e3, p_xy_rs(disc_x_pos, :), 'r--', ...
%      kgrid.y_vec * 1e3, p0_recon(disc_x_pos, :), 'b:');
% xlabel('y-position [mm]');
% ylabel('Pressure');
% legend('Initial Pressure', 'FFT Reconstruction', 'Time Reversal');
% axis tight;
% set(gca, 'YLim', [0, 5.1]);