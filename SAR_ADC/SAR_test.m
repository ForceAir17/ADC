clc;
clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% 定义ADC的基本参数 %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 14;           % ADC分辨率 (Bit)
fs = 200e3;       % ADC采样率 (Hz)
ts = 1/(fs);      % ADC的周期 (s)
Vref = 1.8;       % ADC参考电压 (V)
LSB = 2*Vref/(2^N); % LSB

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% 定义环境参数 %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k = 1.38e-23;     % 玻尔兹曼常数
T = 300;          % 温度 (K)
Jitter = 0e-15;   % 时钟抖动 (s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% 定义输入信号参数 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nsample = 1024;           % FFT点数
M = 147;                 % 素数
Vfs = 1.8;                % 输入信号摆幅 (V)
fin = M/Nsample*fs;       % 输入信号频率 (Hz)

t_sam = 0:ts:(Nsample-1)*ts;
Vin_p = Vref/2 + (Vfs/2)*sin(2*pi*fin*t_sam);   % 正端采样
Vin_n = Vref/2 - (Vfs/2)*sin(2*pi*fin*t_sam);   % 负端采样

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% 定义ADC的电容开关切换策略 %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Switch_Flag = 3;                     %传统开关策略:1、Monotonic:2、VCM Based：3
Mismatch_Flag = 0;                   %无失配：0、失配：1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% 定义ADC的电容阵列参数 %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cu = 4e-15;                                       % ADC的单位电容(F)
Sigma_Cu = 0.11;
Cu_mismatch = Cu * Sigma_Cu;

if Switch_Flag == 1
    Cp_ideal = [2.^((N-1):-1:0),1].*Cu;            % 电容阵列正极板(N个可切换开关电容+1个Dummy)
    Cn_ideal = [2.^((N-1):-1:0),1].*Cu;            % 电容阵列负极板
    Cp_actual = Cp_ideal + sqrt([2.^((N-1):-1:0),1])*Cu_mismatch.*randn(1,N+1);
    Cn_actual = Cn_ideal + sqrt([2.^((N-1):-1:0),1])*Cu_mismatch.*randn(1,N+1);
elseif Switch_Flag == 2 || Switch_Flag == 3
    Cp_ideal = [2.^((N-2):-1:0),1].*Cu;            % 电容阵列正极板(N-1个可切换开关电容+1个Dummy)
    Cn_ideal = [2.^((N-2):-1:0),1].*Cu;            % 电容阵列负极板
    Cp_actual = Cp_ideal + sqrt([2.^((N-2):-1:0),1])*Cu_mismatch.*randn(1,N);
    Cn_actual = Cn_ideal + sqrt([2.^((N-2):-1:0),1])*Cu_mismatch.*randn(1,N);
end

if Mismatch_Flag == 0
    Cp = Cp_ideal;
    Cn = Cn_ideal;
else
    Cp = Cp_actual;
    Cn = Cn_actual;
end

Cp_tot = sum(Cp);                           % 正极板总电容大小
Cn_tot = sum(Cn);                           % 负极板总电容大小

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% 定义比较器参数 %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Comp_offset = 80e-6;                        % 比较器失调电压 (V)
Comp_noise  = 100e-6;                       % 比较器噪声电压 (V)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% ADC的工作过程 %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[D,Vdacp,Vdacn]=SAR_Func(N,Nsample,Vref,Vin_p,Vin_n,k,T,Cp_tot,Cn_tot, ...
    Cp,Cn,Comp_offset,Comp_noise,Switch_Flag);


Vresp(:,:)=Vdacp;
Vresn(:,:)=Vdacn;
Dout=D*2.^((N-1):-1:0)';     



Vout=Dout(1:Nsample).*Vref/2^N; % 归一化之后的输出

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% ADC的测试与绘图 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
windowL=0; % 视窗左边界 (us)
windowR=100; % 视窗右边界 (us)

% 绘制CDAC余差电压波形
plot_CDAC_Voltage(Vresp,Vresn,N,size(Vresp,1),ts,windowL,windowR);

% 绘制输出复原后的电压波形
plot_Vout_Voltage(Vout,Nsample,Vfs,ts,fin,windowL,windowR);

% 测试并绘制动态和静态特性
windowing = 0; % 是否加窗, 0=No, 1=hamming, 2=hann, 3=blackman-harris
[THD,SFDR,SNR,SNDR,ENOB]=Dynamic_test(Dout',fs,Nsample,windowing); % 动态性能测试
[DNLmax,DNLmin,INLmax,INLmin]=Static_test(Dout',N); % 静态性能测试

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% ADC的参数打印 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('ENOB=%.2f\nSNDR=%.2f\nSFDR=%.2f\nTHD=%.2f\n',ENOB,SNDR,SFDR,THD);
fprintf('DNLmax=%.2f\nDNLmin=%.2f\nINLmax=%.2f\nINLmin=%.2f\n',DNLmax,DNLmin,INLmax,INLmin);

