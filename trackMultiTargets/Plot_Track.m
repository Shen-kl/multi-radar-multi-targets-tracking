% Author: Shen Kailun
% Date  : 2023-11-14
classdef Plot_Track
    %�㼣
    properties
        X %״̬����
        Polar_X %������״̬����
        connection_status %����״̬ 0��δ���� 1������
        zone_index %��������
        plot_track_index %�㼣���
        inDoor %������ز��Ǳ�־λ
    end
    methods
        function obj = Plot_Track(Polar_X, plot_track_index)
            %PLOT_TRACK ��������ʵ��
            if isrow(Polar_X)
                Polar_X =Polar_X';
            end
            obj.Polar_X = Polar_X;
            X = zeros(3,1);
            [X(1),X(2),X(3)] = aer2enu(Polar_X(2),Polar_X(3),Polar_X(1));
            obj.X = X;
            obj.connection_status = 0;
            obj.plot_track_index = plot_track_index;
            obj.inDoor = 0;
        end
        
    end
end

