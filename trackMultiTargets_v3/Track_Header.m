% Author: Shen Kailun
% Date  : 2023-11-14
classdef Track_Header
    %���� ��
    properties
        header_index
        X %״̬����
        Polar_X %������ 
        track_quality %�����÷�
        connection_status %����״̬ 0��δ���� 1������
        likelihoodProbability %������Ȼ��
        zone_index %������
        inDoor %���벨�ű�־λ
    end
    
    methods
        function obj = Track_Header(header_index,X,Polar_X,...
                zone_index,likelihoodProbability)
            %������ʼ��
            obj.header_index =  header_index;
            if isrow(X)
                X =X';
            end            
            obj.X = X;
            if isrow(Polar_X)
                Polar_X =Polar_X';
            end            
            obj.Polar_X = Polar_X;
            obj.zone_index = zone_index;
            obj.likelihoodProbability = likelihoodProbability;
            obj.track_quality = 1;
            obj.connection_status = 0;
            obj.inDoor = 0;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

