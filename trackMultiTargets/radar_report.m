% Author: Shen Kailun
% Date  : 2023-11-17
function [fusion] = radar_report(fusion,radar,radar_index,origin_latitude,origin_longitude)
    %函数功能：雷达上报
    fusion.radar_track_set = [];
    for track_index = 1 : radar.track_num
        [X,Y,Z] = enu2ecef(radar.track_set(track_index).X(1,end),...
            radar.track_set(track_index).X(4,end),...
            radar.track_set(track_index).X(7,end),...
            radar.location_geography(2),...
            radar.location_geography(1),...
            radar.location_geography(3),wgs84Ellipsoid);
        [xEast,yNorth,zUp] = ecef2enu(X,Y,Z,...
            origin_latitude,...
            origin_longitude,...
            0,wgs84Ellipsoid);        
        [X_predict,Y_predict,Z_predict] = enu2ecef(radar.track_set(track_index).X_predict(1,end),...
            radar.track_set(track_index).X_predict(4,end),...
            radar.track_set(track_index).X_predict(7,end),...
            radar.location_geography(2),...
            radar.location_geography(1),...
            radar.location_geography(3),wgs84Ellipsoid);
        [xEast_predict,yNorth_predict,zUp_predict] = ecef2enu(X_predict,...
            Y_predict,Z_predict,...
            origin_latitude,...
            origin_longitude,...
            0,wgs84Ellipsoid);            
        fusion.radar_track_set = [fusion.radar_track_set Track_Report([xEast ;
            radar.track_set(track_index).X(2:3,end) ;
            yNorth;
            radar.track_set(track_index).X(5:6,end) ;
            zUp;
            radar.track_set(track_index).X(8:9,end)],...
            [xEast_predict ;
            radar.track_set(track_index).X_predict(2:3,end) ;
            yNorth_predict;
            radar.track_set(track_index).X_predict(5:6,end) ;
            zUp_predict;
            radar.track_set(track_index).X_predict(8:9,end)],...            
            radar.track_set(track_index).P,...
            radar.track_set(track_index).P_predict,...
            radar.track_set(track_index).track_index,radar_index)];
    end
end

