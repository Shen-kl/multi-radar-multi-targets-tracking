%% Simulate_Initialise
% Author: Shen Kailun
% Date  : 2023-11-14

%���ܣ�������ʼ�� �����״�ϵͳ������ʼ�� ������������ʼ����
s = sprintf("====Simulate_Initialise====");
disp(s);

%% ԭ�㾭γ��
origin_longitude = 120.610816;
origin_latitude = 31.329486;
%% �״������ʼ��
%�״�1
radar(1) = Radar([1e3 0 0], [120.621778,31.329486,0],...
                [200 1.5e3], [-12 12],...
                [0.5 80], 'KF',...
                0.2,20,0.1,0.1,1e-6,64e-4,0.99,1e-6,0.6,...
                [-300;-300;-300],[300;300;300],1,16,5,100,1);
%�״�2
radar(2) = Radar([0 1e3 0], [120.610816,31.338553,0],...
                [200 2e3], [80 100],...
                [0.5 70], 'KF',...
                0.2,15,0.1,0.1,1e-6,64e-4,0.99,1e-6,0.6,...
                [-300;-300;-300],[300;300;300],1,16,5,100,1);
          
radar_num= size(radar, 2);%�״�����

%̽������
% figure(1);
% th = linspace(pi/2+radar(1).detection_azimuth_range(1) * pi / 180,...
% pi/2+radar(1).detection_azimuth_range(2) * pi / 180,100);
% x = radar(1).detection_distance_range(2)*cos(th)+radar(1).location_enu(1);
% y = radar(1).detection_distance_range(2)*sin(th)+radar(1).location_enu(2);
% plot([x,radar(1).location_enu(1),x(1)],[y,radar(1).location_enu(2),y(1)],'-k');
% hold on;
% th = linspace(pi/2+radar(1).detection_azimuth_range(1) * pi / 180,...
% pi/2+radar(1).detection_azimuth_range(2) * pi / 180,100);
% x = radar(1).detection_distance_range(1)*cos(th)+radar(1).location_enu(1);
% y = radar(1).detection_distance_range(1)*sin(th)+radar(1).location_enu(2);
% plot([x,radar(1).location_enu(1),x(1)],[y,radar(1).location_enu(2),y(1)],'-r');
% 
% 
% th = linspace(-pi/2+radar(2).detection_azimuth_range(1) * pi / 180,...
% -pi/2+radar(2).detection_azimuth_range(2) * pi / 180,100);
% x = radar(2).detection_distance_range(2)*cos(th)+radar(2).location_enu(1);
% y = radar(2).detection_distance_range(2)*sin(th)+radar(2).location_enu(2);
% plot([x,radar(2).location_enu(1),x(1)],[y,radar(2).location_enu(2),y(1)],'-k');
% th = linspace(-pi/2+radar(2).detection_azimuth_range(1) * pi / 180,...
% -pi/2+radar(2).detection_azimuth_range(2) * pi / 180,100);
% x = radar(2).detection_distance_range(1)*cos(th)+radar(2).location_enu(1);
% y = radar(2).detection_distance_range(1)*sin(th)+radar(2).location_enu(2);
% plot([x,radar(2).location_enu(1),x(1)],[y,radar(2).location_enu(2),y(1)],'-r');
% grid on;
% title('˫�����״�̽�ⷶΧ');
% xlabel('m');
% ylabel('m');
% 
% plot(target1(:,5),target1(:,6));
% plot(target2(:,5),target2(:,6));
% plot(target3(:,5),target3(:,6));
% plot(target4(:,5),target4(:,6));
%% �˲�����ʼ��
for index = 1 : radar_num
    switch radar(index).tracker_method % ��������
        case 'KF'
            T = radar(index).T;
            F=[1 T 1/2*T^2 0 0 0 0 0 0 ;...
                0 1 T 0 0 0 0 0 0;...
                0 0 1 0 0 0 0 0 0;...
                0 0 0 1 T 1/2*T^2 0 0 0;...
                0 0 0 0 1 T 0 0 0;...
                0 0 0 0 0 1 0 0 0;...
                0 0 0 0 0 0 1 T T^2/2;...
                0 0 0 0 0 0 0 1 T;...
                0 0 0 0 0 0 0 0 1];%״̬ת�ƾ���
            W=[50,0.3*pi/180,0.3*pi/180]';%������������ x y z��
            R=[20^2 0 0;0 20^2 0;0 0 20^2];%

            nvar=1e2;%ϵͳ����
            Q=nvar*[(T^5/20) (T^4/8)  (T^3/6) zeros(1,6);...
                        (T^4/8) (T^3/2) (T^2/2) zeros(1,6);
                        (T^3/6) (T^2/2) T zeros(1,6);
                    zeros(1,3) (T^5/20) (T^4/8)  (T^3/6) zeros(1,3);
                    zeros(1,3) (T^4/8) (T^3/2)  (T^2/2) zeros(1,3);
                    zeros(1,3) (T^3/6) (T^2/2) T zeros(1,3);...
                    zeros(1,6) (T^5/20) (T^4/8)  (T^3/6);
                    zeros(1,6) (T^4/8) (T^3/2) (T^2/2);
                    zeros(1,6) (T^3/6) (T^2/2) T];%��������  
           H=[1 0 0 0 0 0 0 0 0 ;
               0 0 0 1 0 0 0 0 0 ;
               0 0 0 0 0 0 1 0 0 ];%�۲����
           radar(index).tracker =  KalmanFilter(F, H, Q, R);
        case 'EKF'
            
        case 'UKF'    
            
    end

end

%% �����ŷ���
TarTrackIndex=zeros(1,1000);%Ŀ�꺽����
for i=1:1000
    TarTrackIndex(i)=i;
end

HeadIndex=zeros(1,1000);%����ͷ���
for i=1:1000
    HeadIndex(i)=i;
end
