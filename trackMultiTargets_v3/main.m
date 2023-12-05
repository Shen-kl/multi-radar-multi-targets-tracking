%% ��Ŀ�����
clear all;close all;clc;
dbstop if error
%% ��ʼ��
Simulate_Initialise;

%% ����Ŀ�����켣
Simulate_Targets;

%% ���ݴ���

for frame_index = 1 : frame_max
    s = sprintf(['====frame' num2str(frame_index) '====']);
	disp(s)
    %����Ŀ������
    Simulate_Measurements;
    tic;
    %���״�Ŀ�����
    Simulate_Track;
    toc;
    tic;
    %�ں�
    Simulate_Fusion;
    toc;
    %��ͼ
    Simulate_Plot;
    
    pause(0.1);
end

