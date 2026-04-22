function [vector_Vresp,vector_Vresn]=plot_CDAC_Voltage(Vresp,Vresn,N,num,fs,windowL,windowR,X)

vector_Vresp = reshape(Vresp', [], 1);
vector_Vresn = reshape(Vresn', [], 1);
x = [0:1e6/(fs*(N+1)):num*1e6/fs-1e6/(fs*(N+1))];

figure
stairs(x,vector_Vresp,'LineWidth',2,'Color','[0.00 0.45 0.74]');hold on;
stairs(x,vector_Vresn,'LineWidth',2,'Color','[0.85 0.33 0.10]');hold on;
set(gca,'linewidth',3);
set(gca,'fontsize',20,'FontWeight','bold','fontname','Arial');

grid on;
zoom xon;       %放缩x坐标

xlim([windowL windowR]);
ylim([min(vector_Vresp)-0.3 round(10*(max(vector_Vresp)+0.3))/10]);
text((windowL+windowR)/2-(windowL+windowR)/5,max(vector_Vresp)+0.15, sprintf(' V_{CDACP}'),'LineWidth',2,'fontsize',20,'Margin',5,'FontWeight','bold','fontname','Arial','Color','[0.00 0.45 0.74]');
text((windowL+windowR)/2,max(vector_Vresp)+0.15, sprintf(' V_{CDACN}'),'LineWidth',2,'fontsize',20,'Margin',5,'FontWeight','bold','fontname','Arial','Color','[0.85 0.33 0.10]');
title(sprintf('CDAC Voltage of Channel %d',X),'FontWeight','bold','fontsize',20,'fontname','Arial');
xlabel('Time (us)','FontWeight','bold','fontsize',20,'fontname','Arial'); 
ylabel('Voltage (V)','FontWeight','bold','fontsize',20,'fontname','Arial'); 
set(gca,'FontSize',20);
set(gcf, 'unit', 'centimeters', 'position', [10 5 18 14]);
end
