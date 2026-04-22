function[THD,SFDR,SNR,SNDR,ENOB]=Dynamic_test(Dout,fs,Nsample,windowing)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% 是否加窗 %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if  windowing == 0                           
    Dout = Dout - mean(Dout);
elseif  windowing==1
    Dout = Dout - mean(Dout);
    Dout = Dout.*window(@hamming,Nsample);         % 加汉明窗，并滤去直流
    Dout = Dout - mean(Dout); 
elseif  windowing==2
    Dout = Dout - mean(Dout);
    Dout = Dout.*window(@hann,Nsample);            % 加汉宁窗，并滤去直流
    Dout = Dout - mean(Dout); 
elseif  windowing==3
    Dout = Dout - mean(Dout);
    Dout = Dout.*window(@blackmanharris,Nsample);  % 加布莱克曼-哈里斯窗，并滤去直流
    Dout = Dout - mean(Dout); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% 动态特性测试 %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Amp_Spectrum_double = abs(fft(Dout',Nsample))/Nsample; %双边幅度谱
Amp_Spectrum_single = Amp_Spectrum_double(1:Nsample/2+1);
Amp_Spectrum_single(2:Nsample/2) = 2*Amp_Spectrum_single(2:Nsample/2);

Power_Spectrum_double = Amp_Spectrum_double.^2; % 双边功率谱
Power_Spectrum_single = Power_Spectrum_double(1:Nsample/2+1);
Power_Spectrum_single(2:Nsample/2) = 2*Power_Spectrum_single(2:Nsample/2);

Power_Spectrum_Density_double = Amp_Spectrum_double.^2 * Nsample/fs; % 双边功率谱密度
Power_Spectrum_Density_single = Power_Spectrum_Density_double(1:Nsample/2+1);
Power_Spectrum_Density_single(2:Nsample/2) = 2*Power_Spectrum_Density_single(2:Nsample/2);

dB_spectrum     = 10*log10(Power_Spectrum_single); % dB谱
max_dBc         = max(dB_spectrum); % 输入信号功率 (dB)

[~, bin]        = max(dB_spectrum(1:Nsample/2)); % 找到输入信号位置
signal_frequency= bin; 
signal_bin      = 0; % 将信号附近的旁瓣视作信号功率
harmonic_bin    = 1; % 将谐波附近的旁瓣视作谐波功率
start_power     = 1; % 忽略DC直流
signal_power    = sum(Power_Spectrum_single(bin-signal_bin:bin+signal_bin)); % 输入信号功率，包括旁瓣
total_power     = sum(Power_Spectrum_single(1:Nsample/2)); % 总功率

harmonic_indices = signal_frequency * (2:20); % 考虑到20次谐波

%%%%%%%%%%%%%%%%%%%% 找到谐波位置 %%%%%%%%%%%%%%%%%%%
for i = 1:length(harmonic_indices)
    if harmonic_indices(i) > Nsample / 2
        division_result = harmonic_indices(i) / (Nsample / 2);
        remainder_fs_2 = mod(harmonic_indices(i), Nsample / 2);

        if rem(division_result, 2) == 1 % 如果除以N/2是奇数，说明落在偶数区间
            if remainder_fs_2 == 0
                harmonic_indices(i) = Nsample / 2;
            else
                harmonic_indices(i) = Nsample / 2 - abs(remainder_fs_2 - Nsample / 2);
            end
        else % 如果除以N/2是偶数，说明落在奇数区间
            harmonic_indices(i) = remainder_fs_2;
        end
    end
    harmonic_indices(i)=harmonic_indices(i);
    harmonic_power_single(i)  = sum(Power_Spectrum_single(harmonic_indices(i)-harmonic_bin:harmonic_indices(i)+harmonic_bin));
end

harmonic_power  = sum(harmonic_power_single); % 计算总的谐波功率

%%%%%%%%%%%%%%%%%%%% 计算各项指标 %%%%%%%%%%%%%%%%%%%
THD             = 10*log10(harmonic_power/signal_power);
SNDR            = 10*log10(signal_power/(total_power-signal_power));
SNR             = 10*log10(signal_power/(total_power-signal_power-harmonic_power));
ENOB            = (SNDR-1.76)/6.02;
Dout_SFDR       = abs(dB_spectrum - dB_spectrum(bin));
Dout_SFDR       = Dout_SFDR(1:Nsample/2);
Dout_SFDR_1     = min(Dout_SFDR(start_power:(bin-signal_bin-1)));%除去输入信号及其旁瓣
Dout_SFDR_2     = min(Dout_SFDR((bin+signal_bin+1):Nsample/2));
SFDR            = min(Dout_SFDR_1,Dout_SFDR_2);

%%%%%%%%%%%%%%%%%%%% 绘出指标图形 %%%%%%%%%%%%%%%%%%%
fin=bin*fs/(1e3*Nsample); % 输入信号实际频率
fs=fs/1e3; % 将X轴设置为KHz单位
figure; 

Figure=plot((0:Nsample/2-1).*fs/Nsample,dB_spectrum(2:Nsample/2+1)-max_dBc,'k'); % 绘图
mindB=min(dB_spectrum(2:Nsample/2+1)-max_dBc); % 标准化Y轴
grid on;

zoom;

set(Figure,'LineWidth',2.5);
title(sprintf('fin = %3.2f KHz,  fs = %d KHz',fin,fs),'FontWeight','Bold','FontSize',20,'FontName','Arial');
xlabel('Frequency (KHz)','FontWeight','Bold','FontSize',20,'FontName','Arial');
ylabel('Power Spectrum(dB)','FontWeight','Bold','FontSize',20,'FontName','Arial');

xlim([0 fs/2]);
ylim([mindB 0]);

% 添加动态参数文本显示
text(fs/5,-25, ...
    sprintf(' ENOB = %3.2f bit\n SFDR = %3.2f dB\n SNR = %3.2f dB\n SNDR = %3.2f dB\n THD = %3.2f dB',...
        ENOB,SFDR,SNR,SNDR,THD),...
        'LineWidth',2,'FontSize',14, 'Margin',5, 'FontWeight','Bold', 'FontName','Arial');

set(gca,'FontSize',14, 'FontWeight','Bold', 'FontName','Arial', 'LineWidth',3);
set(gcf, 'Color','White', 'Unit','CentiMeters', 'Position', [10 5 18 14]);

    