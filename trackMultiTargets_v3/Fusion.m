% Author: Shen Kailun
% Date  : 2023-11-19
classdef Fusion
    %FUSSION �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        location_geography %��γ��
        tracker_method %'���ٷ���'
        tracker %������
        T %֡����
        track_fusion_set %��������
        track_fusion_num %��������
        Chi_large%��Ӧ2ά �Ÿ�������PG=1
        Chi_small%��Ӧ2ά �Ÿ�������PG 
        radar_track_set %����վ�ϱ�����
        system_frame_index%ϵͳʱ��
        radar_set
    end
    
    methods
        function obj = Fusion(location_geography, tracker_method, T, Chi_large, Chi_small,radar_set)
            obj.location_geography = location_geography;
            obj.tracker_method =  tracker_method;%'���ٷ���'
            obj.T = T;%֡����
            obj.Chi_large = Chi_large;%��Ӧ2ά �Ÿ�������PG=1
            obj.Chi_small = Chi_small;%��Ӧ2ά �Ÿ�������PG  
            obj.track_fusion_num = 0;
            obj.radar_set = radar_set;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
        
        
        function [x,value]=find_track(obj,num)
        %���ݺ������Ҷ�Ӧ�ĺ���
        %input num ��Ҫ�ҵı��غ����ĺ������
        %output x �ñ��غ�����track_header_set����������
        %output value 1:�ɹ��ҵ� 0��δ�ҵ�
            value=0;
            if ~isempty(obj.radar_track_set)
                for x=1:size(obj.radar_track_set,2)
                    if obj.radar_track_set(x).track_report_index==num
                        value=1;
                        break;
                    end
                end
            else
                error('radar_track_set is empty!');
            end
        end   
        
        function [D,flag] = Related_gate_track2track(obj,track_fusion_index,radar_track_index,Chi)
            %��ز����ж�
            %input track_fusion_index �������غ����������е����к�
            %input radar_track_fusion_index ����ϵͳ�����������е����к�    
            %input Chi ���޳���

            %output D ͳ�ƾ���
            %output flag 1 :��� 0�������
            % ��չ�������˲�����Բ��������� 
%             jacobian_H = double(subs(obj.tracker.jacobian_H,{'x','x_1','x_2','y','y_1','y_2','z','z_1','z_2'}, ...
%                 {obj.radar_track_set(radar_track_index).X(1),obj.radar_track_set(radar_track_index).X(2),obj.radar_track_set(radar_track_index).X(3), ...
%                 obj.radar_track_set(radar_track_index).X(4),obj.radar_track_set(radar_track_index).X(5),obj.radar_track_set(radar_track_index).X(6), ...
%                 obj.radar_track_set(radar_track_index).X(7),obj.radar_track_set(radar_track_index).X(8),obj.radar_track_set(radar_track_index).X(9)}));
            switch obj.tracker_method
                case 'EKF'
                    jacobian_H = obj.tracker.jacobian_H(obj.track_fusion_set(track_fusion_index).X(1),obj.track_fusion_set(track_fusion_index).X(4),obj.track_fusion_set(track_fusion_index).X(7));
                    S=jacobian_H*(obj.track_fusion_set(track_fusion_index).P + obj.radar_track_set(radar_track_index).P)*jacobian_H' + obj.tracker.R;
                %     ellipse_Volume=pi*Chi*sqrt(det(S));                             
                otherwise
                    % �������˲�����Բ���������
                    S=obj.tracker.H*(obj.track_fusion_set(track_fusion_index).P + obj.radar_track_set(radar_track_index).P)*obj.tracker.H'; %������Բ�����ŵ����   
            end
            d=obj.track_fusion_set(track_fusion_index).X(1:3:9,end)-obj.radar_track_set(radar_track_index).X(1:3:9,end);%Ԥ��״̬������۲�ֵ�Ĳв�  
            D=d'*inv(S)*d;
            if D<0
                disp('error')
            end
            if D<=Chi 
                flag=1;
            else
                flag=0;
            end
        end  
        
        function [costMatrix,flagMatrix] = calCostMatrix(obj,track_fusion_set, radar_track_index_set)
            %������۾��� ��ŷ�Ͼ������
            %���������з���Ϊ���� �з���Ϊ�۲�㼣
            costMatrix = zeros(length(track_fusion_set),length(radar_track_index_set));
            flagMatrix = zeros(length(track_fusion_set),length(radar_track_index_set));
            for i =1 : length(track_fusion_set)
                for j = 1 : length(radar_track_index_set)
                    [D,flag] = obj.Related_gate_track2track(track_fusion_set(i),radar_track_index_set(j),obj.Chi_large);
                    costMatrix(i,j) = D;
                    flagMatrix(i,j) = flag;
                end
            end      
        end
        
        function [fusion_X, fusion_P] = convexCombinationFusion(obj, system_X, system_P, radar_X, radar_P)
            %͹����ں��㷨
            W1 = radar_P * inv(system_P + radar_P);
            I9 = eye(9);
            W2 = I9 - W1;
            fusion_X = W1 * system_X + W2 * radar_X(1:9);
            fusion_P = system_P * inv(system_P + radar_P) * radar_P;
        end
        
        function [fusion_X, fusion_P] = optimalDistributedEstimationFusion(obj, system_X, system_P, radar_X, radar_P, radar_X_predict, radar_P_predict)
            %���ŷֲ�ʽ�����ں�
            fusion_P_inv = inv(system_P) + inv(radar_P) - inv(radar_P_predict);
            fusion_P = inv(fusion_P_inv);
            fusion_X = fusion_P*( inv(system_P) * system_X + inv(radar_P) * radar_X - inv(radar_P_predict) * radar_X_predict);
        end     
        function [public_flag] = judgeIfInThePublicArea(obj,x,y,z)
            %�жϵ�ǰ�����Ƿ��ڶ��״﹫��������
            public_flag = 1;
            radar_index = 1;
            radar_num = size(obj.radar_set,2);
            while public_flag && radar_index <= radar_num
                [X,Y,Z] = enu2ecef(x,y,z,...
                    obj.location_geography(2),...
                    obj.location_geography(1),...
                    obj.location_geography(3),wgs84Ellipsoid);
                [xEast,yNorth,zUp] = ecef2enu(X,Y,Z,...
                    obj.radar_set(radar_index).location_geography(2),...
                    obj.radar_set(radar_index).location_geography(1),...
                    obj.radar_set(radar_index).location_geography(3),wgs84Ellipsoid);   
                [az,elev,slantRange] = enu2aer(xEast,yNorth,zUp);
                if obj.radar_set(radar_index).detection_distance_range(1) <= slantRange &&...
                        obj.radar_set(radar_index).detection_distance_range(2) >= slantRange &&...
                        obj.radar_set(radar_index).detection_azimuth_range(1) <= az &&...
                        obj.radar_set(radar_index).detection_azimuth_range(2) >= az &&...
                        obj.radar_set(radar_index).detection_elevation_range(1) <= elev &&...
                        obj.radar_set(radar_index).detection_elevation_range(2) >= elev  
                    public_flag = 1;
                else
                    public_flag = 0;
                end
                radar_index = radar_index + 1;
            end            
        end
    end

end

