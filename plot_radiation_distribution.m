clear all;
close all
clc;

% Energy-deposition distribution
A=load('F:\��ʿ�����о�\��������-������ά������ģ\X����������ֵ����\MC Simulation\Geant4 data\������800000000(���3.5cm)\certain_plane.txt');

% Dose distribution
Density_matrix=ones(120, 120)*1000; % ����һ��ά��Ϊ120*120��ȫ1����
Density_matrix(54:67,21:100)=Density_matrix(54:67,21:100)*11.3437;  % Ǧ�������ܶ�Ϊ11.3437ǧ��/������
Dose =(A*1.6021892*1e-13)./(Density_matrix*0.0025*0.0025*0.0025);% ��������ֲ����(Gy)

% Dose-XA signal relation
Water_density = 1000; % ˮ���ܶ� 1000 kg /m3
Water_sound = 1500;    % ˮ�Ĵ�������Ϊ 1500 m /s
Water_thermal_expansion_coefficient = 210 * 1e-6; % ˮ�����������ϵ��Ϊ 210 * 1e-6
Water_specific_heat_capacity = 4181; % ˮ�ı����� 4181 J/( kg��K)

Lead_density = 11.3437*1e3; % Ǧ���ܶ� 11.3437 g /cm3
Lead_sound = 1960; % Ǧ�Ĵ�������Ϊ 1960 m /s
Lead_thermal_expansion_coefficient = 87 * 1e-6;% Ǧ�����������ϵ��Ϊ 87 �� e-6,����������ϵ��Ϊ29 ��  e-6
Lead_specific_heat_capacity = 127; % Ǧ�ı����� 127 J/( kg��K)

Water_Gruneisen_coefficient = Water_sound*Water_sound*Water_thermal_expansion_coefficient/Water_specific_heat_capacity; % ������ɭ����
Lead_Gruneisen_coefficient = Lead_sound*Lead_sound*Lead_thermal_expansion_coefficient/Lead_specific_heat_capacity; % ������ɭ����

Acoustic_pressure = ones(120, 120)*Water_Gruneisen_coefficient; % ����һ��ά��Ϊ120*120��ȫ1����
Acoustic_pressure(54:67,21:100) = Lead_Gruneisen_coefficient;  % Ǧ�������ܶ�Ϊ11.3437ǧ��/������
Acoustic_pressure = Acoustic_pressure.* Density_matrix.* Dose; % ��ѹ�ֲ����

% C = B(21:100,21:100); % ȡ�����м�����ݣ�10cm x 10cm
% B = reshape(B,[100,80]);B=B'; % ��ת��Ϊ���󣬶�Ӧĳһ�߶ȵ�2D��������
% C = B*1.6021892*1e-13*1e6*3600/(1.29*0.10*0.10*0.10);%(��λ��Gy/h)

figure % Energy-deposition distribution
imagesc(A);
colormap(parula);  % parula��hot
colorbar;  % ɫ��
set(gca,'xtick',0:10:120)
set(gca,'ytick',0:10:120)
set(gca,'XTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); % FontSize=25
set(gca,'YTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); %

xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10);
h=colorbar;
set(get(h,'Title'),'string','MeV'); % ��λ

figure % 2D Dose-deposition distribution
imagesc(Dose);
colormap(parula);  % parula��hot
colorbar;  % ɫ��
set(gca,'xtick',0:10:120)
set(gca,'ytick',0:10:120)
set(gca,'XTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); % FontSize=25
set(gca,'YTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); %

xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10);
h=colorbar;
set(get(h,'Title'),'string','Gy'); % ��λ

% figure % 3D Dose-deposition distribution
% surfc(Dose)
% xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10),zlabel('Z (Dose deposition)','FontSize',10);
% h=colorbar;
% set(get(h,'Title'),'string','Gy'); % ��λ

figure % 2D Pression distribution
imagesc(Acoustic_pressure);
colormap(parula);  % parula��hot
colorbar;  %ɫ��
set(gca,'xtick',0:10:120)
set(gca,'ytick',0:10:120)

set(gca,'XTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); % FontSize=25
set(gca,'YTickLabel',{'120','10','20','30','40','50','60','70','80','90','100','110'},'FontSize',10); %25

xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10);
% caxis([0 max(max(C))]) 
h=colorbar;
set(get(h,'Title'),'string','Pa'); % ��λ

figure % 3D Pression distribution
surfc(Acoustic_pressure)
xlabel('X (Grid)','FontSize',10), ylabel('Y (Grid)','FontSize',10),zlabel('Z (XA signal pressure)','FontSize',10);
h=colorbar;
set(get(h,'Title'),'string','Pa'); % ��λ

save('Acoustic_pressure','Acoustic_pressure')