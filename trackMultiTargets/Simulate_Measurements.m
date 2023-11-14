%% Simulate_Measurements
% Author: Shen Kailun
% Date  : 2023-11-14

%���ܣ���������
s = sprintf("====Simulate_Measurements====");
disp(s);
for radar_index = 1 : radar_num
    measurement_set = [];
    for target_index = 1 : target_num
        if size(target_set{target_index},1) >= frame_index %��ǰ֡Ŀ�����
                measurement = target_set{target_index}(frame_index,:);%���� ��λ�� ������ �����ԭ��
                %�ж��Ƿ����״�۲ⷶΧ��
                [X,Y,Z] = enu2ecef(measurement(5),measurement(6),measurement(7),...
                    origin_latitude,origin_longitude,0,wgs84Ellipsoid);
                [xEast,yNorth,zUp] = ecef2enu(X,Y,Z,...
                    radar_param(radar_index).location_geography(2),...
                    radar_param(radar_index).location_geography(1),...
                    radar_param(radar_index).location_geography(3),wgs84Ellipsoid);
                [az,elev,slantRange] = enu2aer(xEast,yNorth,zUp);
                if az > 180
                    az= az -360;
                end
                if radar_param(radar_index).detection_distance_range(1) <= slantRange &&...
                        radar_param(radar_index).detection_distance_range(2) >= slantRange &&...
                        radar_param(radar_index).detection_azimuth_range(1) <= az &&...
                        radar_param(radar_index).detection_azimuth_range(2) >= az &&...
                        radar_param(radar_index).detection_elevation_range(1) <= elev &&...
                        radar_param(radar_index).detection_elevation_range(2) >= elev
                    %��Ŀ���ڹ۲ⷶΧ��
                    measurement = [slantRange az elev] + [radar_param(radar_index).distance_measurement_error * randn(1,1),...
                                                radar_param(radar_index).azimuth_measurement_error * randn(1,1),...
                                                radar_param(radar_index).elevation_measurement_error * randn(1,1)];%��ֵ������ ģ������
                    plot_track = Plot_Track(measurement);
                    measurement_set = [measurement_set; plot_track];                    
                end
        end
    end
    radar_param(radar_index).measurement_set = measurement_set;
end