%% Simulate_Fusion
% Author: Shen Kailun
% Date  : 2023-11-16

%���ܣ��ںϸ���
s = sprintf("====Simulate_Fusion====");
disp(s);

%����
fusion = zone(fusion);
%��������
fusion = track_process_GNN(fusion);
%������ʼ
fusion = track_init(fusion);
%��������
fusion = track_manage(fusion);