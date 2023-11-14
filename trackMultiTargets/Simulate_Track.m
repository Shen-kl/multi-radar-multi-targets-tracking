%% Simulate_Track
% Author: Shen Kailun
% Date  : 2023-11-14

%功能： 雷达跟踪
s = sprintf("====Simulate_Track====");
disp(s);
for radar_index = 1 : radar_num    
    %分区
    zone(radar_param(radar_index));
    %航迹处理
    track_process;
    %航迹起始
    track_init;
    %航迹管理
    track_manage;
end