% Author: Shen Kailun
% Date  : 2023-11-18
function [fusion] = track_init_fusion(fusion, frame_index)
    %�����վ�ϱ����� ����վ������Ϊϵͳ����
    if ~isempty(fusion.radar_track_set)
        for track_index = 1 : size(fusion.radar_track_set,2)
            radar_track_set = fusion.radar_track_set(track_index);
            fusion.track_fusion_set = [fusion.track_fusion_set,...
                Track_Fusion(radar_track_set.X, radar_track_set.P, ...
                track_index, radar_track_set.track_report_index,...
                radar_track_set.radar_index)];
        end
        fusion.track_fusion_num = size(fusion.radar_track_set,2);
        fusion.system_frame_index = frame_index;%��ʼ��ϵͳʱ��
    else
       return;
    end
end

