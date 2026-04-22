function []=plot_CDAC_Voltage(Vresp,Vresn,N,num,ts,windowL,windowR)

vector_Vresp = reshape(Vresp', [], 1);
vector_Vresn = reshape(Vresn', [], 1);
x = 0:1e6*ts/(N+1):num*1e6*ts-1e6*ts/(N+1);

figure;
hold on;
stairs(x,vector_Vresp,'LineWidth',2,'Color','[0.00 0.45 0.74]');
stairs(x,vector_Vresn,'LineWidth',2,'Color','[0.85 0.00 0.10]');

grid on;
zoom xon;                           %放缩坐标

xlim([windowL windowR]);
ylim([min(vector_Vresp)-0.3 round(10*(max(vector_Vresp)+0.3))/10]);
%text((windowL+windowR)/2,max(vector_Vresp)+0.25, sprintf('V_{CDACP}'),'LineWidth',2,'fontsize',20,'Margin',5,'FontWeight','bold','fontname','Arial','Color','[0.00 0.45 0.74]');
%text((windowL+windowR)/2,max(vector_Vresp)+0.15, sprintf('V_{CDACN}'),'LineWidth',2,'fontsize',20,'Margin',5,'FontWeight','bold','fontname','Arial','Color','[0.85 0.00 0.10]');

title('CDAC Voltage', 'FontWeight','Bold', 'FontSize',20, 'FontName','Arial');
xlabel('Time (us)', 'FontWeight','Bold', 'FontSize',20, 'FontName','Arial'); 
ylabel('Voltage (V)', 'FontWeight','Bold', 'FontSize',20, 'FontName','Arial'); 
legend('V_{CDACP}','V_{CDACN}');

set(gca, 'FontSize',14, 'FontWeight','Bold', 'FontName','Arial', 'LineWidth',3);
set(gcf, 'Color','White', 'Unit','CentiMeters', 'Position',[10 5 18 14]);

end
