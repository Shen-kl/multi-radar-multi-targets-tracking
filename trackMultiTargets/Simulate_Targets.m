%% Simulate_Targets
% Author: Shen Kailun
% Date  : 2023-11-14

%���ܣ�����Ŀ��켣
s = sprintf("====Simulate_Targets====");
disp(s);

%����Ŀ��켣
load("target.mat");
target_num = 4;%Ҫ���ص�Ŀ������

for index = 1 : target_num
    exp = ['target_set{' num2str(index) '}=target' num2str(index) ';'];
    eval(exp);
end

%����������֡��
frame_max = 0;
for index = 1 : target_num
    exp = ['frame_max = max(frame_max, size(target' num2str(index) ', 1))' ';'];
    eval(exp);
end