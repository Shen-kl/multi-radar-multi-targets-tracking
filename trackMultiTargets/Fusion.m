classdef Fusion
    %FUSSION �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        tracker_method %'���ٷ���'
        tracker %������
        T %֡����
        track_set %��������
        track_num %��������
        Chi_large%��Ӧ2ά �Ÿ�������PG=1
        Chi_small%��Ӧ2ά �Ÿ�������PG         
    end
    
    methods
        function obj = Fusion(inputArg1,inputArg2)
            %FUSSION ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 �˴���ʾ�йش˷�����ժҪ
            %   �˴���ʾ��ϸ˵��
            outputArg = obj.Property1 + inputArg;
        end
    end
end

