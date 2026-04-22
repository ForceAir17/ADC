
        
            %% 
clear;
clc;

% initial parameters
n=10;
c_unit=1;
v_ref=1;

% preallocating
energy_conv=zeros(1,2^n);
energy_saving=zeros(1,2^n);
energy_mono=zeros(1,2^n);
energy_vcm=zeros(1,2^n);

% calculating
for x=0:(2^n-1)
    b=decimal2binary(x,n);
    energy_conv(x+1)=energy_calculate_conv(b,n,c_unit,v_ref);
    energy_saving(x+1)=energy_calculate_saving(b,n,c_unit,v_ref);
    energy_mono(x+1)=energy_calculate_mono(b,n,c_unit,v_ref);
    energy_vcm(x+1)=energy_calculate_vcm(b,n,c_unit,v_ref);
end
energy_avg_conv=sum(energy_conv)/2^n;
energy_avg_saving=sum(energy_saving)/2^n;
energy_avg_mono=sum(energy_mono)/2^n;
energy_avg_vcm=sum(energy_vcm)/2^n;

% plot
hold on;
plot(0:(2^n-1),energy_conv,'k-s','MarkerIndices',1:32:2^n);
plot(0:(2^n-1),energy_saving,'r-x','MarkerIndices',1:32:2^n);
plot(0:(2^n-1),energy_mono,'b-^','MarkerIndices',1:32:2^n);
plot(0:(2^n-1),energy_vcm,'c-v','MarkerIndices',1:32:2^n);
hold off;

% note
title('\fontname{Times New Roman}Switching Procedure Comparision');
xlabel('\fontname{Times New Roman}Output Code');
ylabel('\fontname{Times New Roman}Switching Energy [CV^2_{ref}]');
legend('Conventional','Energy-saving','Monotonic','Vcm-based');
set(gcf,'color','white');
set(gca,'FontSize',12);
set(gca,'FontName','Times New Roman');
set(gca,'XLim',[0 2^n-1]);
set(gca,'YLim',[0 max(energy_conv)]);
grid off;
box off;


%%%%%%%%%%%%%%%%%%%%%%%%% fucntion defination %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to convert decimal to binary
function convert_result=decimal2binary(d,n)
    % initial parameters
    binary=zeros(1,n);
    i=n;
    
    % judge
    while i~=0
        if d<2^(i-1)
            binary(n-i+1)=0;
        else
            binary(n-i+1)=1;
            d=d-2^(i-1);
        end
        i=i-1;
    end
    
    % result
    convert_result=binary;
end

% function to calculate conventional method of an arbitrary code
function energy_result=energy_calculate_conv(b,n,c_unit,v_ref)
    % initial parameters
    energy_1=2^(n-1)*c_unit*v_ref^2;
    
    % preallocating
    block_1=zeros(1,n);
    block_2=zeros(1,n);
    energy_step=zeros(1,n);
    
    % circle
    for i=2:n
        a=zeros(1,n);
        for k=1:(i-1)
            a(k)=(1-2*b(k))*2^(n-k)*(2*b(i-1)-1)/2^i;
        end
        block_1(i)=sum(a);
        block_2(i)=2^(n-i)*(3-2*b(i-1));
        energy_step(i)=block_1(i)+block_2(i);
        energy_sum=sum(energy_step);
    end
    
    % result
    energy_result=energy_sum*c_unit*v_ref^2+energy_1;
end

% function to calculate energy-saving method of an arbitrary code
function energy_result=energy_calculate_saving(b,n,c_unit,v_ref)
    % preallocating
    block_1=zeros(1,n);
    block_2=zeros(1,n);
    energy_step=zeros(1,n);
    
    % circle
    for i=3:n
        a=zeros(1,n);
        for k=1:(i-1)
            a(k)=-1/2^(i-1)*(1-2*b(i-1))*2^(n-k-1)*(1-2*b(k));
        end
        block_1(i)=sum(a);
        block_2(i)=2^(n-i);
        energy_step(i)=block_1(i)+block_2(i);
        energy_sum=sum(energy_step);
    end
    
    % result
    energy_result=(energy_sum+3*2^(n-3))*c_unit*v_ref^2;
end

% function to calculate monotonic method of an arbitrary code
function energy_result=energy_calculate_mono(b,n,c_unit,v_ref)
    % preallocating
    block_1=zeros(1,n);
    block_2=zeros(1,n);
    energy_step=zeros(1,n);
    
    % circle
    for i=2:n
        a=zeros(1,n);
        for k=1:(i-1)
            a(k)=1/2^(i-1)*2^(n-k-1)*b(k)+1/2^(i-1)*b(i-1)*2^(n-k-1)*(1-2*b(k));
        end
        block_1(i)=sum(a);
        block_2(i)=2^(n-2*i+1);
        energy_step(i)=block_1(i)+block_2(i);
        energy_sum=sum(energy_step);
    end
    
    % result
    energy_result=energy_sum*c_unit*v_ref^2;
end

% function to calculate vcm-baesd method of an arbitrary code
function energy_result=energy_calculate_vcm(b,n,c_unit,v_ref)
    % preallocating
    block_1=zeros(1,n);
    block_2=zeros(1,n);
    energy_step=zeros(1,n);
    
    % circle
    for i=2:n
        a=zeros(1,n);
        for k=1:(i-1)
            a(k)=1/2^(i-1)*(2^(n-k-1)*(b(k)-0.5)+b(i-1)*2^(n-k-1)*(1-2*b(k)));
        end
        block_1(i)=sum(a);
        block_2(i)=2^(n-i-1);
        energy_step(i)=block_1(i)+block_2(i);
        energy_sum=sum(energy_step);
    end
    
    % result
    energy_result=energy_sum*c_unit*v_ref^2;
end
%%
        
    