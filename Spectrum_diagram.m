% 时域信号存储在变量 signal 中
signal = sensor_data.p(1, :); % 在这里填入你的时域信号
sample_rate = 1 / kgrid.dt; % 设置采样频率

% 加汉宁窗后信号失真
% signal = signal - mean(signal);          % 去除直流分量    
% window = hann(length(signal));           % 汉宁窗
% signal_windowed = signal .* window;      % 加窗
    
% 进行傅里叶变换
freq_signal = fft(signal);

% 获取频率轴
n = length(signal);
f = (0:n-1) * (sample_rate / n); % 频率向量

% 幅度归一化
Y_magnitude = abs(freq_signal/n); 

% 绘制频谱
figure;
plot(f, Y_magnitude, 'LineWidth', 1,'Color', 'b');
xlabel('Frequency (Hz)','FontSize',10), ylabel('Magnitude','FontSize',10);
title('Frequency Spectrum');
xlim([0 sample_rate/2]); % 只显示正频率部分
grid on;