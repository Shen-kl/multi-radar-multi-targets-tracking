% Author: Shen Kailun
% Date  : 2023-11-19
function [fusion] = track_manage_fusion(fusion, radar_index)
    %�������ܣ� �������� ���������л�
    DeleteTrackSet = [];
    %ͳ�ƺ�������
    type_0_set = [];
    type_1_set = [];
    type_2_set = [];
    for track_fusion_index = 1 : fusion.track_fusion_num
        switch fusion.track_fusion_set(track_fusion_index).track_type
            case 0
                type_0_set = [type_0_set track_fusion_index];
            case 1
                type_1_set = [type_1_set track_fusion_index];
            case 2
                type_2_set = [type_2_set track_fusion_index];
        end
    end     

    %��������2����
    for type_2_index = 1 : size(type_2_set,2)
        if fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) > 12
            fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) = 12;
        elseif fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index)< 0
            %�л�Ϊ��������
            fusion.track_fusion_set(type_2_set(type_2_index)).connection_table(radar_index) = -1;
            fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) = -1;
            tmp = [1,0];
            fusion.track_fusion_set(type_2_set(type_2_index)).track_type = tmp(radar_index);
        end
    end
    
    switch radar_index
        case 1
            %��������0����
            for type_0_index = 1 : size(type_0_set,2)
                if fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) > 12
                    fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) = 12;
                elseif fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index)< 0
                    %ɾ������
                    DeleteTrackSet = [DeleteTrackSet type_0_set(type_0_index)];
                end
            end     
            %��������1����
            for type_1_index = 1 : size(type_1_set,2)
                if fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(1) > 0
                    %�����л�
                    fusion.track_fusion_set(type_1_set(type_1_index)).track_type = 2;
                end
                if fusion.track_fusion_set(type_1_set(type_1_index)).aloneCnt == 6 %������֡û������
                    %ɾ������
                    DeleteTrackSet = [DeleteTrackSet type_1_set(type_1_index)];             
                end
            end                  
        case 2
            %��������0����
            for type_0_index = 1 : size(type_0_set,2)
                if fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(2) > 0
                    %�����л�
                    fusion.track_fusion_set(type_0_set(type_0_index)).track_type = 2;
                end
                if fusion.track_fusion_set(type_0_set(type_0_index)).aloneCnt == 6 %������֡û������
                    %ɾ������
                    DeleteTrackSet = [DeleteTrackSet type_0_set(type_0_index)];             
                end                
            end     
            %��������1����
            for type_1_index = 1 : size(type_1_set,2)
                if fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) > 12
                    fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) = 12;
                elseif fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index)< 0
                    %ɾ������
                    DeleteTrackSet = [DeleteTrackSet type_1_set(type_1_index)];
                end
            end              
    end

    %ɾ�������͵ĺ���
    if ~isempty(DeleteTrackSet)
        fusion.track_fusion_set(DeleteTrackSet) =[];
    end
    
    fusion.track_fusion_num = size(fusion.track_fusion_set,2);%�����ںϺ�������
end

