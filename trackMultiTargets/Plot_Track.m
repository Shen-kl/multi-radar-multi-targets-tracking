% Author: Shen Kailun
% Date  : 2023-11-14
classdef Plot_Track
    %�㼣
    properties
        X %״̬����
        Polar_X %������״̬����
        connectionStatus %����״̬ 0��δ���� 1������
    end
    methods
        function obj = Plot_Track(X,Polar_X)
            %PLOT_TRACK ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj.X = X;
            obj.connectionStatus = 0;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

