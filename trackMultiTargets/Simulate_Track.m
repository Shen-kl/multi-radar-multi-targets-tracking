%% Simulate_Track
% Author: Shen Kailun
% Date  : 2023-11-14

%���ܣ� �״����
s = sprintf("====Simulate_Track====");
disp(s);

for radar_index = 1 : radar_num    
    %����
    radar(radar_index) = zone(radar(radar_index));
    %��������
    radar(radar_index) = track_process_GNN(radar(radar_index));
    %������ʼ
    radar(radar_index) = track_init(radar(radar_index));
    %��������
    radar(radar_index) = track_manage(radar(radar_index));
end