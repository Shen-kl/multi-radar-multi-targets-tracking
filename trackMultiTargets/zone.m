% Author: Shen Kailun
% Date  : 2023-11-14
function [radar] = zone(radar)
%函数功能： 对航迹与点迹进行分区，便于关联
    %航迹预测 分区
    for track_index = 1 : radar.track_num
        [X_predict, P_predict] = radar.tracker.KalmanPredict(...
            radar.track_set(track_index).X(:,end), radar.track_set(track_index).P);
        radar.track_set(track_index).X = [radar.track_set(track_index).X X_predict];
        radar.track_set(track_index).P = P_predict;
        [az,elev,slantRange] = enu2aer(X_predict(1),X_predict(4),X_predict(7));
        if az > 180
            az = az - 360;
        end
        radar.track_set(track_index).Polar_X = [slantRange,az,elev];
        if radar.detection_distance_range(1) <= slantRange &&...
                radar.detection_distance_range(2) >= slantRange &&...
                radar.detection_azimuth_range(1) <= az &&...
                radar.detection_azimuth_range(2) >= az &&...
                radar.detection_elevation_range(1) <= elev &&...
                radar.detection_elevation_range(2) >= elev
            radar.track_set(track_index).zone_index = ...
                attribute_location_number(radar.track_set(track_index).Polar_X,...
                radar.distance_step, radar.azi_step, ...
                radar.detection_distance_range(2),...
                radar.detection_distance_range(1),...
                radar.detection_azimuth_range(1));       
        else
            radar.track_set(track_index).track_property = 2;%若超出探测范围 不再继续跟踪
        end
    end
    
    %航迹头分区
    for track_header_index = 1 : radar.track_header_num
        radar.track_header_set(track_header_index).zone_index = ...
            attribute_location_number(radar.track_header_set(track_header_index).Polar_X,...
            radar.distance_step, radar.azi_step, ...
            radar.detection_distance_range(2),...
            radar.detection_distance_range(1),...
            radar.detection_azimuth_range(1));        
    end    
    %点迹分区
     radar.At_Location_Plot_Track = repmat(At_Location_Plot_Track(),1,...
         ((radar.detection_distance_range(2) - radar.detection_distance_range(1))/radar.distance_step) ...
         *((radar.detection_azimuth_range(2) - radar.detection_azimuth_range(1))/radar.azi_step));
    for plot_track_index = 1 : radar.plot_track_num
        radar.plot_track_set(plot_track_index).zone_index = ...
            attribute_location_number(radar.plot_track_set(plot_track_index).Polar_X,...
            radar.distance_step, radar.azi_step, ...
            radar.detection_distance_range(2),...
            radar.detection_distance_range(1),...
            radar.detection_azimuth_range(1));
        zone_index = radar.plot_track_set(plot_track_index).zone_index;
        radar.At_Location_Plot_Track(zone_index).plot_track_num = ...
            radar.At_Location_Plot_Track(zone_index).plot_track_num + 1;
        radar.At_Location_Plot_Track(zone_index).plot_track_index = [...
            radar.At_Location_Plot_Track(zone_index).plot_track_index ...
            radar.plot_track_set(plot_track_index).plot_track_index];
    end     
end

