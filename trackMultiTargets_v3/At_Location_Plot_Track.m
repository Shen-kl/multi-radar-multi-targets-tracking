% Author: Shen Kailun
% Date  : 2023-11-15
classdef At_Location_Plot_Track
    properties
        plot_track_num
        plot_track_index
    end
    
    methods
        function obj = At_Location_Plot_Track()
            %ATT_LOCATION_PLOT_TRACK ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj.plot_track_num = 0;
            obj.plot_track_index = [];
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

