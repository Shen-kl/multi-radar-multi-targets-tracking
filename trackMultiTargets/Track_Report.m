% Author: Shen Kailun
% Date  : 2023-11-17
classdef Track_Report
    %�ϱ�����
    properties
        X %״̬����
        X_predict %Ԥ��״̬����
        Polar_X %������״̬����
        connection_status %����״̬ 0��δ���� 1������
        track_report_index %����
        inDoor %������ز��Ǳ�־λ
        P %���Э�������
        P_predict %Ԥ�����Э�������
        radar_index %�״���
    end
    
    methods
        function obj = Track_Report(X, X_predict, P, P_predict, track_report_index,radar_index)
            obj.X = X;
            obj.X_predict = X_predict;
            obj.P = P;
            obj.P_predict = P_predict;
            Polar_X = zeros(3,1);
            [Polar_X(2),Polar_X(3),Polar_X(1)] = enu2aer(X(1),X(2),X(3));
            obj.Polar_X = Polar_X;
            obj.connection_status = 0;
            obj.inDoor = 0;
            obj.track_report_index = track_report_index;
            obj.radar_index =  radar_index;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

