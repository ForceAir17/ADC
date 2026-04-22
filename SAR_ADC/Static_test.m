function[DNLmax,DNLmin,INLmax,INLmin]=Static_test(Dout,N)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% 静态特性测试 %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 计算DNL/INL
min_bin=min(Dout);
max_bin=max(Dout);
h=hist(Dout, min_bin:max_bin);            % 直方图
ch = cumsum(h);                           % 累积直方图
Tlevels = -cos(pi*ch/sum(h));             % 升余弦拟合
hlin = Tlevels(2:end) - Tlevels(1:end-1); % 相邻码箱之间的差异
hlin = hlin(3:end-2);                     % 丢弃边缘码箱
lsb = sum(hlin) / (length(hlin));         % 查找箱之间的平均差异,以消除增益误差
DNL = [0 hlin/lsb-1];                     % 删除增益误差,中心处DNL为0
INL = cumsum(DNL);                        % INL是DNL的积分（求和）

DNLmax=max(DNL);
DNLmin=min(DNL); 
INLmax=max(INL);
INLmin=min(INL);
  
% 绘出DNL/INL
figure;

subplot(2,1,1);
grid on;
box on;
Q_DNL=plot(linspace(min_bin+2, max_bin-2, length(DNL)), DNL,'k');
set(Q_DNL,'linewidth',2);

% text(0.02,0.5,sprintf('DNLmax = %3.2fLSB\n\n\n\n\nDNLmin = %3.2fLSB',DNLmax,DNLmin),...
%    'sc','FontWeight','bold','fontsize',15,'fontname','Arial');
text(0.02,0.5,sprintf('+%3.2fLSB/%3.2fLSB\n\n\n\n\n',DNLmax,DNLmin),...
    'sc','FontWeight','bold','fontsize',15,'fontname','Arial');

%xlim([0 2^N]);ylim([-1 1]);
axis([0 2^N -10 60]);

title(sprintf('DNL'),'FontWeight','bold','fontsize',20,'fontname','Arial');
xlabel('Digital Code [LSB]');
ylabel('DNL [LSB]');

set(gca, 'LineWidth',2, 'FontWeight','Bold', 'FontSize',15, 'FontName','Arial', 'Xgrid','Off');
set(gcf, 'Color','White', 'Unit','CentiMeters', 'Position', [10 5 18 14]);

subplot(2,1,2);
grid on;
box on;
Q_INL=plot(linspace(min_bin+2, max_bin-2, length(DNL)), INL,'k');
set(Q_INL,'linewidth',2);

% text(0.02,0.5,sprintf('INLmax = %3.2fLSB\n\n\n\n\nINLmin = %3.2fLSB',INLmax,INLmin),...
%    'sc','FontWeight','Bold', 'FontSize',15, 'FontName','Arial');
text(0.02,0.5,sprintf('+%3.2fLSB/%3.2fLSB\n\n\n\n\n',INLmax,INLmin),...
    'sc','FontWeight','Bold', 'FontSize',15, 'FontName','Arial');

axis([0 2^N -50 50]);

title(sprintf('INL'),'FontWeight','Bold', 'FontSize',20, 'FontName','Arial');
xlabel('Digital Code [LSB]');
ylabel('INL [LSB]');

set(gca, 'LineWidth',2, 'FontWeight','Bold', 'FontSize',15, 'FontName','Arial', 'Xgrid','Off');
set(gcf, 'Color','White', 'Unit','CentiMeters', 'Position', [10 5 18 14]);

