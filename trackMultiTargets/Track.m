% Author: Shen Kailun
% Date  : 2023-11-14
classdef Track
    %���� ��
    properties
        X %״̬����
        P %���Э�������
        score %�����÷�
        connectionStatus %����״̬ 0��δ���� 1������ 2��С����
    end
    
    methods
        function obj = Track(X, P)
            %������ʼ��
            obj.X = X;
            obj.P = P;
            obj.score = 1;
            obj.connectionStatus = 0;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

