% Author: Shen Kailun
% Date  : 2023-11-17
classdef Track_Fusion
    %�ںϺ���
    properties
        X %״̬����
        P %���Э�������
        Polar_X %������
        track_quality %�����÷�
        connection_status %����״̬ 0��δ���� 1�������ɹ�
        track_fusion_index %����
        zone_index
        track_property %0���˲� 1������ 2���ս�
        connection_table %������
        track_type % 0:���״�1ƥ���� 1�����״�2ƥ���� 3�����״�1��2ƥ����
    end
    
    methods
        function obj = Track_Fusion(X, P, track_fusion_index, track_index,radar_index)
            %������ʼ��
            if isrow(X)
                X = X';
            end
            obj.X = X(1:9);
            obj.P = P;
            obj.connection_status = 0;
            obj.track_fusion_index = track_fusion_index;
            obj.track_property = 0;
            obj.connection_table = ones(1,2) * -1;
            obj.track_quality = ones(1,2) * -1;
            if radar_index == 1
                obj.connection_table(1) = track_index;%��վ��������
                obj.track_type = 0;%���״�1ƥ����
                obj.track_quality(1) = 1;
            else
                obj.connection_table(2) = track_index;
                obj.track_type = 1;%���״�1ƥ����
                obj.track_quality(2) = 1;
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

