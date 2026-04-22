function [D,Vdacp,Vdacn]=SAR_FUN(N,num,Vref,Vin_p,Vin_n,k,T,C_tot_p,C_tot_n,C_act_p,C_act_n,Comp_offset,Comp_noise)

for j=1:num % 使用for循环来实现周期工作过程
    Vip=Vin_p(j); % 正输入端电压，单次
    Vin=Vin_n(j); % 负输入端电压，单次

    Vip=Vip+sqrt(k*T/C_tot_p)*randn(1,1);
    Vin=Vin+sqrt(k*T/C_tot_n)*randn(1,1);

    Vresp(1)=Vip;
    Vresn(1)=Vin;

    for i=1:N-1
        if Vip-Vin<=Comp_offset+Comp_noise*randn(1,1)
            B(i)=0;

            Vip=Vip+Vref/2*C_act_p(i)/C_tot_p; % Vcm-Based时序
            Vin=Vin-Vref/2*C_act_n(i)/C_tot_n;
            % Vip=Vip+Vref*C_act_p(i)/C_tot_p; % Monotonic时序
            % Vin=Vin-Vref*C_act_n(i)/C_tot_n;
            Vresp(i+1)=Vip;
            Vresn(i+1)=Vin;
        else
            B(i)=1;

            Vip=Vip-Vref/2*C_act_p(i)/C_tot_p; % Vcm-Based时序
            Vin=Vin+Vref/2*C_act_n(i)/C_tot_n;
            % Vip=Vip-Vref*C_act_p(i)/C_tot_p; % Monotonic时序
            % Vin=Vin+Vref*C_act_n(i)/C_tot_n;
            Vresp(i+1)=Vip;
            Vresn(i+1)=Vin;
        end
    end
    
    if Vip-Vin<=Comp_offset+Comp_noise*randn(1,1)
        B(N)=0;
        Vresp(N+1)=Vip;
        Vresn(N+1)=Vin;
    else
        B(N)=1;
        Vresp(N+1)=Vip;
        Vresn(N+1)=Vin;
    end

    D(j,:)=B; % ADC的数字码输出
    Vdacp(j,:)=Vresp; % ADC的正端CDAC上的余差电压
    Vdacn(j,:)=Vresn; % ADC的负端CDAC上的余差电压
end

