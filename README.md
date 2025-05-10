# X-ray-induced acoustic imaging
利用蒙特卡罗+K-wave toolbox仿真X射线激发电离辐射声信号，并通过设置传感器采集电离辐射声信号
1. certain_plane.txt为来自蒙特卡罗仿真的能量沉积数据，需要转换为剂量数据
2. plot_radiation_distribution.m为通过能量沉积数据计算得到平面中的剂量，以及诱导产生的超声信号数据
3. Single_sensor_collect_data.m的功能是通过K-wave toolbox设置单个传感器，以检查传感器记录到的超声信号时域波形
4. 
