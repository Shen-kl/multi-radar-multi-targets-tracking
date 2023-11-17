% Author: Shen Kailun
% Date  : 2023-11-15
function [radar] = track_process_GNN(radar)
%�������ܣ� �������� �����˲� GNN
    distance_step = radar.distance_step;
    azi_step = radar.azi_step;
    distance_max = radar.detection_distance_range(2);
    distance_min = radar.detection_distance_range(1);
    azi_max = radar.detection_azimuth_range(2);
    azi_min = radar.detection_azimuth_range(1);   
     
    locSet = [];
    clusterSet=[];
    for i =1 : radar.track_num
        if radar.track_set(i).track_property ~=2%�ж��Ƿ����սẽ��
            clusterSet= [clusterSet i];
            zone_index = radar.track_set(i).zone_index;
            [locSetTemp] = Sudoku(zone_index, distance_step, azi_step, distance_max,distance_min,...
                azi_max,azi_min);
            locSet = union(locSet,locSetTemp);
        end
    end
    
    if ~isempty(clusterSet) %����ǰ���ڷ��սẽ��
        plot_track_index_set = [];
        for i = 1 :length(locSet) %����ͬ�����Լ����ڷ����ĵ㼣
            for j =1:radar.At_Location_Plot_Track(locSet(i)).plot_track_num
                index = radar.At_Location_Plot_Track(locSet(i)).plot_track_index(j);
                if radar.plot_track_set(index).connection_status == 0%δ��ʹ�ù�
                    plot_track_index_set = [plot_track_index_set index];
                end
            end
        end
        if ~isempty(plot_track_index_set) %����ǰ���ڵ㼣
            plot_track_index_set = linspace(1,radar.plot_track_num,radar.plot_track_num);
            [costMatrix,flagMatrix] = radar.calCostMatrix(clusterSet, plot_track_index_set);
            [row ,loc] = linear_sum_assignment(costMatrix);

            for i =1:length(row) 
                if flagMatrix(i,loc(i)) == 1
                    track_index = clusterSet(i);
                    plot_track_index = plot_track_index_set(loc(i));
                    radar.track_set(track_index).connection_status=1;
                    radar.plot_track_set(plot_track_index).connection_status = 1;
                    [~,flag1] = radar.Related_gate_track2ob(track_index,plot_track_index,radar.Chi_small);%��ز��� С����
                    if flag1 == 0 %δ����С����
                        radar.track_set(track_index).track_quality = radar.track_set(track_index).track_quality + 2 ;
                    else %����С����
                        radar.track_set(track_index).track_quality = radar.track_set(track_index).track_quality + 3 ;
                    end
                    [radar.track_set(track_index).X(:,end), radar.track_set(track_index).P] = radar.tracker.KalmanUpdate(radar.track_set(track_index).X(:,end), radar.track_set(track_index).P, radar.plot_track_set(plot_track_index).X);%����������        
                else
                    track_index = clusterSet(i);
                    radar.track_set(track_index).connection_status=0;
                    radar.track_set(track_index).track_quality = radar.track_set(track_index).track_quality - 3 ;
                end
            end
        else
    for track_index =1 : radar.track_num
        if radar.track_set(track_index).track_property ~=2%�ж��Ƿ����սẽ��
            radar.track_set(track_index).connection_status=0;
            radar.track_set(track_index).track_quality = radar.track_set(track_index).track_quality - 3 ;
        end
    end            
        end
    end
end

