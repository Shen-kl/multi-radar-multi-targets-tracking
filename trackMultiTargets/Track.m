% Author: Shen Kailun
% Date  : 2023-11-14
classdef Track
    %���� ��
    properties
        X %״̬����
        P %���Э�������
        Polar_X %������
        track_quality %�����÷�
        connection_status %����״̬ 0��δ���� 1�������ɹ�
        track_index %����
        zone_index
        track_property %0���˲� 1������ 2���ս�
    end
    
    methods
        function obj = Track(X, P, track_index,zone_index,track_quality)
            %������ʼ��
            if isrow(X)
                X = X';
            end
            obj.X = X;
            obj.P = P;
            obj.track_quality = track_quality;
            obj.connection_status = 0;
            obj.zone_index = zone_index;
            obj.track_index = track_index;
            obj.track_property = 0;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

