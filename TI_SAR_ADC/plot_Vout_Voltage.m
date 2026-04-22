function []=plot_Vout_Voltage(Vout,num,fs,windowL,windowR,fin)

x = [0:1e6/fs:num*1e6/fs-1e6/fs];

figure
stairs(x,Vout,'LineWidth',2);
hold on;%保留当前坐标区中的绘图，使新添加到坐标区中的绘图不会删除现有绘图
set(gca,'linewidth',3);
set(gca,'fontsize',20,'FontWeight','bold','fontname','Arial');
grid on;%显示 gca 命令返回的当前坐标区的主网格线。主网格线从每个刻度线延伸。
zoom xon;%仅对x轴进行图形缩放
xlim([windowL windowR]);
ylim([min(Vout)-0.3 round(10*(max(Vout)+0.3))/10]);
title('V_{OUT}','FontWeight','bold','fontsize',20,'fontname','Arial');
xlabel('Time (us)','FontWeight','bold','fontsize',20,'fontname','Arial'); 
ylabel('Voltage (V)','FontWeight','bold','fontsize',20,'fontname','Arial'); 
set(gca,'FontSize',20);
set(gcf, 'unit', 'centimeters', 'position', [10 5 18 14]);
end
