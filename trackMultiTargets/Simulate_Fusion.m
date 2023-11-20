%% Simulate_Fusion
% Author: Shen Kailun
% Date  : 2023-11-16

%���ܣ��ںϸ���
s = sprintf("====Simulate_Fusion====");
disp(s);

%���δ������վ�ϱ�����
for radar_index = 1 : radar_num
    %�״��ϱ�
    fusion = radar_report(fusion,radar(radar_index),radar_index,origin_latitude,origin_longitude);
    %��������
    %�����ںϺ���
    if fusion.track_fusion_num == 0 %��ǰû���ںϺ���
        fusion = track_init_fusion(fusion,frame_index);
    else %��ǰ�����ںϺ���
        %��������
        fusion = track_process_GNN_fusion(fusion,frame_index,radar_index);
        
        %��������
        fusion = track_manage_fusion(fusion, radar_index);
    end
    

end