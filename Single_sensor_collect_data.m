% Recording Particle Velocity Example
%
% This example demonstrates how to record the particle velocity using a
% Cartesian or binary sensor mask. It builds on the Homogeneous Propagation
% Medium and Heterogeneous Propagation Medium examples.  
%
% author: Bradley Treeby
% date: 1st November 2010
% last update: 3rd May 2017
%  
% This function is part of the k-Wave Toolbox (http://www.k-wave.org)
% Copyright (C) 2010-2017 Bradley Treeby

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
close all
% =========================================================================
% SIMULATION
% =========================================================================
load('Acoustic_pressure.mat')
% create the computational grid
% Nx = 120;           % number of grid points in the x (row) direction
% Ny = 120;           % number of grid points in the y (column) direction
PML_size = 10;              % size of the PML in grid points
Nx = 140 - 2 * PML_size;    % number of grid points in the x direction
Ny = 140 - 2 * PML_size;    % number of grid points in the y direction
dx = 2.5e-3;        % grid point spacing in the x direction [m]
dy = 2.5e-3;        % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% 材料密度、声速、比热容、体积热膨胀系数、格律乃森参数定义
% medium.sound_speed = 1500;  % [m/s]
% medium.density = 1000;      % [kg/m^3]

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


% create time array
t_end = 300e-6;       % [s]  % 声波时间设置——根据声波情况来
kgrid.makeTime(medium.sound_speed, [], t_end);

% create initial pressure distribution using makeDisc

source.p0 = Acoustic_pressure;

% % smooth the initial pressure distribution and restore the magnitude
% source.p0 = smooth(source.p0, true); 

% define four sensor points centered about source.p0
sensor_radius = 40; % [grid points]  10cm
sensor.mask = zeros(Nx, Ny);
sensor.mask(Nx/2 + sensor_radius, Ny/2) = 1; % 下
% sensor.mask(Nx/2 - sensor_radius, Ny/2) = 1; % 上
% sensor.mask(Nx/2, Ny/2 + sensor_radius) = 1; % 右
% sensor.mask(Nx/2, Ny/2 - sensor_radius) = 1; % 左

% set the acoustic variables that are recorded
sensor.record = {'p', 'u'};

% run the simulation
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor);

% =========================================================================
% VISUALISATION
% =========================================================================

% plot the initial pressure and sensor distribution
figure;
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, source.p0 + sensor.mask, [-1, 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;

% get a suitable scaling factor for the time array
[t, t_sc, t_prefix] = scaleSI(kgrid.t_array(end));

% set y-axis limits
p_lim = 1.1;  % 声压坐标
u_lim = 12e-7;  % 速度坐标

% plot the simulated sensor data
figure;

% plot the pressure
    plot(t_sc * kgrid.t_array, sensor_data.p(1, :), 'k-');
    set(gca, 'YLim', [-p_lim+0.5, p_lim], 'XLim', [0, t_end * t_sc]);
    xlabel(['Time [' t_prefix 's]']);
    ylabel('XA Signal Pressure');

% for sensor_num = 1:4
%     
%     plot the pressure
%     subplot(4, 3, 3 * sensor_num - 2);
%     plot(t_sc * kgrid.t_array, sensor_data.p(sensor_num, :), 'k-');
%     set(gca, 'YLim', [-p_lim, p_lim], 'XLim', [0, t_end * t_sc]);
%     xlabel(['Time [' t_prefix 's]']);
%     ylabel('p');    
% 
%     plot the particle velocity ux
%     subplot(4, 3, 3 * sensor_num - 1);
%     plot(t_sc * kgrid.t_array, sensor_data.ux(sensor_num, :), 'k-');
%     set(gca, 'YLim', [-u_lim, u_lim], 'XLim', [0, t_end * t_sc]);
%     xlabel(['Time [' t_prefix 's]']);
%     ylabel('ux'); 
% 
%     plot the particle velocity uz
%     subplot(4, 3, 3 * sensor_num);
%     plot(t_sc * kgrid.t_array, sensor_data.uy(sensor_num, :), 'k-');
%     set(gca, 'YLim', [-u_lim, u_lim], 'XLim', [0, t_end * t_sc]);
%     xlabel(['Time [' t_prefix 's]']);
%     ylabel('uy'); 
%     
% end
% scaleFig(1, 1.5);