clc;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% 定义ADC的基本参数 %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=10;           % ADC分辨率 (Bit)
fs=10e6;        % ADC采样率 (Hz)
ts=1/(fs);      % ADC的周期 (s)
Vref=1.2;       % ADC参考电压 (V)
LSB=Vref/(2^N); % LSB
n_ch=1;         % ADC通道数, 可以是2,4,6,8 ... 等通道数

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% 定义环境参数 %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k=1.38e-23;     % 玻尔兹曼常数
T=300;          % 温度 (K)
Jitter=0e-15;   % 时钟抖动 (s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% 定义通道间失配参数 %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Mis_OS=0*LSB*randn(1,n_ch);         % 失调失配
Mis_Gain=1+0*LSB*randn(1,n_ch);     % 增益失配
Mis_TS=normrnd(0,0.00*ts,[1,n_ch]); % 时钟偏差

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% 定义子级SAR ADC参数 %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fs_sub=fs/n_ch;         % Sub-ADC 采样率 (Hz)
ts_sub=1/(fs_sub);      % Sub-ADC周期 (s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% 定义输入信号参数 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nsample=2^15;            % FFT点数
m=133111;               % 素数
num=Nsample;            % 采样点数
Vfs=1.2;                % 输入信号摆幅 (V)
fin=m/Nsample*fs;       % 输入信号频率 (Hz)

for number=1:n_ch % 不同通道的采样序列
    t(number,:)=[ts*number:ts_sub:floor(num/n_ch)*ts_sub]+Mis_TS(number).*ones(1,floor(num/n_ch))+Jitter.*rand(1,floor(num/n_ch));
    t_sam=t(number,:);
    Vin_pp(number,:)=Vref/2+Mis_OS(number)+Mis_Gain(number).*(Vfs/2)*sin(2*pi*fin*t_sam);   % 正端采样
    Vin_nn(number,:)=Vref/2-Mis_Gain(number).*(Vfs/2)*sin(2*pi*fin*t_sam);                  % 负端采样
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% 定义ADC的电容阵列参数 %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cu=1e-15;                                       % ADC的单位电容(F)
sigma_Cu=00;
C_mismatch=sigma_Cu*Cu;                          % ADC的电容失配(%)
C_arr_p=[2.^[(N-2):-1:0],1];                    % 电容阵列正极板，CDAC_P
C_arr_n=[2.^[(N-2):-1:0],1];                    % 电容阵列负极板，CDAC_N
C_dev_p=C_mismatch*sqrt(C_arr_p).*randn(1,N);   % 正极板电容失配
C_dev_n=C_mismatch*sqrt(C_arr_n).*randn(1,N);   % 负极板电容失配
Cp_p=0e-15;                                     % 正极板寄生电容
Cp_n=0e-15;                                     % 负极板寄生电容
C_act_p=C_arr_p.*Cu+C_dev_p;                    % 电容阵列正极板，考虑电容失配
C_act_n=C_arr_n.*Cu+C_dev_n;                    % 电容阵列负极板，考虑电容失配
C_tot_p=sum(C_act_p)+Cp_p;                      % 正极板总电容大小，考虑寄生电容
C_tot_n=sum(C_act_n)+Cp_n;                      % 负极板总电容大小，考虑寄生电容

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% 定义比较器参数 %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Comp_offset = 0;                               % 比较器失调电压 (V)
Comp_noise  = 0;                               % 比较器噪声电压 (V)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% ADC的工作过程 %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for number=1:n_ch
    Vin_p=Vin_pp(number,:);
    Vin_n=Vin_nn(number,:);

    % 将SAR ADC的工作工程封装为函数，命名为SAR_FUN，并调用
    [D,Vdacp,Vdacn]=SAR_FUN(N,num/n_ch,Vref,Vin_p,Vin_n,k,T,C_tot_p,C_tot_n,C_act_p,C_act_n,Comp_offset,Comp_noise);

    Vresn(number,:,:)=Vdacp;
    Vresp(number,:,:)=Vdacn;
    D_ch(number,:,:)=D; % 单通道的数字码
    Dout_ch(number,:)=D*2.^[(N-1):-1:0]'; % 单通道的数字码经过理想DAC复原之后的输出
end

%%%%%%%%%%%%%%%%%%%%%%% MUX %%%%%%%%%%%%%%%%%%%%%%%%
for number=1:n_ch
    for j=1:floor(num/n_ch)
        Dout(n_ch*j-n_ch+number) = Dout_ch(number,j); % 数字码经过理想DAC复原之后的输出
    end
end
Vout=Dout(1:Nsample).*Vref/2^N; % 归一化之后的输出

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% ADC的测试与绘图 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 绘制CDAC余差电压波形
windowL_DAC=0; % 视窗左边界 (us)
windowR_DAC=2; % 视窗右边界 (us)
cellArrayp = mat2cell(Vresp,ones(1,size(Vresp,1)),size(Vresp,2),size(Vresp,3));
cellArrayn = mat2cell(Vresn,ones(1,size(Vresn,1)),size(Vresn,2),size(Vresn,3));
X = 1; % 第X个通道
VresP = reshape(cellArrayp{X},size(Vresp,2),size(Vresp,3));
VresN = reshape(cellArrayn{X},size(Vresp,2),size(Vresp,3));
VresPP = (Vref/2).*ones(num,N+1);
VresNN = (Vref/2).*ones(num,N+1);
for j=1:floor(num/n_ch)
     VresPP(n_ch*j-n_ch+X,:) = VresP(j,:);
     VresNN(n_ch*j-n_ch+X,:) = VresN(j,:);
end
[vector_Vresp,vector_Vresn]=plot_CDAC_Voltage(VresPP,VresNN,N,size(VresPP,1),fs_sub,windowL_DAC,windowR_DAC,X);

% 绘制输出复原后的电压波形
windowL_OUT=0; % 视窗左边界 (us)
windowR_OUT=2; % 视窗右边界 (us)
plot_Vout_Voltage(Vout,Nsample,fs,windowL_OUT,windowR_OUT,fin);

% 测试并绘制动态和静态特性
En_plot = 1; % 是否绘图, 0=No, 1=Yes
wid = 0; % 是否加窗, 0=No, 1=hamming, 2=hann
[THD,SFDR,SNR,SNDR,ENOB]=Dynamic_test(Dout',fs,Nsample,En_plot,wid); % 动态性能测试
[DNLmax,DNLmin,INLmax,INLmin]=Static_test(Dout',N); % 静态性能测试

