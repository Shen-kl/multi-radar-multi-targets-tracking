%% ��Ŀ�����
clear all;close all;clc;
%% ��ʼ��
Simulate_Initialise;

%% ����Ŀ�����켣
Simulate_Targets;

%% ���ݴ���

for frame_index = 1 : frame_max
    %����Ŀ������
    Simulate_Measurements;
    
    %���״�Ŀ�����
    
    
    %�ں�
    Simulate_Fusion;
    
    %��ͼ

end

