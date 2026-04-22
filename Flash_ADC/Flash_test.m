clc;
clear;
close all;

N=3;
fs=10e6;        % ADC采样率 (Hz)
ts=1/(fs);      % ADC的周期 (s)
Vref=1.2;       % ADC参考电压 (V)
LSB=Vref/(2^N); % LSB

Comp_offset = 1e-3;
Comp_noise = 1e-6 * randn(1);

Nsample=2^15;           % FFT点数
m=33331;               % 素数
Vfs=1.2;                % 输入信号摆幅 (V)
fin=m/Nsample*fs;       % 输入信号频率 (Hz)

t_sam=0:ts:(Nsample-1)*ts;
Vin=Vfs/2+Vfs/2*sin(2*pi*fin*t_sam);

[D] = Flash_Fun(N,Nsample,Vin,Vref,Comp_offset,Comp_noise);

Vout=D(1:Nsample).*Vref/2^N; % 归一化之后的输出

windowL=0; % 视窗左边界 (us)
windowR=2; % 视窗右边界 (us)

% 绘制输出复原后的电压波形
plot_Vout_Voltage(Vout,Nsample,ts,fin,windowL,windowR);
% 测试并绘制动态和静态特性
windowing = 0; % 是否加窗, 0=No, 1=hamming, 2=hann, 3=blackman-harris
[THD,SFDR,SNR,SNDR,ENOB]=Dynamic_test(D,fs,Nsample,windowing); % 动态性能测试
[DNLmax,DNLmin,INLmax,INLmin]=Static_test(D,N); % 静态性能测试