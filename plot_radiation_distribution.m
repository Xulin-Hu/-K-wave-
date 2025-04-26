clear all;
close all
clc;

% Energy-deposition distribution
A=load('F:\热声成像-人体三维剂量建模\X光声成像数值仿真\MC Simulation\Geant4 data\粒子数800000000(宽度3.5cm)\certain_plane.txt'); % 换成自己的文件夹路径!!!!

% Dose distribution
Density_matrix=ones(120, 120)*1000; % 定义一个维度为120*120的全1矩阵
Density_matrix(54:67,21:100)=Density_matrix(54:67,21:100)*11.3437;  % 铅杆区域密度为11.3437千克/立方米
Dose =(A*1.6021892*1e-13)./(Density_matrix*0.0025*0.0025*0.0025);% 区域剂量分布情况(Gy)

% Dose-XA signal relation
Water_density = 1000; % 水的密度 1000 kg /m3
Water_sound = 1500;    % 水的传播声速为 1500 m /s
Water_thermal_expansion_coefficient = 210 * 1e-6; % 水的体积热膨胀系数为 210 * 1e-6
Water_specific_heat_capacity = 4181; % 水的比热容 4181 J/( kg·K)

Lead_density = 11.3437*1e3; % 铅的密度 11.3437 g /cm3
Lead_sound = 1960; % 铅的传播声速为 1960 m /s
Lead_thermal_expansion_coefficient = 87 * 1e-6;% 铅的体积热膨胀系数为 87 × e-6,线性热膨胀系数为29 ×  e-6
Lead_specific_heat_capacity = 127; % 铅的比热容 127 J/( kg·K)

Water_Gruneisen_coefficient = Water_sound*Water_sound*Water_thermal_expansion_coefficient/Water_specific_heat_capacity; % 格律乃森常数
Lead_Gruneisen_coefficient = Lead_sound*Lead_sound*Lead_thermal_expansion_coefficient/Lead_specific_heat_capacity; % 格律乃森常数

Acoustic_pressure = ones(120, 120)*Water_Gruneisen_coefficient; % 定义一个维度为120*120的全1矩阵
Acoustic_pressure(54:67,21:100) = Lead_Gruneisen_coefficient;  % 铅杆区域密度为11.3437千克/立方米
Acoustic_pressure = Acoustic_pressure.* Density_matrix.* Dose; % 声压分布情况

% C = B(21:100,21:100); % 取矩阵中间的数据，10cm x 10cm
% B = reshape(B,[100,80]);B=B'; % 行转换为矩阵，对应某一高度的2D辐射数据
% C = B*1.6021892*1e-13*1e6*3600/(1.29*0.10*0.10*0.10);%(单位μGy/h)

figure % Energy-deposition distribution
imagesc(A);
colormap(parula);  % parula、hot
colorbar;  % 色阶
set(gca,'xtick',0:10:120)
set(gca,'ytick',0:10:120)
set(gca,'XTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); % FontSize=25
set(gca,'YTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); %

xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10);
h=colorbar;
set(get(h,'Title'),'string','MeV'); % 单位

figure % 2D Dose-deposition distribution
imagesc(Dose);
colormap(parula);  % parula、hot
colorbar;  % 色阶
set(gca,'xtick',0:10:120)
set(gca,'ytick',0:10:120)
set(gca,'XTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); % FontSize=25
set(gca,'YTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); %

xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10);
h=colorbar;
set(get(h,'Title'),'string','Gy'); % 单位

% figure % 3D Dose-deposition distribution
% surfc(Dose)
% xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10),zlabel('Z (Dose deposition)','FontSize',10);
% h=colorbar;
% set(get(h,'Title'),'string','Gy'); % 单位

figure % 2D Pression distribution
imagesc(Acoustic_pressure);
colormap(parula);  % parula、hot
colorbar;  %色阶
set(gca,'xtick',0:10:120)
set(gca,'ytick',0:10:120)

set(gca,'XTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); % FontSize=25
set(gca,'YTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); %25

xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10);
% caxis([0 max(max(C))]) 
h=colorbar;
set(get(h,'Title'),'string','Pa'); % 单位

figure % 3D Pression distribution
surfc(Acoustic_pressure)
xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10),zlabel('Z (XA signal pressure)','FontSize',10);
h=colorbar;
set(get(h,'Title'),'string','Pa'); % 单位

save('Acoustic_pressure','Acoustic_pressure')
