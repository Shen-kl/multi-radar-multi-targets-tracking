% Author: Shen Kailun
% Date  : 2023-11-15
function [radar] = track_manage(radar)
%�������ܣ� �������� ���������л�
%��ճ�ʼ��
head2ConfirmedTrackSet = [];
head2DeleteTrackSet = [];
confirmed2DeleteTrackSet = [];

T = radar.T;

tarTracksNum_lastTime = radar.track_num;
tracksHeadNum_lastTime = radar.track_header_num;

for i = 1 : tarTracksNum_lastTime
    %����ȷ�Ϻ���
    if radar.track_set(i).track_quality > 0 && radar.track_set(i).track_property ~= 2
        if radar.track_set(i).track_quality > 12
            radar.track_set(i).track_quality = 12;%���ֻ�а˷�
        end
        if radar.track_set(i).connection_status ~= 0
            radar.track_set(i).track_property=0;
        else
            radar.track_set(i).track_property=1;
        end
    else
        radar.track_set(i).track_property = 2;
        confirmed2DeleteTrackSet = [confirmed2DeleteTrackSet radar.track_set(i).track_index]; %�������� ɾ��
    end
end

for i =1:tracksHeadNum_lastTime
    %������ͷ
    if radar.track_header_set(i).track_quality > 2 && (exp(radar.track_header_set(i).likelihoodProbability)/1+exp(radar.track_header_set(i).likelihoodProbability))>radar.trackProbabilityThreshold% �����������ĺ���תΪĿ�꺽���洢
        head2ConfirmedTrackSet = [head2ConfirmedTrackSet radar.track_header_set(i).header_index];  %��ʼ�ɹ� ת�� ���ܺ���
        radar.track_num = radar.track_num + 1;
    elseif radar.track_header_set(i).track_quality > 2 && (exp(radar.track_header_set(i).likelihoodProbability)/1+exp(radar.track_header_set(i).likelihoodProbability))<=radar.trackProbabilityThreshold
        head2DeleteTrackSet = [head2DeleteTrackSet radar.track_header_set(i).header_index]; %��ʼδ�ɹ� ɾ��
    elseif radar.track_header_set(i).track_quality <= 0
        head2DeleteTrackSet = [head2DeleteTrackSet radar.track_header_set(i).header_index];   %�������� ɾ��
    end  
end

%     ��������ת��
if ~isempty(confirmed2DeleteTrackSet)
    for i =1:length(confirmed2DeleteTrackSet)
        [loc,value]=radar.find_track(confirmed2DeleteTrackSet(i));
        if value == 1
            radar.track_index_set = [radar.track_index_set  radar.track_set(loc).track_index];%���պ�����
            radar.track_set(loc) =[];%��ԭ�м�����ɾ��
        end
    end
end  
 
%��ʼ�� ״̬���� ���Э�������
if ~isempty(head2ConfirmedTrackSet)
    for i =1:length(head2ConfirmedTrackSet)
        [loc,value]=radar.find_head(head2ConfirmedTrackSet(i));
        if value == 1
            X = zeros(9,1);Polar_X=zeros(3,1);
            X(1:3:9,1) = radar.track_header_set(loc).X(:,end);
            X(2,1)=(radar.track_header_set(loc).X(1,end)-radar.track_header_set(loc).X(1,end - 1))/T;
            X(3,1)=((radar.track_header_set(loc).X(1,end)-radar.track_header_set(loc).X(1,end - 1))/T - ...
                (radar.track_header_set(loc).X(1,end-1)-radar.track_header_set(loc).X(1,end - 2))/T)/T;
            X(5,1)=(radar.track_header_set(loc).X(2,end)-radar.track_header_set(loc).X(2,end - 1))/T;
            X(6,1)=((radar.track_header_set(loc).X(2,end)-radar.track_header_set(loc).X(2,end - 1))/T - ...
                (radar.track_header_set(loc).X(2,end-1)-radar.track_header_set(loc).X(2,end - 2))/T)/T;          
            X(8,1)=(radar.track_header_set(loc).X(3,end)-radar.track_header_set(loc).X(3,end - 1))/T;
            X(9,1)=((radar.track_header_set(loc).X(3,end)-radar.track_header_set(loc).X(3,end - 1))/T - ...
                (radar.track_header_set(loc).X(3,end-1)-radar.track_header_set(loc).X(3,end - 2))/T)/T;         
            [Polar_X(2),Polar_X(3),Polar_X(1)] = enu2aer(X(1),X(4),X(7));
            switch radar.tracker_method
                case 'KF'
                    P = diag([1e3,1e4,1e5 ,1e3,1e4,1e5 ,1e3,1e4,1e5]);
%                     R = [20^2 0 0;0 (0.1*pi/180)^2 0;0 0 (0.1*pi/180)^2];
%                     Polar_X_0 = zeros(3,1);
%                     [Polar_X_0(2),Polar_X_0(3),Polar_X_0(1)] = enu2aer(radar.track_header_set(loc).X(1,end - 2),radar.track_header_set(loc).X(2,end - 2),radar.track_header_set(loc).X(3,end - 2));
%                     R_c_0 = error_conversion(R,Polar_X_0);
%                     Polar_X_1 = zeros(3,1);
%                     [Polar_X_1(2),Polar_X_1(3),Polar_X_1(1)] = enu2aer(radar.track_header_set(loc).X(1,end - 1),radar.track_header_set(loc).X(2,end - 1),radar.track_header_set(loc).X(3,end - 1));
%                     R_c_1 = error_conversion(R,Polar_X_1);
%                     Polar_X_2 = zeros(3,1);
%                     [Polar_X_2(2),Polar_X_2(3),Polar_X_2(1)] = enu2aer(radar.track_header_set(loc).X(1,end),radar.track_header_set(loc).X(2,end),radar.track_header_set(loc).X(3,end));
%                     R_c_2 = error_conversion(R,Polar_X_2);
%                     
%                     P_1 = zeros(3,3,9);
%                     for j = 1:3
%                         for k = 1:3
%                             P_1(:,:,(j-1)*3 + k) = [R_c_2(j,k),R_c_2(j,k)/T,R_c_2(j,k)/(T^2);
%                                 R_c_2(j,k)/T,(R_c_2(j,k)+R_c_1(j,k))/(T^2),(R_c_2(j,k)+2*R_c_1(j,k))/(T^3);
%                                 R_c_2(j,k)/(T^2),(R_c_2(j,k)+2*R_c_1(j,k))/(T^3),(R_c_2(j,k)+4*R_c_1(j,k)+R_c_0(j,k))/(T^4)];
%                         end
%                     end
%                     P = [P_1(:,:,1),P_1(:,:,2),P_1(:,:,3);
%                         P_1(:,:,4),P_1(:,:,5),P_1(:,:,6);
%                         P_1(:,:,7),P_1(:,:,8),P_1(:,:,9)];
                case 'EKF'
%                     P=diag([1e3,1e4,1e5 ,1e3,1e4,1e5 ,1e3,1e4,1e5]);
                    R = [20^2 0 0;0 (0.1*pi/180)^2 0;0 0 (0.1*pi/180)^2];
                    Polar_X_0 = zeros(3,1);
                    [Polar_X_0(2),Polar_X_0(3),Polar_X_0(1)] = enu2aer(radar.track_header_set(loc).X(1,end - 2),radar.track_header_set(loc).X(2,end - 2),radar.track_header_set(loc).X(3,end - 2));
                    R_c_0 = error_conversion(R,Polar_X_0);
                    Polar_X_1 = zeros(3,1);
                    [Polar_X_1(2),Polar_X_1(3),Polar_X_1(1)] = enu2aer(radar.track_header_set(loc).X(1,end - 1),radar.track_header_set(loc).X(2,end - 1),radar.track_header_set(loc).X(3,end - 1));
                    R_c_1 = error_conversion(R,Polar_X_1);
                    Polar_X_2 = zeros(3,1);
                    [Polar_X_2(2),Polar_X_2(3),Polar_X_2(1)] = enu2aer(radar.track_header_set(loc).X(1,end),radar.track_header_set(loc).X(2,end),radar.track_header_set(loc).X(3,end));
                    R_c_2 = error_conversion(R,Polar_X_2);
                    
                    P_1 = zeros(3,3,9);
                    for j = 1:3
                        for k = 1:3
                            P_1(:,:,(j-1)*3 + k) = [R_c_2(j,k),R_c_2(j,k)/T,R_c_2(j,k)/(T^2);
                                R_c_2(j,k)/T,(R_c_2(j,k)+R_c_1(j,k))/(T^2),(R_c_2(j,k)+2*R_c_1(j,k))/(T^3);
                                R_c_2(j,k)/(T^2),(R_c_2(j,k)+2*R_c_1(j,k))/(T^3),(R_c_2(j,k)+4*R_c_1(j,k)+R_c_0(j,k))/(T^4)];
                        end
                    end
                    P = [P_1(:,:,1),P_1(:,:,2),P_1(:,:,3);
                        P_1(:,:,4),P_1(:,:,5),P_1(:,:,6);
                        P_1(:,:,7),P_1(:,:,8),P_1(:,:,9)];
                case 'Singer'
                    P = diag([1e3,1e4,1e5 ,1e3,1e4,1e5 ,1e3,1e4,1e5]);                    
            end
            radar.track_set = [radar.track_set Track(X, P, radar.track_index_set(1),...
                radar.track_header_set(loc).zone_index,radar.track_header_set(loc).track_quality)];
            radar.track_index_set(1) = []; %�����Ŷ�����ɾ��
            radar.track_header_set(loc) =[];%��ԭ�м�����ɾ��
        end
    end
end

if ~isempty(head2DeleteTrackSet)
    for i =1:length(head2DeleteTrackSet)
        [loc,value]=radar.find_head(head2DeleteTrackSet(i));
        if value == 1
            radar.track_header_set(loc) =[];%��ԭ�м�����ɾ��
        end
    end
end     

radar.track_num = size(radar.track_set,2);
radar.track_header_num = size(radar.track_header_set,2);

% radar.plot_track_set = [];%��յ㼣�б�

end

