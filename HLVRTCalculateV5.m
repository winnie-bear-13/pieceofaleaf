clc
clear

% SourceData = csvread('MY5MW_lv_2025_02_16_114737.csv',1,0);
SourceData = csvread('20%emptyfall.csv',1,0);

isLineV = 1;%1：线电压；0：相电压
time = SourceData(:,1);
Ts = single(abs(SourceData(1,1)-SourceData(2,1))); %采样周期 
Freq = single(50);%被测信号基波均为50Hz              
SamplePer = uint32(1/Freq/Ts); %一个周期的采样点数   
SampleTotal = uint32(length(SourceData)); %所有数据的总采样点数
if isLineV == 0
    U_an = SourceData(:,2);%电网U相相电压 
    U_bn = SourceData(:,3);%电网V相相电压 
    U_cn = SourceData(:,4);%电网W相相电压 
elseif isLineV == 1
    U_uv = SourceData(:,2);%电网uv线电压 
    U_vw = SourceData(:,3);%电网vw线电压
    U_wu = SourceData(:,4);%电网wu线电压
    U_an = (U_uv-U_wu)/3;%线电压转化为相电压
    U_bn = (U_vw-U_uv)/3;%线电压转化为相电压
    U_cn = (U_wu-U_vw)/3;%线电压转化为相电压
end
I_a = SourceData(:,5);%U相相电流 
I_b = SourceData(:,6);%V相相电流
I_c = SourceData(:,7);%W相相电流
%相电压基波傅里叶系数分量
U_an_cos = U_an; 
U_an_sin = U_an; 
U_bn_cos = U_bn; 
U_bn_sin = U_bn; 
U_cn_cos = U_cn; 
U_cn_sin = U_cn;
%线电压基波傅里叶系数分量
if isLineV == 1
    U_uv_cos = U_an; 
    U_uv_sin = U_an; 
    U_vw_cos = U_bn; 
    U_vw_sin = U_bn; 
    U_wu_cos = U_cn; 
    U_wu_sin = U_cn;
end
I_a_cos = I_a; 
I_a_sin = I_a; 
I_b_cos = I_b; 
I_b_sin = I_b; 
I_c_cos = I_c; 
I_c_sin = I_c; 
%相电压傅里叶系数一个周期内的积分
U_an_cos_INT = single(0);
U_an_sin_INT = single(0);
U_bn_cos_INT = single(0);
U_bn_sin_INT = single(0);
U_cn_cos_INT = single(0);
U_cn_sin_INT = single(0);
%线电压傅里叶系数一个周期内的积分
if isLineV == 1
    U_uv_cos_INT = single(0);
    U_uv_sin_INT = single(0);
    U_vw_cos_INT = single(0);
    U_vw_sin_INT = single(0);
    U_wu_cos_INT = single(0);
    U_wu_sin_INT = single(0);
end
I_a_cos_INT = single(0);
I_a_sin_INT = single(0);
I_b_cos_INT = single(0);
I_b_sin_INT = single(0);
I_c_cos_INT = single(0);
I_c_sin_INT = single(0);
%相电压一个周期内有效值计算的积分变量
U_an_rms_INT = single(0);
U_bn_rms_INT = single(0);
U_cn_rms_INT = single(0);
%线电压一个周期内有效值计算的积分变量
U_uv_rms_INT = single(0);
U_vw_rms_INT = single(0);
U_wu_rms_INT = single(0);

I_b_rms_INT = single(0);
I_a_rms_INT = single(0);
I_c_rms_INT = single(0);
%相电压基波有效值
U_an_rms_H1 = U_an;
U_bn_rms_H1 = U_bn;
U_cn_rms_H1 = U_cn;
%线电压基波有效值
U_uv_rms_H1 = U_an;
U_vw_rms_H1 = U_bn;
U_wu_rms_H1 = U_cn;

I_a_rms_H1 = I_a;
I_b_rms_H1 = I_b;
I_c_rms_H1 = I_c;
%相电压总有效值
U_an_rms = U_an;
U_bn_rms = U_bn;
U_cn_rms = U_cn;
%线电压总有效值
U_uv_rms = U_an;
U_vw_rms = U_bn;
U_wu_rms = U_cn;

I_a_rms = I_a;
I_b_rms = I_b;
I_c_rms = I_c;
%基波正序电压电流矢量
U_p_cos = U_an;
U_p_sin = U_an;
I_p_cos = I_a;
I_p_sin = I_b;
%基波负序电压电流矢量
U_n_cos = U_an;
U_n_sin = U_an;
I_n_cos = I_a;
I_n_sin = I_b;
%基波正序有功、无功
P_p = U_an;
Q_p = U_an;
IP_p = I_a;
IQ_p = I_a;
%基波负序有功、无功
P_n = U_an;
Q_n = U_an;
IP_n = I_a;
IQ_n = I_a;
%基波正序线电压有效值
U_p_ab_rms = U_an;
%基波负序线电压有效值
U_n_ab_rms = U_an;
%基波正序分量功率因数
PowerFactor = U_an;
%基波负序分量功率因数
PowerFactor_n = U_an;
for i = 1:SampleTotal
    if i <= SamplePer    
            U_an_cos_INT = U_an(i)*cos(2*pi*Freq*Ts*single(i-1))+U_an_cos_INT;
            U_an_cos(i) = U_an_cos_INT*2/single(i);
            U_an_sin_INT = U_an(i)*sin(2*pi*Freq*Ts*single(i-1))+U_an_sin_INT;
            U_an_sin(i) = U_an_sin_INT*2/single(i);
            U_bn_cos_INT = U_bn(i)*cos(2*pi*Freq*Ts*single(i-1))+U_bn_cos_INT;
            U_bn_cos(i) = U_bn_cos_INT*2/single(i);
            U_bn_sin_INT = U_bn(i)*sin(2*pi*Freq*Ts*single(i-1))+U_bn_sin_INT;
            U_bn_sin(i) = U_bn_sin_INT*2/single(i);
            U_cn_cos_INT = U_cn(i)*cos(2*pi*Freq*Ts*single(i-1))+U_cn_cos_INT;
            U_cn_cos(i) = U_cn_cos_INT*2/single(i);
            U_cn_sin_INT = U_cn(i)*sin(2*pi*Freq*Ts*single(i-1))+U_cn_sin_INT;
            U_cn_sin(i) = U_cn_sin_INT*2/single(i);
            
            I_a_cos_INT = I_a(i)*cos(2*pi*Freq*Ts*single(i-1))+I_a_cos_INT;
            I_a_cos(i) = I_a_cos_INT*2/single(i);
            I_a_sin_INT = I_a(i)*sin(2*pi*Freq*Ts*single(i-1))+I_a_sin_INT;
            I_a_sin(i) = I_a_sin_INT*2/single(i);
            I_b_cos_INT = I_b(i)*cos(2*pi*Freq*Ts*single(i-1))+I_b_cos_INT;
            I_b_cos(i) = I_b_cos_INT*2/single(i);
            I_b_sin_INT = I_b(i)*sin(2*pi*Freq*Ts*single(i-1))+I_b_sin_INT;
            I_b_sin(i) = I_b_sin_INT*2/single(i);
            I_c_cos_INT = I_c(i)*cos(2*pi*Freq*Ts*single(i-1))+I_c_cos_INT;
            I_c_cos(i) = I_c_cos_INT*2/single(i);
            I_c_sin_INT = I_c(i)*sin(2*pi*Freq*Ts*single(i-1))+I_c_sin_INT;
            I_c_sin(i) = I_c_sin_INT*2/single(i);
            
            U_an_rms_INT = power(U_an(i),2)+U_an_rms_INT;
            U_an_rms(i) = sqrt(U_an_rms_INT/single(i));
            U_bn_rms_INT = power(U_bn(i),2)+U_bn_rms_INT;
            U_bn_rms(i) = sqrt(U_bn_rms_INT/single(i));
            U_cn_rms_INT = power(U_cn(i),2)+U_cn_rms_INT;
            U_cn_rms(i) = sqrt(U_cn_rms_INT/single(i));
            I_a_rms_INT = power(I_a(i),2)+I_a_rms_INT;
            I_a_rms(i) = sqrt(I_a_rms_INT/single(i));
            I_b_rms_INT = power(I_b(i),2)+I_b_rms_INT;
            I_b_rms(i) = sqrt(I_b_rms_INT/single(i));
            I_c_rms_INT = power(I_c(i),2)+I_c_rms_INT;
            I_c_rms(i) = sqrt(I_c_rms_INT/single(i));
            if isLineV == 1
                U_uv_cos_INT = U_uv(i)*cos(2*pi*Freq*Ts*single(i-1))+U_uv_cos_INT;
                U_uv_cos(i) = U_uv_cos_INT*2/single(i);
                U_uv_sin_INT = U_uv(i)*sin(2*pi*Freq*Ts*single(i-1))+U_uv_sin_INT;
                U_uv_sin(i) = U_uv_sin_INT*2/single(i);
                U_vw_cos_INT = U_vw(i)*cos(2*pi*Freq*Ts*single(i-1))+U_vw_cos_INT;
                U_vw_cos(i) = U_vw_cos_INT*2/single(i);
                U_vw_sin_INT = U_vw(i)*sin(2*pi*Freq*Ts*single(i-1))+U_vw_sin_INT;
                U_vw_sin(i) = U_vw_sin_INT*2/single(i);
                U_wu_cos_INT = U_wu(i)*cos(2*pi*Freq*Ts*single(i-1))+U_wu_cos_INT;
                U_wu_cos(i) = U_wu_cos_INT*2/single(i);
                U_wu_sin_INT = U_wu(i)*sin(2*pi*Freq*Ts*single(i-1))+U_wu_sin_INT;
                U_wu_sin(i) = U_wu_sin_INT*2/single(i);
            end
    else
            U_an_cos_INT = U_an(i)*cos(2*pi*Freq*Ts*single(i-1))+U_an_cos_INT-U_an(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
            U_an_cos(i) = U_an_cos_INT*2/single(SamplePer);
            U_an_sin_INT = U_an(i)*sin(2*pi*Freq*Ts*single(i-1))+U_an_sin_INT-U_an(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
            U_an_sin(i) = U_an_sin_INT*2/single(SamplePer);
            U_bn_cos_INT = U_bn(i)*cos(2*pi*Freq*Ts*single(i-1))+U_bn_cos_INT-U_bn(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
            U_bn_cos(i) = U_bn_cos_INT*2/single(SamplePer);
            U_bn_sin_INT = U_bn(i)*sin(2*pi*Freq*Ts*single(i-1))+U_bn_sin_INT-U_bn(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
            U_bn_sin(i) = U_bn_sin_INT*2/single(SamplePer);
            U_cn_cos_INT = U_cn(i)*cos(2*pi*Freq*Ts*single(i-1))+U_cn_cos_INT-U_cn(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
            U_cn_cos(i) = U_cn_cos_INT*2/single(SamplePer);
            U_cn_sin_INT = U_cn(i)*sin(2*pi*Freq*Ts*single(i-1))+U_cn_sin_INT-U_cn(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
            U_cn_sin(i) = U_cn_sin_INT*2/single(SamplePer);
            
            I_a_cos_INT = I_a(i)*cos(2*pi*Freq*Ts*single(i-1))+I_a_cos_INT-I_a(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
            I_a_cos(i) = I_a_cos_INT*2/single(SamplePer);
            I_a_sin_INT = I_a(i)*sin(2*pi*Freq*Ts*single(i-1))+I_a_sin_INT-I_a(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
            I_a_sin(i) = I_a_sin_INT*2/single(SamplePer);
            I_b_cos_INT = I_b(i)*cos(2*pi*Freq*Ts*single(i-1))+I_b_cos_INT-I_b(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
            I_b_cos(i) = I_b_cos_INT*2/single(SamplePer);
            I_b_sin_INT = I_b(i)*sin(2*pi*Freq*Ts*single(i-1))+I_b_sin_INT-I_b(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
            I_b_sin(i) = I_b_sin_INT*2/single(SamplePer);
            I_c_cos_INT = I_c(i)*cos(2*pi*Freq*Ts*single(i-1))+I_c_cos_INT-I_c(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
            I_c_cos(i) = I_c_cos_INT*2/single(SamplePer);
            I_c_sin_INT = I_c(i)*sin(2*pi*Freq*Ts*single(i-1))+I_c_sin_INT-I_c(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
            I_c_sin(i) = I_c_sin_INT*2/single(SamplePer);
            
            U_an_rms_INT = power(U_an(i),2)+U_an_rms_INT-power(U_an(i-SamplePer),2);
            U_an_rms(i) = sqrt(U_an_rms_INT/single(SamplePer));
            U_bn_rms_INT = power(U_bn(i),2)+U_bn_rms_INT-power(U_bn(i-SamplePer),2);
            U_bn_rms(i) = sqrt(U_bn_rms_INT/single(SamplePer));
            U_cn_rms_INT = power(U_cn(i),2)+U_cn_rms_INT-power(U_cn(i-SamplePer),2);
            U_cn_rms(i) = sqrt(U_cn_rms_INT/single(SamplePer));
            I_a_rms_INT = power(I_a(i),2)+I_a_rms_INT-power(I_a(i-SamplePer),2);
            I_a_rms(i) = sqrt(I_a_rms_INT/single(SamplePer));
            I_b_rms_INT = power(I_b(i),2)+I_b_rms_INT-power(I_b(i-SamplePer),2);
            I_b_rms(i) = sqrt(I_b_rms_INT/single(SamplePer));
            I_c_rms_INT = power(I_c(i),2)+I_c_rms_INT-power(I_c(i-SamplePer),2);
            I_c_rms(i) = sqrt(I_c_rms_INT/single(SamplePer));  
            if isLineV == 1
                U_uv_cos_INT = U_uv(i)*cos(2*pi*Freq*Ts*single(i-1))+U_uv_cos_INT-U_uv(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
                U_uv_cos(i) = U_uv_cos_INT*2/single(SamplePer);
                U_uv_sin_INT = U_uv(i)*sin(2*pi*Freq*Ts*single(i-1))+U_uv_sin_INT-U_uv(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
                U_uv_sin(i) = U_uv_sin_INT*2/single(SamplePer);
                U_vw_cos_INT = U_vw(i)*cos(2*pi*Freq*Ts*single(i-1))+U_vw_cos_INT-U_vw(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
                U_vw_cos(i) = U_vw_cos_INT*2/single(SamplePer);
                U_vw_sin_INT = U_vw(i)*sin(2*pi*Freq*Ts*single(i-1))+U_vw_sin_INT-U_vw(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
                U_vw_sin(i) = U_vw_sin_INT*2/single(SamplePer);
                U_wu_cos_INT = U_wu(i)*cos(2*pi*Freq*Ts*single(i-1))+U_wu_cos_INT-U_wu(i-SamplePer) *cos(2*pi*Freq*Ts*single(i-SamplePer-1));
                U_wu_cos(i) = U_wu_cos_INT*2/single(SamplePer);
                U_wu_sin_INT = U_wu(i)*sin(2*pi*Freq*Ts*single(i-1))+U_wu_sin_INT-U_wu(i-SamplePer) *sin(2*pi*Freq*Ts*single(i-SamplePer-1));
                U_wu_sin(i) = U_wu_sin_INT*2/single(SamplePer);
           
                U_uv_rms_INT = power(U_uv(i),2)+U_uv_rms_INT-power(U_uv(i-SamplePer),2);
                U_uv_rms(i) = sqrt(U_uv_rms_INT/single(SamplePer));
                U_vw_rms_INT = power(U_vw(i),2)+U_vw_rms_INT-power(U_vw(i-SamplePer),2);
                U_vw_rms(i) = sqrt(U_vw_rms_INT/single(SamplePer));
                U_wu_rms_INT = power(U_wu(i),2)+U_wu_rms_INT-power(U_wu(i-SamplePer),2);
                U_wu_rms(i) = sqrt(U_wu_rms_INT/single(SamplePer));
            end
    end
    U_an_rms_H1(i) = sqrt((power(U_an_cos(i),2)+power(U_an_sin(i),2))/2);
    U_bn_rms_H1(i) = sqrt((power(U_bn_cos(i),2)+power(U_bn_sin(i),2))/2);
    U_cn_rms_H1(i) = sqrt((power(U_cn_cos(i),2)+power(U_cn_sin(i),2))/2);
    U_p_cos(i) = 1/6*(2*U_an_cos(i)-U_bn_cos(i)-U_cn_cos(i)-sqrt(3)*(U_cn_sin(i)-U_bn_sin(i)));
    U_p_sin(i) = 1/6*(2*U_an_sin(i)-U_bn_sin(i)-U_cn_sin(i)-sqrt(3)*(U_bn_cos(i)-U_cn_cos(i)));
    U_p_ab_rms(i) = sqrt(3/2*(power(U_p_cos(i),2)+power(U_p_sin(i),2)));
    I_a_rms_H1(i) = sqrt((power(I_a_cos(i),2)+power(I_a_sin(i),2))/2);
    I_b_rms_H1(i) = sqrt((power(I_b_cos(i),2)+power(I_b_sin(i),2))/2);
    I_c_rms_H1(i) = sqrt((power(I_c_cos(i),2)+power(I_c_sin(i),2))/2);
    I_p_cos(i) = 1/6*(2*I_a_cos(i)-I_b_cos(i)-I_c_cos(i)-sqrt(3)*(I_c_sin(i)-I_b_sin(i)));
    I_p_sin(i) = 1/6*(2*I_a_sin(i)-I_b_sin(i)-I_c_sin(i)-sqrt(3)*(I_b_cos(i)-I_c_cos(i)));
    P_p(i) = 3/2*(U_p_cos(i)*I_p_cos(i)+U_p_sin(i)*I_p_sin(i))/1000;
    Q_p(i) = 3/2*(U_p_cos(i)*I_p_sin(i)-U_p_sin(i)*I_p_cos(i))/1000;
    IP_p(i) = P_p(i)/sqrt(3)/U_p_ab_rms(i)*1000;
    IQ_p(i) = Q_p(i)/sqrt(3)/U_p_ab_rms(i)*1000;
    PowerFactor(i) = P_p(i)/sqrt(power(P_p(i),2)+power(Q_p(i),2)); 
    %基波负序分量计算
    U_n_cos(i) = 1/6*(2*U_an_cos(i)-U_bn_cos(i)-U_cn_cos(i)+sqrt(3)*(U_cn_sin(i)-U_bn_sin(i)));
    U_n_sin(i) = 1/6*(2*U_an_sin(i)-U_bn_sin(i)-U_cn_sin(i)-sqrt(3)*(U_cn_cos(i)-U_bn_cos(i)));
    U_n_ab_rms(i) = sqrt(3/2*(power(U_n_cos(i),2)+power(U_n_sin(i),2)));
    I_n_cos(i) = 1/6*(2*I_a_cos(i)-I_b_cos(i)-I_c_cos(i)+sqrt(3)*(I_c_sin(i)-I_b_sin(i)));
    I_n_sin(i) = 1/6*(2*I_a_sin(i)-I_b_sin(i)-I_c_sin(i)-sqrt(3)*(I_c_cos(i)-I_b_cos(i)));
    P_n(i) = 3/2*(U_n_cos(i)*I_n_cos(i)+U_n_sin(i)*I_n_sin(i))/1000;
    Q_n(i) = 3/2*(U_n_cos(i)*I_n_sin(i)-U_n_sin(i)*I_n_cos(i))/1000;
    IP_n(i) = P_n(i)/sqrt(3)/U_n_ab_rms(i)*1000;
    IQ_n(i) = Q_n(i)/sqrt(3)/U_n_ab_rms(i)*1000;
    PowerFactor_n(i) = P_n(i)/sqrt(power(P_n(i),2)+power(Q_n(i),2));
    if isLineV == 1
        U_uv_rms_H1(i) = sqrt((power(U_uv_cos(i),2)+power(U_uv_sin(i),2))/2);
        U_vw_rms_H1(i) = sqrt((power(U_vw_cos(i),2)+power(U_vw_sin(i),2))/2);
        U_wu_rms_H1(i) = sqrt((power(U_wu_cos(i),2)+power(U_wu_sin(i),2))/2);
    end
end
% figure
% set(gcf,'color','black'); %窗口背景黑色
% colordef black; %2D/3D图背景黑色
% dcm_obj = datacursormode(gcf);
% set(dcm_obj,'UpdateFcn',@NewCallback)
% subplot(2,1,1)
% plot(time,U_an_cos,'DisplayName','Uan,cos')
% hold on
% plot(time,U_an_sin,'DisplayName','Uan,sin')
% hold on
% plot(time,U_bn_cos,'DisplayName','Ubn,cos')
% hold on
% plot(time,U_bn_sin,'DisplayName','Ubn,sin')
% hold on
% plot(time,U_cn_cos,'DisplayName','Ucn,cos')
% hold on
% plot(time,U_cn_sin,'DisplayName','Ucn,sin')
% hold on
% plot(time,U_an_rms_H1,'DisplayName','Uan,rms,H1')
% hold on
% plot(time,U_bn_rms_H1,'DisplayName','Ubn,rms,H1')
% hold on
% plot(time,U_cn_rms_H1,'DisplayName','Ucn,rms,H1')
% hold on
% plot(time,I_a_rms_H1,'DisplayName','Ia,rms,H1')
% hold on
% plot(time,I_b_rms_H1,'DisplayName','Ib,rms,H1')
% hold on
% plot(time,I_c_rms_H1,'DisplayName','Ic,rms,H1')
% hold on
% plot(time,U_an_rms,'DisplayName','Uan,rms')
% hold on
% plot(time,U_bn_rms,'DisplayName','Ubn,rms')
% hold on
% plot(time,U_cn_rms,'DisplayName','Ucn,rms')
% hold on
% plot(time,I_a_rms,'DisplayName','Ia,rms')
% hold on
% plot(time,I_b_rms,'DisplayName','Ib,rms')
% hold on
% plot(time,I_c_rms,'DisplayName','Ic,rms')
% % axis([-2 2 -1000 2000])
% legend show
% grid on

%==========================正负序分量显示===========================
% ax1 = subplot(4,1,1);
% plot(time,U_p_ab_rms,'Color',[255/255,255/255,0/255],'LineWidth',2,'DisplayName','Up,ab,rms')%正序基波电压
% hold on
% plot(time,U_n_ab_rms,'Color',[30/255,144/255,255/255],'LineWidth',2,'DisplayName','Un,ab,rms')%负序基波电压
% xlabel('时间 /s'); % 设置X轴名称
% ylabel('电压序分量 / V'); % 设置Y轴名称
% legend show
% grid on
% ax2 = subplot(4,1,2);
% plot(time,P_p,'Color',[255/255,0/255,0/255],'LineWidth',2,'DisplayName','P,p')
% hold on
% plot(time,Q_p,'Color',[127/255,255/255,0/255],'LineWidth',2,'DisplayName','Q,p')
% hold on
% plot(time,PowerFactor,'Color',[255/255,153/255,18/255],'LineWidth',2,'DisplayName','PF,p')
% xlabel('时间 /s'); % 设置X轴名称
% ylabel('功率序分量 / kW'); % 设置Y轴名称
% legend show
% grid on
% ax3 = subplot(4,1,3);
% plot(time,IP_p,'Color',[255/255,0/255,0/255],'LineWidth',2,'DisplayName','IP,p')
% hold on
% plot(time,IQ_p,'Color',[127/255,255/255,0/255],'LineWidth',2,'DisplayName','IQ,p')
% hold on
% plot(time,IQ_n,'Color',[0/255,191/255,255/255],'LineWidth',2,'DisplayName','IQ,n')
% xlabel('时间 /s'); % 设置X轴名称
% ylabel('电流序分量 / V'); % 设置Y轴名称
% legend show
% grid on
% ax4 = subplot(4,1,4);
% plot(time,U_an,'Color',[255/255,255/255,0/255],'LineWidth',2,'DisplayName','Uan')
% hold on
% plot(time,U_bn,'Color',[127/255,255/255,0/255],'LineWidth',2,'DisplayName','Ubn')
% hold on
% plot(time,U_cn,'Color',[255/255,0/255,0/255],'LineWidth',2,'DisplayName','Ucn')
% hold on
% plot(time,I_a,'Color',[255/255,153/255,18/255],'LineWidth',2,'DisplayName','Ia')
% hold on
% plot(time,I_b,'Color',[0/255,100/255,0/255],'LineWidth',2,'DisplayName','Ib')
% hold on
% plot(time,I_c,'Color',[255/255,0/255,255/255],'LineWidth',2,'DisplayName','Ic')
% xlabel('时间 /s'); % 设置X轴名称
% ylabel('电压电流 / V-A'); % 设置Y轴名称
% legend show
% grid on
% linkaxes([ax1,ax2,ax3,ax4],'x')

%===================负序分量显示=========================
% plot(time,U_n_ab_rms,'DisplayName','Un,ab,rms')
% hold on
% plot(time,U_n_cos,'DisplayName','Un,cos')
% hold on
% plot(time,U_n_sin,'DisplayName','Un,sin')
% hold on
% plot(time,P_n,'DisplayName','P,n')
% hold on
% plot(time,Q_n,'DisplayName','Q,n')
% hold on
% plot(time,IP_n,'DisplayName','IP,n')
% hold on
% plot(time,IQ_n,'DisplayName','IQ,n')
% hold on
% plot(time,PowerFactor_n,'DisplayName','PF,n')
% legend show
% grid on
%===================瞬时值显示=========================
% plot(time,U_an,'DisplayName','Uan')
% hold on
% plot(time,U_bn,'DisplayName','Ubn')
% hold on
% plot(time,U_cn,'DisplayName','Ucn')
% hold on
% plot(time,I_a,'DisplayName','Ia')
% hold on
% plot(time,I_b,'DisplayName','Ib')
% hold on
% plot(time,I_c,'DisplayName','Ic')
% legend show
% grid on
%=======================以下变量在simulink中通过from Workspace在scope中显示曲线
modelName = 'HLVRTCalculateV5Sim';
open_system(modelName);
sampleTime = Ts; % 定义采样时间变量
U_p_ab_rms = [time,U_p_ab_rms];
U_n_ab_rms = [time,U_n_ab_rms];
U_uv_rms_H1 = [time,U_uv_rms_H1];
U_vw_rms_H1 = [time,U_vw_rms_H1];
U_wu_rms_H1 = [time,U_wu_rms_H1];
P_p = [time,P_p];
Q_p = [time,Q_p];
PowerFactor = [time,PowerFactor];
IP_p = [time,IP_p];
IQ_p = [time,IQ_p];
IQ_n = [time,IQ_n];
U_an = [time,U_an];
U_bn = [time,U_bn];
U_cn = [time,U_cn];
I_a = [time,I_a];
I_b = [time,I_b];
I_c = [time,I_c];
U_uv = [time,U_uv];
U_vw = [time,U_vw];
U_wu = [time,U_wu];

set_param(modelName,'StartTime',num2str(time(1)));%仿真开始时间为csv原始数据的第一行有效数据
set_param(modelName,'StopTime',num2str(time(SampleTotal)));%仿真结束时间为csv原始数据的最后一行有效数据
set_param('HLVRTCalculateV5Sim/U_an_V','SampleTime',num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_bn_V', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_cn_V', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/I_a_A', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/I_b_A', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/I_c_A', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_p_ab_rms_V', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_n_ab_rms_V', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/P_p_kW', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/Q_p_kVA', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/PF_p', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/IP_p_A', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/IQ_p_A', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/IQ_n_A', 'SampleTime', num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_uv_rms_H1','SampleTime',num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_vw_rms_H1','SampleTime',num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_wu_rms_H1','SampleTime',num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_uv','SampleTime',num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_vw','SampleTime',num2str(sampleTime));
set_param('HLVRTCalculateV5Sim/U_wu','SampleTime',num2str(sampleTime));

save_system(modelName);
% sim(modelName);
% close_system(modelName);


