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
        function [X_predict, P_predict] = KalmanPredict_specifiedT(obj,X, P, T)
            %�������ܣ� ������Ԥ��
            %X ״̬����
            %P ���Э�������
            if T >= 0
                F=[1 T 1/2*T^2 0 0 0 0 0 0 ;...
                    0 1 T 0 0 0 0 0 0;...
                    0 0 1 0 0 0 0 0 0;...
                    0 0 0 1 T 1/2*T^2 0 0 0;...
                    0 0 0 0 1 T 0 0 0;...
                    0 0 0 0 0 1 0 0 0;...
                    0 0 0 0 0 0 1 T T^2/2;...
                    0 0 0 0 0 0 0 1 T;...
                    0 0 0 0 0 0 0 0 1];%״̬ת�ƾ���   
                X_predict = F * X;
                P_predict = F * P + F' + obj.Q;                 
            else
                T = abs(T);
                F=[1 T 1/2*T^2 0 0 0 0 0 0 ;...
                    0 1 T 0 0 0 0 0 0;...
                    0 0 1 0 0 0 0 0 0;...
                    0 0 0 1 T 1/2*T^2 0 0 0;...
                    0 0 0 0 1 T 0 0 0;...
                    0 0 0 0 0 1 0 0 0;...
                    0 0 0 0 0 0 1 T T^2/2;...
                    0 0 0 0 0 0 0 1 T;...
                    0 0 0 0 0 0 0 0 1];%״̬ת�ƾ���         
                inv_F = inv(F);
                X_predict = inv_F * X;
                P_predict = inv_F * P + inv_F' + obj.Q;                
            end

        end        
    end
end

