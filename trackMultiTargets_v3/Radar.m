% Author: Shen Kailun
% Date  : 2023-11-14
classdef Radar
    %�״�    
    properties
        location_enu %�״�����
        location_geography %�״ﾭγ��
        detection_distance_range %����̽�ⷶΧ
        detection_azimuth_range %��λ��̽�ⷶΧ
        detection_elevation_range %������̽�ⷶΧ
        tracker_method %'���ٷ���'
        tracker %������
        T %֡����
        distance_measurement_error %����۲����
        azimuth_measurement_error %��λ�۲����
        elevation_measurement_error %�����۲����
        plot_track_set %�㼣����
        track_set %��������
        track_header_set  %����ͷ����
        track_num %��������
        track_header_num%����ͷ����
        plot_track_num%�㼣����
        lambda_NT%��Ŀ��ռ��ܶ�
        lambda_FA%�Ӳ��ռ��ܶ�
        Pd%������
        Pf%�龯����
        trackProbabilityThreshold
        Vmin%Ŀ����С�ٶ� X���� Y����
        Vmax%Ŀ������ٶ� X���� Y����
        PG%�Ÿ�������
        Chi_large%��Ӧ2ά �Ÿ�������PG=1
        Chi_small%��Ӧ2ά �Ÿ�������PG 
        distance_step%�������벽��
        azi_step%������λ�ǲ���
        At_Location_Plot_Track
        track_index_set %��������
        head_index_set %���õ㼣���
        report %�ϱ�����
    end
    
    methods
        function obj = Radar(location_enu, location_geography,...
                detection_distance_range, detection_azimuth_range,...
                detection_elevation_range, tracker_method,...
                T,distance_measurement_error,azimuth_measurement_error,...
                elevation_measurement_error,lambda_NT,lambda_FA,Pd,...
                Pf,trackProbabilityThreshold,Vmin,Vmax,PG,Chi_large,...
                Chi_small,distance_step,azi_step)
            obj.location_enu = location_enu;
            obj.location_geography = location_geography;
            obj.detection_distance_range = detection_distance_range;
            obj.detection_azimuth_range = detection_azimuth_range;
            obj.detection_elevation_range = detection_elevation_range;
            obj.tracker_method = tracker_method;
            obj.T = T;
            obj.distance_measurement_error = distance_measurement_error;
            obj.azimuth_measurement_error = azimuth_measurement_error;
            obj.elevation_measurement_error = elevation_measurement_error;
            obj.lambda_NT = lambda_NT;
            obj.lambda_FA = lambda_FA;
            obj.Pd = Pd;
            obj.Pf = Pf;
            obj.trackProbabilityThreshold = trackProbabilityThreshold;
            obj.Vmin = Vmin;
            obj.Vmax = Vmax;
            obj.PG = PG;
            obj.Chi_large = Chi_large;
            obj.Chi_small = Chi_small;
            obj.distance_step = distance_step;
            obj.azi_step = azi_step;
            obj.track_header_num = 0;
            obj.track_num = 0;  
            
            obj.track_index_set=zeros(1,1000);%Ŀ�꺽����
            for i=1:1000
                obj.track_index_set(i)=i;
            end

            obj.head_index_set=zeros(1,1000);%����ͷ���
            for i=1:1000
                obj.head_index_set(i)=i;
            end            
        end
        
        function [x,value]=find_head(obj,num)
        %���ݺ������Ҷ�Ӧ�ĺ���ͷ
        %input num ��Ҫ�ҵı��غ����ĺ������
        %output x �ñ��غ�����track_header_set����������
        %output value 1:�ɹ��ҵ� 0��δ�ҵ�
            value=0;
            for x=1:obj.track_header_num
                if obj.track_header_set(x).header_index==num
                    value=1;
                    break;
                end
            end
        end       

        function [x,value]=find_track(obj,num)
        %���ݺ������Ҷ�Ӧ�ĺ���
        %input num ��Ҫ�ҵı��غ����ĺ������
        %output x �ñ��غ�����track_header_set����������
        %output value 1:�ɹ��ҵ� 0��δ�ҵ�
            value=0;
            for x=1:obj.track_num
                if obj.track_set(x).track_index==num
                    value=1;
                    break;
                end
            end
        end     
        function [D,flag] = Related_gate_track2ob(obj,track_index,plot_track_index,Chi)
            %��ز����ж�
            %input track_index �������غ����������е����к�
            %input plot_track_index ����ϵͳ�����������е����к�    
            %input Chi ���޳���

            %output D ͳ�ƾ���
            %output flag 1 :��� 0�������
%             % �������˲�����Ӧ����Բ���������
%             S=obj.tracker.H*(obj.track_set(track_index).P)*obj.tracker.H'+ obj.tracker.R; %������Բ�����ŵ����
            % ��չ�������˲�����Ӧ����Բ���������
%             jacobian_H = double(subs(obj.tracker.jacobian_H,{'x','x_1','x_2','y','y_1','y_2','z','z_1','z_2'}, ...
%                 {obj.track_set(track_index).X(1),obj.track_set(track_index).X(2),obj.track_set(track_index).X(3), ...
%                 obj.track_set(track_index).X(4),obj.track_set(track_index).X(5),obj.track_set(track_index).X(6), ...
%                 obj.track_set(track_index).X(7),obj.track_set(track_index).X(8),obj.track_set(track_index).X(9)}));
%             jacobian_H = obj.tracker.jacobian_H(obj.track_set(track_index).X(1), ...
%                 obj.track_set(track_index).X(4), ...
%                 obj.track_set(track_index).X(7));
            jacobian_H = mearsure_jacobian(obj.track_set(track_index).X(1), ...
                obj.track_set(track_index).X(4), ...
                obj.track_set(track_index).X(7));
            S=jacobian_H*(obj.track_set(track_index).P)*jacobian_H'+ obj.tracker.R;

        %     ellipse_Volume=pi*Chi*sqrt(det(S));                             
            d=obj.track_set(track_index).X(1:3:9,end)-obj.plot_track_set(plot_track_index).X;%Ԥ��״̬������۲�ֵ�Ĳв�  

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
        
        function [costMatrix,flagMatrix] = calCostMatrix(obj,clusterSet, obIndexSet)
        %������۾��� ��ŷ�Ͼ������
        %���������з���Ϊ���� �з���Ϊ�۲�㼣
        costMatrix = zeros(length(clusterSet),length(obIndexSet));
        flagMatrix = zeros(length(clusterSet),length(obIndexSet));
        for i =1 : length(clusterSet)
            for j = 1 : length(obIndexSet)
                [D,flag] = obj.Related_gate_track2ob(clusterSet(i),obIndexSet(j),obj.Chi_large);
                costMatrix(i,j) = D;
                flagMatrix(i,j) = flag;
            end
        end
        end        
    end
end

