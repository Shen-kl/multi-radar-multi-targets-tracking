%% Simulate_Measurements
% Author: Shen Kailun
% Date  : 2023-11-14

%���ܣ���������
s = sprintf("====Simulate_Measurements====");
disp(s);
for radar_index = 1 : radar_num
    plot_track_set = [];
    plot_track_index = 0;
    for target_index = 1 : target_num
        if size(target_set{target_index},1) >= frame_index %��ǰ֡Ŀ�����
                measurement = target_set{target_index}(frame_index,:);%���� ��λ�� ������ �����ԭ��
%                 figure(3);
%                 hold on;
%                 plot(measurement(5),measurement(6),'*');
%                 set (gcf,'position', [1500 300 500 500]);
                
                %�ж��Ƿ����״�۲ⷶΧ�� ����ԭ��ת�����״���������
                [X,Y,Z] = enu2ecef(measurement(5),measurement(8),measurement(11),...
                    origin_latitude,origin_longitude,origin_height,wgs84Ellipsoid);
                [xEast,yNorth,zUp] = ecef2enu(X,Y,Z,...
                    radar(radar_index).location_geography(2),...
                    radar(radar_index).location_geography(1),...
                    radar(radar_index).location_geography(3),wgs84Ellipsoid);
                [az,elev,slantRange] = enu2aer(xEast,yNorth,zUp);
                if az > 180
                    az= az -360;
                end
                measurement = [slantRange az elev];%��ֵ������ ģ������                
                if radar(radar_index).detection_distance_range(1) <= measurement(1) &&...
                        radar(radar_index).detection_distance_range(2) >= measurement(1) &&...
                        radar(radar_index).detection_azimuth_range(1) <= measurement(2) &&...
                        radar(radar_index).detection_azimuth_range(2) >= measurement(2) &&...
                        radar(radar_index).detection_elevation_range(1) <= measurement(3) &&...
                        radar(radar_index).detection_elevation_range(2) >= measurement(3)
                    %��Ŀ���ڹ۲ⷶΧ��

                    plot_track_index= plot_track_index + 1;
                    plot_track = Plot_Track(measurement, plot_track_index);
%                     figure(4);
%                     hold on;
%                     plot(plot_track.X(1),plot_track.X(2),'*');
%                     set (gcf,'position', [2000 300 500 500]);
                    plot_track_set = [plot_track_set; plot_track];                    
                end
        end
    end
    radar(radar_index).plot_track_set = plot_track_set;
    radar(radar_index).plot_track_num = size(plot_track_set, 1);
end