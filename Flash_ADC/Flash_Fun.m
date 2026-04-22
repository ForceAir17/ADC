function [D] = Flash_Fun(N,Nsample,Vin,Vref,Comp_offset,Comp_noise)

for j=1:1:Nsample
    for i=2^N-1:-1:1
        if Vin(j) - i/2^N*Vref > Comp_offset + Comp_noise
            T(j,i) = 1;
        else
            T(j,i) = 0;
        end
    end

    B(j,1) = T(j,7) + (1-T(j,7))*(1-T(j,6))*T(j,5) + (1-T(j,5))*(1-T(j,4))*T(j,3) + (1-T(j,3))*(1-T(j,2))*T(j,1); 
    B(j,2) = T(j,7) + (1-T(j,7))*T(j,6) + (1-T(j,5))*(1-T(j,4))*T(j,3) + (1-T(j,4))*(1-T(j,3))*T(j,2); 
    B(j,3) = T(j,7) + (1-T(j,7))*T(j,6) + (1-T(j,7))*(1-T(j,6))*T(j,5) + (1-T(j,6))*(1-T(j,5))*T(j,4); 

    D(j,:) = B(j,:)*2.^(0:1:N-1)';
end

end
