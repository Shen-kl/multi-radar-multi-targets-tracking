%% Simulate_Initialise
% Author: Shen Kailun
% Date  : 2023-11-14

%���ܣ�������ʼ�� �����״�ϵͳ������ʼ�� ������������ʼ����
s = sprintf("====Simulate_Initialise====");
disp(s);

%% ԭ�㾭γ��
origin_longitude = 120.61725;
origin_latitude = 31.336535;
%% �״������ʼ��
radar_param = struct(...%�״����
    'location_enu',[],...%�״�����
    'location_geography',[],...%�״ﾭγ��
    'detection_distance_range',[],...%����̽�ⷶΧ
    'detection_azimuth_range',[],...%��λ��̽�ⷶΧ
    'detection_elevation_range',[],...%������̽�ⷶΧ
    'tracker_method',[],...'���ٷ���'
    'tracker',[],...'������'
    'T',[],...%֡����
    'distance_measurement_error',[],...%����۲����
    'azimuth_measurement_error',[],...%��λ�۲����
    'elevation_measurement_error',[],...%�����۲����
    'measurement_set',[],...%���⼯��
    'track_set',[],...%��������
    'track_header',[]...%����ͷ����
);

%�״�1
radar_param(1).location_enu = [4e3 0 0];
radar_param(1).location_geography = [120.65519,31.336343,0];
radar_param(1).detection_distance_range = [1e3 5e3];
radar_param(1).detection_azimuth_range = [-12 12];
radar_param(1).detection_elevation_range = [0.5 80];
radar_param(1).tracker_method = 'KF';
radar_param(1).T = 0.1;
radar_param(1).distance_measurement_error = 20;
radar_param(1).azimuth_measurement_error = 0.2;
radar_param(1).elevation_measurement_error = 0.2;
%�״�2
radar_param(2).location_enu = [0 4e3 0];
radar_param(2).location_geography = [120.61725,31.371806,0];
radar_param(2).detection_distance_range = [1e3 6e3];
radar_param(2).detection_azimuth_range = [80 100];
radar_param(2).detection_elevation_range = [0.5 70];
radar_param(2).tracker_method = 'KF';
radar_param(2).T = 0.1;
radar_param(2).distance_measurement_error = 15;
radar_param(2).azimuth_measurement_error = 0.1;
radar_param(2).elevation_measurement_error = 0.15;

radar_num= size(radar_param, 2);%�״�����

%̽������
figure;
th = linspace(pi/2+radar_param(1).detection_azimuth_range(1) * pi / 180,...
pi/2+radar_param(1).detection_azimuth_range(2) * pi / 180,100);
x = radar_param(1).detection_distance_range(2)*cos(th)+radar_param(1).location_enu(1);
y = radar_param(1).detection_distance_range(2)*sin(th)+radar_param(1).location_enu(2);
plot([x,radar_param(1).location_enu(1),x(1)],[y,radar_param(1).location_enu(2),y(1)],'-k');
hold on;
th = linspace(pi/2+radar_param(1).detection_azimuth_range(1) * pi / 180,...
pi/2+radar_param(1).detection_azimuth_range(2) * pi / 180,100);
x = radar_param(1).detection_distance_range(1)*cos(th)+radar_param(1).location_enu(1);
y = radar_param(1).detection_distance_range(1)*sin(th)+radar_param(1).location_enu(2);
plot([x,radar_param(1).location_enu(1),x(1)],[y,radar_param(1).location_enu(2),y(1)],'-r');


th = linspace(-pi/2+radar_param(2).detection_azimuth_range(1) * pi / 180,...
-pi/2+radar_param(2).detection_azimuth_range(2) * pi / 180,100);
x = radar_param(2).detection_distance_range(2)*cos(th)+radar_param(2).location_enu(1);
y = radar_param(2).detection_distance_range(2)*sin(th)+radar_param(2).location_enu(2);
plot([x,radar_param(2).location_enu(1),x(1)],[y,radar_param(2).location_enu(2),y(1)],'-k');
th = linspace(-pi/2+radar_param(2).detection_azimuth_range(1) * pi / 180,...
-pi/2+radar_param(2).detection_azimuth_range(2) * pi / 180,100);
x = radar_param(2).detection_distance_range(1)*cos(th)+radar_param(2).location_enu(1);
y = radar_param(2).detection_distance_range(1)*sin(th)+radar_param(2).location_enu(2);
plot([x,radar_param(2).location_enu(1),x(1)],[y,radar_param(2).location_enu(2),y(1)],'-r');
grid on;
title('˫�����״�̽�ⷶΧ');
xlabel('m');
ylabel('m');

%% �˲�����ʼ��
for index = 1 : radar_num
    switch radar_param(index).tracker_method % ��������
        case 'KF'
            T = radar_param(index).T;
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
            R=[100^2 0 0;0 (0.3*pi/180)^2 0;0 0 (0.3*pi/180)^2];%W��Э������� 

            nvar=10;%ϵͳ����
            Q=nvar*[(T^5/20) (T^4/8)  (T^3/6) zeros(1,6);...
                        (T^4/8) (T^3/2) (T^2/2) zeros(1,6);
                        (T^3/6) (T^2/2) T zeros(1,6);
                    zeros(1,3) (T^5/20) (T^4/8)  (T^3/6) zeros(1,3);
                    zeros(1,3) (T^4/8) (T^3/2)  (T^2/2) zeros(1,3);
                    zeros(1,3) (T^3/6) (T^2/2) T zeros(1,3);...
                    zeros(1,6) (T^5/20) (T^4/8)  (T^3/6);
                    zeros(1,6) (T^4/8) (T^3/2) (T^2/2);
                    zeros(1,6) (T^3/6) (T^2/2) T];%��������  
           H=[1 0 0 0 0 0 0 0 0 0;
               0 0 0 1 0 0 0 0 0 0;
               0 0 0 0 0 0 1 0 0 0];%�۲����
           radar_param(index).tracker =  KalmanFilter(F, H, Q, R);
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

%% ������ʼ��������
lambda_NT=1e-6;%��Ŀ��ռ��ܶ�
lambda_FA=64e-4;%�Ӳ��ռ��ܶ�
Pd=0.99;%������
Pf=1e-6;%�龯����
trackProbabilityThreshold = 0.6;
Vmin=[-300;-300;-300];%Ŀ����С�ٶ� X���� Y����
Vmax=[300;300;300];%Ŀ������ٶ� X���� Y����
PG=1;%�Ÿ�������
Chi_large=16;%��Ӧ2ά �Ÿ�������PG=1
Chi_small=5;%��Ӧ2ά �Ÿ�������PG 

RULE = "2_2" ; %��ʼ׼��