function [D,Vdacp,Vdacn]=SAR_Func(N,num,Vref,Vin_p,Vin_n,k,T,Cp_tot,Cn_tot,Cp,Cn,Comp_offset,Comp_noise,Switch_Flag)

for j=1:1:num
    Vip = Vin_p(j);       
    Vin = Vin_n(j);

    Vip = Vip + sqrt(k*T/Cp_tot)*randn(1,1);
    Vin = Vin + sqrt(k*T/Cn_tot)*randn(1,1);

    if Switch_Flag == 1
        Vresp(1) = Vref - Vip;       
        Vresn(1) = Vref - Vin;
        Vip = Vref - Vip;       
        Vin = Vref - Vin;
    elseif Switch_Flag == 2 || Switch_Flag == 3
        Vresp(1) = Vip;
        Vresn(1) = Vin;
    end
    
    for i=1:N-1
        if Vip - Vin <= Comp_offset + Comp_noise*randn(1,1)
            if Switch_Flag == 1                                % Convention时序
                B(i) = 1;
                Vip = Vip + Vref/2*Cp(i)/Cp_tot; 
                Vin = Vin - Vref/2*Cn(i)/Cn_tot;
            elseif Switch_Flag == 2                            % Monotonic时序
                B(i) = 0;
                Vin = Vin - Vref*Cn(i)/Cn_tot;
            elseif Switch_Flag == 3                            % Vcm-Based时序
                B(i) = 0;
                Vip = Vip + Vref/2*Cp(i)/Cp_tot; 
                Vin = Vin - Vref/2*Cn(i)/Cn_tot;
            end
        else 
            if Switch_Flag == 1                                % Convention时序
                B(i) = 0;
                Vip = Vip - Vref/2*Cp(i)/Cp_tot; 
                Vin = Vin + Vref/2*Cn(i)/Cn_tot;
            elseif Switch_Flag == 2                                % Monotonic时序
                B(i) = 1;
                Vip = Vip - Vref*Cp(i)/Cp_tot;
            elseif Switch_Flag == 3                            % Vcm-Based时序
                B(i) = 1;
                Vip = Vip - Vref/2*Cp(i)/Cp_tot; 
                Vin = Vin + Vref/2*Cn(i)/Cn_tot;
            end
        end
        Vresp(i+1) = Vip;
        Vresn(i+1) = Vin;
    end
    
    if Vip - Vin <= Comp_offset + Comp_noise*randn(1,1)
        if Switch_Flag == 1
            B(N) = 1;
        else
            B(N) = 0;
        end
    else
        if Switch_Flag == 1
            B(N) = 0;
        else
            B(N) = 1;
        end
    end
    Vresp(N+1) = Vip;
    Vresn(N+1) = Vin;

    D(j,:)=B;               % ADC的数字码输出
    Vdacp(j,:)=Vresp;       % ADC的正端CDAC上的余差电压
    Vdacn(j,:)=Vresn;       % ADC的负端CDAC上的余差电压
end

