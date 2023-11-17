% Author: Shen Kailun
% Date  : 2023-11-15
function [radar] = track_process(radar)
%�������ܣ� �������� �����˲� ����ڴ���
    distance_step = radar.distance_step;
    azi_step = radar.azi_step;
    distance_max = radar.detection_distance_range(2);
    distance_min = radar.detection_distance_range(1);
    azi_max = radar.detection_azimuth_range(2);
    azi_min = radar.detection_azimuth_range(1);   
    
    for track_index = 1 : radar.track_num
        if radar.track_set(track_index).track_property ~= 2
            [locSet] = Sudoku(radar.track_set(track_index).zone_index, distance_step, azi_step, distance_max, distance_min, azi_max, azi_min);%����Ҫ��Ѱ�����з������
            DSet = [];
            IndexSet= [];
            for j =1 : length(locSet)%���������
                if radar.At_Location_Plot_Track(locSet(j)).plot_track_num > 0 %����ǰ�����е㼣����
                    for k = 1 : radar.At_Location_Plot_Track(locSet(j)).plot_track_num
                        index_temp=radar.At_Location_Plot_Track(locSet(j)).plot_track_index(k);%��ȡ������
                        if radar.plot_track_set(index_temp).connection_status == 0 %δ����
                            [D,flag] = radar.Related_gate_track2ob(track_index,index_temp,radar.Chi_large);%��ز����ж� ����
                            if flag==1
                                DSet=[DSet D];
                                IndexSet=[IndexSet index_temp];
                            end   
                        end
                    end
                end
            end
            if isempty(DSet) %û�е㼣���벨��
                radar.track_set(track_index).connection_status=0;
                radar.track_set(track_index).track_quality = radar.track_set(track_index).track_quality - 3 ;
            else  %�е㼣���벨��  ȡ����ĵ㼣
                [~ ,loc]=min(DSet);
                radar.track_set(track_index).connection_status=1;
                radar.plot_track_set(IndexSet(loc)).connection_status = 1;
                [~,flag1] = radar.Related_gate_track2ob(track_index,IndexSet(loc),radar.Chi_small);%��ز��� С����
                if flag1 == 0 %δ����С����
                    radar.track_set(track_index).track_quality = radar.track_set(track_index).track_quality + 2 ;
                else %����С����
                    radar.track_set(track_index).track_quality = radar.track_set(track_index).track_quality + 3 ;
                end
                [radar.track_set(track_index).X(:,end), radar.track_set(track_index).P] = radar.tracker.KalmanUpdate(radar.track_set(track_index).X(:,end), radar.track_set(track_index).P, radar.plot_track_set(IndexSet(loc)).X);%����������
            end 
        end
    end

end

