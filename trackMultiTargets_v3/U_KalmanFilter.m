classdef U_KalmanFilter
    %KALMANFILTER �������˲���
    properties
        F %F ״̬ת�ƾ���
        H %H �۲����
        Q %Q ������������
        R %R ������������
        W
        nx
        k
    end
    methods
        function obj = U_KalmanFilter(F,H,Q,R)
            %F ״̬ת�ƾ��� H �۲����
            %Q ������������ R ������������
            obj.F = F;
            obj.H = H;
            obj.Q = Q;
            obj.R = R;
            obj.nx = 9;obj.k=-3;
            obj.W=zeros(1,2*obj.nx+1);%Ȩֵ
            obj.W(1)=obj.k/(obj.nx+obj.k);
            obj.W(2:1+2*obj.nx)=1/(2*(obj.nx+obj.k));
        end
        function [X_predict, P_predict, x_forecast_sigma] = U_KalmanPredict(obj,X, P)
            %�������ܣ� ������Ԥ��
            %X ״̬����
            %P ���Э�������
            X1=zeros(obj.nx,2*obj.nx+1);%������
            X1(:,1)=X;
            X1(:,2:1+obj.nx)=repmat(X,1,obj.nx)+chol((obj.nx+obj.k)*P,'lower');
            X1(:,2+obj.nx:1+2*obj.nx)=repmat(X,1,obj.nx)-chol((obj.nx+obj.k)*P,'lower');
            for j=1:2*obj.nx+1
                x_forecast_sigma(:,j) = obj.F * X1(:,j);        %Ԥ��ֵ
            end
            X_predict=sum(obj.W.*x_forecast_sigma,2);%Ԥ��״̬����
            P_predict=zeros(obj.nx,obj.nx);
            for j=1:2*obj.nx+1
               P_predict=P_predict+obj.W(j)*(x_forecast_sigma(:,j)-X_predict)*(x_forecast_sigma(:,j)-X_predict).';
            end
            P_predict=P_predict+obj.Q;%Ԥ�����Э�������
        end
        
        
        function [X_update, P_update] = U_KalmanUpdate(obj,X, P, x_forecast_sigma, Z)
            %�������ܣ� �������˲�
            z1=zeros(3,1);
            y_yuce=[];
            for j=1:2*obj.nx+1
                r = sqrt(x_forecast_sigma(1,j)^2+x_forecast_sigma(4,j)^2+x_forecast_sigma(7,j)^2);
                alpha = atan2(x_forecast_sigma(1,j),x_forecast_sigma(4,j));
                beta =atan(x_forecast_sigma(7,j)/sqrt(x_forecast_sigma(1,j)^2+x_forecast_sigma(4,j)^2));
                y_yuce = [y_yuce [r,alpha,beta]'];
                z1=z1+obj.W(j)*y_yuce(:,end);%Ԥ������
            end
            Pzz=0;
            for j=1:2*obj.nx+1
                Pzz=Pzz+obj.W(j)*(y_yuce(:,j)-z1)*(y_yuce(:,j)-z1).';%Ԥ���������Э�������
            end
            Pzz=Pzz+obj.R;
            Pxz=zeros(obj.nx,1);
            for j=1:2*obj.nx+1
               Pxz=Pxz+obj.W(j)*(x_forecast_sigma(:,j)-X)*(y_yuce(:,j)-z1).';%Ԥ������ ״̬�����������Э�������
            end    
            K=Pxz/(Pzz);%����
            Z(2) = Z(2)*pi/180;Z(3) = Z(3)*pi/180;
            X_update=X+K*(Z-z1);%�˲�
            x=X_update(1);y=X_update(4);z=X_update(7);
            h = [x/(x^2 + y^2 + z^2)^(1/2),0,0,y/(x^2 + y^2 + z^2)^(1/2),0,0,z/(x^2 + y^2 + z^2)^(1/2),0,0;...
                1/(y^2*(x^2/y^2 + 1)),0,0,-x/(y^2*(x^2/y^2 + 1)),0,0,0,0,0;...
                -(x*z)/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(3/2)),0,0,-(y*z)/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(3/2)),0,0,1/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(1/2)),0,0];              
            P_update=P-K*Pzz*K';%�˲�
%             P_update = (eye(length(X)) - K * h) * P * (eye(length(X)) - K * h)' + K * obj.R * K';
        end
        function [X_predict, P_predict, x_forecast_sigma] = U_KalmanPredict_specifiedT(obj,X, P, T)
            %�������ܣ� ������Ԥ��
            %X ״̬����
            %P ���Э�������
            if T >= 0
                %X ״̬����
                %P ���Э�������                
                F=[1 T 1/2*T^2 0 0 0 0 0 0 ;...
                    0 1 T 0 0 0 0 0 0;...
                    0 0 1 0 0 0 0 0 0;...
                    0 0 0 1 T 1/2*T^2 0 0 0;...
                    0 0 0 0 1 T 0 0 0;...
                    0 0 0 0 0 1 0 0 0;...
                    0 0 0 0 0 0 1 T T^2/2;...
                    0 0 0 0 0 0 0 1 T;...
                    0 0 0 0 0 0 0 0 1];%״̬ת�ƾ���   

                X1=zeros(obj.nx,2*obj.nx+1);%������
                X1(:,1)=X;
                X1(:,2:1+obj.nx)=repmat(X,1,obj.nx)+chol((obj.nx+obj.k)*P,'lower');
                X1(:,2+obj.nx:1+2*obj.nx)=repmat(X,1,obj.nx)-chol((obj.nx+obj.k)*P,'lower');
                for j=1:2*obj.nx+1
                    x_forecast_sigma(:,j) = F * X1(:,j);        %Ԥ��ֵ
                end
                X_predict=sum(obj.W.*x_forecast_sigma,2);%Ԥ��״̬����
                P_predict=zeros(obj.nx,obj.nx);
                for j=1:2*obj.nx+1
                   P_predict=P_predict+obj.W(j)*(x_forecast_sigma(:,j)-X_predict)*(x_forecast_sigma(:,j)-X_predict).';
                end
                P_predict=P_predict+obj.Q;%Ԥ�����Э�������               
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
                X1=zeros(obj.nx,2*obj.nx+1);%������
                X1(:,1)=X;
                X1(:,2:1+obj.nx)=repmat(X,1,obj.nx)+chol((obj.nx+obj.k)*P,'lower');
                X1(:,2+obj.nx:1+2*obj.nx)=repmat(X,1,obj.nx)-chol((obj.nx+obj.k)*P,'lower');
                for j=1:2*obj.nx+1
                    x_forecast_sigma(:,j) = inv_F * X1(:,j);        %Ԥ��ֵ
                end
                X_predict=sum(obj.W.*x_forecast_sigma,2);%Ԥ��״̬����
                P_predict=zeros(obj.nx,obj.nx);
                for j=1:2*obj.nx+1
                   P_predict=P_predict+obj.W(j)*(x_forecast_sigma(:,j)-X_predict)*(x_forecast_sigma(:,j)-X_predict).';
                end
                P_predict=P_predict+obj.Q;%Ԥ�����Э�������                  
            end

        end        
    end
end

