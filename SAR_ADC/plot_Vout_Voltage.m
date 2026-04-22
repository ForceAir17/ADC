function []=plot_Vout_Voltage(Dout,Nsample,Vfs,ts,fin,windowL,windowR)

x1 = 0:1e6*ts:(Nsample-1)*1e6*ts;    %us
x2 = 0:5e4*ts:(Nsample-1)*1e6*ts;    %us

figure;     %创建窗口
stairs(x1,Dout,'LineWidth',2);   %阶梯
hold on;
plot(x2,Vfs/2 + Vfs/2*sin(2*pi*fin*x2/1e6),'LineWidth',2);
grid on;    %网格
zoom xon;   %横向放大

xlim([windowL windowR]);
ylim([min(Dout)-0.1 round(10*(max(Dout)+0.1))/10]);

title('V_{OUT}','FontWeight','bold','fontsize',20,'fontname','Arial');
xlabel('Time (\mus)','FontWeight','bold','fontsize',20,'fontname','Arial'); 
ylabel('Voltage (V)','FontWeight','bold','fontsize',20,'fontname','Arial');
legend('V_{OUT}','V_{IN}')

set(gca, 'FontSize',14, 'FontWeight','Bold', 'FontName','Arial', 'LineWidth',3);
set(gcf, 'Color','White', 'Unit','CentiMeters', 'Position',[10 5 18 14]);

end
