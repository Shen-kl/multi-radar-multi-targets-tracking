% Author: Shen Kailun
% Date  : 2023-11-14
classdef KalmanFilter
    %KALMANFILTER �������˲���
    properties
        F %F ״̬ת�ƾ���
        H %H �۲����
        Q %Q ������������
        R %R ������������
    end
    methods
        function obj = KalmanFilter(F,H,Q,R)
            %F ״̬ת�ƾ��� H �۲����
            %Q ������������ R ������������
            obj.F = F;
            obj.H = H;
            obj.Q = Q;
            obj.R = R;
        end
        function [X_predict, P_predict] = KalmanPredict(obj,X, P)
            %�������ܣ� ������Ԥ��
            %X ״̬����
            %P ���Э�������
            X_predict = obj.F * X;
            P_predict = obj.F * P + obj.F' + obj.Q;
        end
        function [X_update, P_update] = KalmanUpdate(obj,X, P, Z)
            %�������ܣ� �������˲�
            Z_pre= obj.H * X;
            K = P *obj.H' /(obj.H * P * obj.H' + obj.R);%�����������
            X_update = X + K * (Z - Z_pre);
            P_update = (eye(length(X)) - K * obj.H) * P * (eye(length(X)) - K * obj.H)' + K * obj.R * K';
        end
    end
end

