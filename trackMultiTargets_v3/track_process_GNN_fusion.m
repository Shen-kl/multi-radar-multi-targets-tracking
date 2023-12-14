% Author: Shen Kailun
% Date  : 2023-11-17
function [fusion] = track_process_GNN_fusion(fusion, frame_index, radar_index)
    %ʱ����׼ ����Ԥ��
    if frame_index ~= fusion.system_frame_index
        for track_fusion_index = 1 : fusion.track_fusion_num
            switch fusion.tracker_method
                case 'KF' 
                    [X_predict, P_predict] = fusion.tracker.KalmanPredict_specifiedT(...
                        fusion.track_fusion_set(track_fusion_index).X(:,end),...
                        fusion.track_fusion_set(track_fusion_index).P,...
                        fusion.T * (frame_index - fusion.system_frame_index));
                case 'EKF'
                     [X_predict, P_predict] = fusion.tracker.ExtentedKalmanPredict_specifiedT(...
                        fusion.track_fusion_set(track_fusion_index).X(:,end),...
                        fusion.track_fusion_set(track_fusion_index).P,...
                        fusion.T * (frame_index - fusion.system_frame_index));
                case 'UKF'
                    [X_predict, P_predict, x_forecast_sigma] = radar.tracker.U_KalmanPredict_specifiedT(...
                        radar.track_set(track_index).X(:,end), radar.track_set(track_index).P);    
                    fusion.track_fusion_set(track_fusion_index).x_forecast_sigma = x_forecast_sigma;                    
                case 'Singer'
                    [X_predict, P_predict] = fusion.tracker.SingerPredict_specifiedT(...
                        fusion.track_fusion_set(track_fusion_index).X(:,end),...
                        fusion.track_fusion_set(track_fusion_index).P,...
                        fusion.T * (frame_index - fusion.system_frame_index));                    
            end
            fusion.track_fusion_set(track_fusion_index).X = [...
                fusion.track_fusion_set(track_fusion_index).X X_predict];
            fusion.track_fusion_set(track_fusion_index).P = P_predict;
        end
        fusion.system_frame_index = frame_index;
    end
    if isempty(fusion.radar_track_set)
       %����վ����Ϊ��
       %����ϵͳ���� ��Ӧ��վ�۷�
        for track_fusion_index = 1 : fusion.track_fusion_num
            fusion.track_fusion_set(track_fusion_index).track_quality(radar_index) = ...
                fusion.track_fusion_set(track_fusion_index).track_quality(radar_index) - 3;
        end        
    else
        %ͳ�ƺ�������
        type_0_set = [];
        type_1_set = [];
        type_2_set = [];
        for track_fusion_index = 1 : fusion.track_fusion_num
            switch fusion.track_fusion_set(track_fusion_index).track_type
                case 0
                    type_0_set = [type_0_set track_fusion_index];
                case 1
                    type_1_set = [type_1_set track_fusion_index];
                case 2
                    type_2_set = [type_2_set track_fusion_index];
            end
        end        
        %���ȴ�������Ϊ2�ĺ���
        if ~isempty(type_2_set)
            for type_2_index = 1 : size(type_2_set,2)
                %ȷ�ϵ�ǰ֡ �״��Ƿ��⵽��Ŀ��
                [loc, value] = fusion.find_track(fusion.track_fusion_set(type_2_set(type_2_index)).connection_table(radar_index));
                if value == 0
                    %�������� ����ΪĿ����ʧ ��Ϊ��������
                    fusion.track_fusion_set(type_2_set(type_2_index)).connection_status = 0;
                    fusion.track_fusion_set(type_2_set(type_2_index)).connection_table(radar_index) = -1;
                    fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) = -1;
                else
                    %ȷ���Ƿ������С����
                    fusion.track_fusion_set(type_2_set(type_2_index)).connection_status = 1;
                    fusion.radar_track_set(loc).connection_status = 1;
                    
                    [~,flag] = fusion.Related_gate_track2track(type_2_set(type_2_index),loc,fusion.Chi_large);
                    if flag == 0
                        %û���������
                        fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) = ...
                            fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) - 3;
                    else
                        %������� �ж�С����
                        [~,flag1] = fusion.Related_gate_track2track(type_2_set(type_2_index),loc,fusion.Chi_small);
                        if flag1 == 0
                            %û������С����
                            fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) = ...
                                fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) + 2;                            
                        else
                            %����С����
                            fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) = ...
                                fusion.track_fusion_set(type_2_set(type_2_index)).track_quality(radar_index) + 3;                            
                        end
                    end
                    
                    %�ں�
%                     [fusion_X, fusion_P] = fusion.convexCombinationFusion(fusion.track_fusion_set(type_2_set(type_2_index)).X(:,end),...
%                         fusion.track_fusion_set(type_2_set(type_2_index)).P,...
%                         fusion.radar_track_set(loc).X, fusion.radar_track_set(loc).P);
                    [fusion_X, fusion_P] = fusion.optimalDistributedEstimationFusion(fusion.track_fusion_set(type_2_set(type_2_index)).X(:,end),...
                        fusion.track_fusion_set(type_2_set(type_2_index)).P,...
                        fusion.radar_track_set(loc).X, fusion.radar_track_set(loc).P,...
                        fusion.radar_track_set(loc).X_predict, fusion.radar_track_set(loc).P_predict);                    
                    fusion.track_fusion_set(type_2_set(type_2_index)).X(:,end) = fusion_X;
                    fusion.track_fusion_set(type_2_set(type_2_index)).P = fusion_P;
                end
            end
        end

        switch radar_index
            case 1
                %��ǰ���״�1 ������
                %���ȴ�������Ϊ0�ĺ���
                if ~isempty(type_0_set)
                    for type_0_index = 1 : size(type_0_set,2)
                        %ȷ�ϵ�ǰ֡ �״��Ƿ��⵽��Ŀ��
                        [loc, value] = fusion.find_track(fusion.track_fusion_set(type_0_set(type_0_index)).connection_table(radar_index));
                        if value == 0
                            %�������� ����ΪĿ����ʧ ��Ϊ��������
                            fusion.track_fusion_set(type_0_set(type_0_index)).connection_status = 1;
                            fusion.track_fusion_set(type_0_set(type_0_index)).connection_table(radar_index) = -1;
                            fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) = -1;
                        else
                            %ȷ���Ƿ������С����
                            fusion.track_fusion_set(type_0_set(type_0_index)).connection_status = 1;
                            fusion.radar_track_set(loc).connection_status = 1;

                            [~,flag] = fusion.Related_gate_track2track(type_0_set(type_0_index),loc,fusion.Chi_large);
                            if flag == 0
                                %û���������
                                fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) = ...
                                    fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) - 3;
                            else
                                %������� �ж�С����
                                [~,flag1] = fusion.Related_gate_track2track(type_0_set(type_0_index),loc,fusion.Chi_small);
                                if flag1 == 0
                                    %û������С����
                                    fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) = ...
                                        fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) + 2;                            
                                else
                                    %����С����
                                    fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) = ...
                                        fusion.track_fusion_set(type_0_set(type_0_index)).track_quality(radar_index) + 3;                            
                                end
                            end
                            %�ں�
%                             [fusion_X, fusion_P] = fusion.convexCombinationFusion(fusion.track_fusion_set(type_0_set(type_0_index)).X(:,end),...
%                                 fusion.track_fusion_set(type_0_set(type_0_index)).P,...
%                                 fusion.radar_track_set(loc).X, fusion.radar_track_set(loc).P);
                            [fusion_X, fusion_P] = fusion.optimalDistributedEstimationFusion(fusion.track_fusion_set(type_0_set(type_0_index)).X(:,end),...
                                fusion.track_fusion_set(type_0_set(type_0_index)).P,...
                                fusion.radar_track_set(loc).X, fusion.radar_track_set(loc).P,...
                                fusion.radar_track_set(loc).X_predict, fusion.radar_track_set(loc).P_predict);   
                            fusion.track_fusion_set(type_0_set(type_0_index)).X(:,end) = fusion_X;
                            fusion.track_fusion_set(type_0_set(type_0_index)).P = fusion_P;                            
                        end
                    end
                end      
                
                %��������Ϊ1�ĺ��� ʹ��GNN�㷨����δ���ӵķ�վ����
                if ~isempty(type_1_set)
                    %�жϵ�ǰ����δ�����ķ�վ����
                    radar_track_index_set = [];
                    for radar_track_index = 1 : size(fusion.radar_track_set,2)
                        if fusion.radar_track_set(radar_track_index).connection_status == 0
                            radar_track_index_set = [radar_track_index_set ,...
                                radar_track_index];
                        end
                    end
                    if isempty(radar_track_index_set)
                        %����ǰ�����ڿɷ���ķ�վ����
                        for type_1_index = 1 : size(type_1_set,2)
                            %�жϵ�ǰ�����Ƿ��ڶ��״﹫��������
                            [public_flag] = fusion.judgeIfInThePublicArea(fusion.track_fusion_set(type_1_set(type_1_index)).X(1,end),...
                                    fusion.track_fusion_set(type_1_set(type_1_index)).X(4,end),...
                                    fusion.track_fusion_set(type_1_set(type_1_index)).X(7,end));
                            if public_flag ==0 %���ڹ�������
                                fusion.track_fusion_set(type_1_set(type_1_index)).aloneCnt = 0;
                                fusion.track_fusion_set(type_1_set(type_1_index)).connection_status = 1;
                            else
                                %��������δƥ������ɾ��
                                fusion.track_fusion_set(type_1_set(type_1_index)).aloneCnt = fusion.track_fusion_set(type_1_set(type_1_index)).aloneCnt + 1;
                            end
                        end
                    else
                        %GNN ��������
                        all_set = [];
                        for type_2_index = 1 : size(type_2_set,2)
                            if fusion.track_fusion_set(type_2_set(type_2_index)).connection_status == 0 %��ǰ֡û�к�����ر��еĺ���
                                all_set = [all_set type_2_set(type_2_index)];
                            end
                        end
                        all_set =[all_set type_1_set];
                        [costMatrix,flagMatrix] = fusion.calCostMatrix(all_set, radar_track_index_set);%������۾��� ���۾����д洢ͳ�ƾ���
                        [row ,loc] = linear_sum_assignment(costMatrix); 
                        
                        for i =1:length(row) 
                            if flagMatrix(row(i),loc(i)) == 1 %�ڴ����� ���� �ں�
                                track_fusion_index = all_set(row(i));
                                radar_track_index = radar_track_index_set(loc(i));
                                fusion.track_fusion_set(track_fusion_index).connection_status=1;%�����ɹ�
                                fusion.radar_track_set(radar_track_index).connection_status = 1;%�����ɹ�
                                fusion.track_fusion_set(track_fusion_index).connection_table(radar_index) = fusion.radar_track_set(radar_track_index).track_report_index;%���������������
                                fusion.track_fusion_set(track_fusion_index).track_quality(radar_index) = 1;%��ʼ����������
                                %�ں�
%                                 [fusion_X, fusion_P] = fusion.convexCombinationFusion(fusion.track_fusion_set(track_fusion_index).X(:,end),...
%                                     fusion.track_fusion_set(track_fusion_index).P,...
%                                     fusion.radar_track_set(radar_track_index).X, fusion.radar_track_set(radar_track_index).P);
                                [fusion_X, fusion_P] = fusion.optimalDistributedEstimationFusion(fusion.track_fusion_set(track_fusion_index).X(:,end),...
                                    fusion.track_fusion_set(track_fusion_index).P,...
                                    fusion.radar_track_set(radar_track_index).X, fusion.radar_track_set(radar_track_index).P,...
                                    fusion.radar_track_set(radar_track_index).X_predict, fusion.radar_track_set(radar_track_index).P_predict);   
                                fusion.track_fusion_set(track_fusion_index).X(:,end) = fusion_X;
                                fusion.track_fusion_set(track_fusion_index).P = fusion_P;          
                            else
                                track_fusion_index = all_set(row(i));
                                %�жϵ�ǰ�����Ƿ��ڶ��״﹫��������
                                [public_flag] = fusion.judgeIfInThePublicArea(fusion.track_fusion_set(track_fusion_index).X(1,end),...
                                        fusion.track_fusion_set(track_fusion_index).X(4,end),...
                                        fusion.track_fusion_set(track_fusion_index).X(7,end));
                                if public_flag ==0 %���ڹ�������
                                    fusion.track_fusion_set(track_fusion_index).aloneCnt = 0;
                                    fusion.track_fusion_set(track_fusion_index).connection_status = 1;
                                else
                                    %��������δƥ������ɾ��
                                    fusion.track_fusion_set(track_fusion_index).aloneCnt = fusion.track_fusion_set(track_fusion_index).aloneCnt + 1;
                                end
                            end
                        end 
                        
                    %����δ������ĺ���
                    uncorr = setdiff(all_set, row);%���clusterSet�� ����row�е�Ԫ��
                    for index = 1 : length(uncorr)
                        track_fusion_index = uncorr(index);
                        %�жϵ�ǰ�����Ƿ��ڶ��״﹫��������
                        [public_flag] = fusion.judgeIfInThePublicArea(fusion.track_fusion_set(track_fusion_index).X(1,end),...
                                fusion.track_fusion_set(track_fusion_index).X(4,end),...
                                fusion.track_fusion_set(track_fusion_index).X(7,end));
                        if public_flag ==0 %���ڹ�������
                            fusion.track_fusion_set(track_fusion_index).aloneCnt = 0;
                            fusion.track_fusion_set(track_fusion_index).connection_status = 1;
                        else
                            %��������δƥ������ɾ��
                            fusion.track_fusion_set(track_fusion_index).aloneCnt = fusion.track_fusion_set(track_fusion_index).aloneCnt + 1;
                        end              
                    end    
                    
                    end
                end                   
            case 2
                %��ǰ���״�2 ������
                %���ȴ�������Ϊ1�ĺ���
                if ~isempty(type_1_set)
                    for type_1_index = 1 : size(type_1_set,2)
                        %ȷ�ϵ�ǰ֡ �״��Ƿ��⵽��Ŀ��
                        [loc, value] = fusion.find_track(fusion.track_fusion_set(type_1_set(type_1_index)).connection_table(radar_index));
                        if value == 0
                            %�������� ����ΪĿ����ʧ ��Ϊ��������
                            fusion.track_fusion_set(type_1_set(type_1_index)).connection_status = 1;
                            fusion.track_fusion_set(type_1_set(type_1_index)).connection_table(radar_index) = -1;
                            fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) = -1;
                        else
                            %ȷ���Ƿ������С����
                            fusion.track_fusion_set(type_1_set(type_1_index)).connection_status = 1;
                            fusion.radar_track_set(loc).connection_status = 1;

                            [~,flag] = fusion.Related_gate_track2track(type_1_set(type_1_index),loc,fusion.Chi_large);
                            if flag == 0
                                %û���������
                                fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) = ...
                                    fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) - 3;
                            else
                                %������� �ж�С����
                                [~,flag1] = fusion.Related_gate_track2track(type_1_set(type_1_index),loc,fusion.Chi_small);
                                if flag1 == 0
                                    %û������С����
                                    fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) = ...
                                        fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) + 2;                            
                                else
                                    %����С����
                                    fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) = ...
                                        fusion.track_fusion_set(type_1_set(type_1_index)).track_quality(radar_index) + 3;                            
                                end
                            end
                            %�ں�
%                             [fusion_X, fusion_P] = fusion.convexCombinationFusion(fusion.track_fusion_set(type_1_set(type_1_index)).X(:,end),...
%                                 fusion.track_fusion_set(type_1_set(type_1_index)).P,...
%                                 fusion.radar_track_set(loc).X, fusion.radar_track_set(loc).P);
                            [fusion_X, fusion_P] = fusion.optimalDistributedEstimationFusion(fusion.track_fusion_set(type_1_set(type_1_index)).X(:,end),...
                                fusion.track_fusion_set(type_1_set(type_1_index)).P,...
                                fusion.radar_track_set(loc).X, fusion.radar_track_set(loc).P,...
                                fusion.radar_track_set(loc).X_predict, fusion.radar_track_set(loc).P_predict);   
                            fusion.track_fusion_set(type_1_set(type_1_index)).X(:,end) = fusion_X;
                            fusion.track_fusion_set(type_1_set(type_1_index)).P = fusion_P;                            
                        end
                    end
                end      
                
                %��������Ϊ0�ĺ��� ʹ��GNN�㷨����δ���ӵķ�վ����
                if ~isempty(type_0_set)
                    %�жϵ�ǰ����δ�����ķ�վ����
                    radar_track_index_set = [];
                    for radar_track_index = 1 : size(fusion.radar_track_set,2)
                        if fusion.radar_track_set(radar_track_index).connection_status == 0
                            radar_track_index_set = [radar_track_index_set ,...
                                radar_track_index];
                        end
                    end
                    if isempty(radar_track_index_set)
                        %����ǰ�����ڿɷ���ķ�վ����
                        for type_0_index = 1 : size(type_0_set,2)
                            %�жϵ�ǰ�����Ƿ��ڶ��״﹫��������
                            [public_flag] = fusion.judgeIfInThePublicArea(fusion.track_fusion_set(type_0_set(type_0_index)).X(1,end),...
                                    fusion.track_fusion_set(type_0_set(type_0_index)).X(4,end),...
                                    fusion.track_fusion_set(type_0_set(type_0_index)).X(7,end));
                            if public_flag ==0 %���ڹ�������
                                fusion.track_fusion_set(type_0_set(type_0_index)).aloneCnt = 0;
                                fusion.track_fusion_set(type_0_set(type_0_index)).connection_status = 1;
                            else
                                %��������δƥ������ɾ��
                                fusion.track_fusion_set(type_0_set(type_0_index)).aloneCnt = fusion.track_fusion_set(type_0_set(type_0_index)).aloneCnt + 1;
                            end
                        end
                    else
                        %GNN ��������
                        all_set = [];
                        for type_2_index = 1 : size(type_2_set,2)
                            if fusion.track_fusion_set(type_2_set(type_2_index)).connection_status == 0 %��ǰ֡û�к�����ر��еĺ���
                                all_set = [all_set type_2_set(type_2_index)];
                            end
                        end
                        all_set =[all_set type_0_set];
                        [costMatrix,flagMatrix] = fusion.calCostMatrix(all_set, radar_track_index_set);%������۾��� ���۾����д洢ͳ�ƾ���
                        [row ,loc] = linear_sum_assignment(costMatrix); 
                        
                        for i =1:length(row) 
                            if flagMatrix(row(i),loc(i)) == 1 %�ڴ����� ���� �ں�
                                track_fusion_index = all_set(row(i));
                                radar_track_index = radar_track_index_set(loc(i));
                                fusion.track_fusion_set(track_fusion_index).connection_status=1;%�����ɹ�
                                fusion.radar_track_set(radar_track_index).connection_status = 1;%�����ɹ�
                                fusion.track_fusion_set(track_fusion_index).connection_table(radar_index) = fusion.radar_track_set(radar_track_index).track_report_index;%���������������
                                fusion.track_fusion_set(track_fusion_index).track_quality(radar_index) = 1;%��ʼ����������
                                %�ں�
%                                 [fusion_X, fusion_P] = fusion.convexCombinationFusion(fusion.track_fusion_set(track_fusion_index).X(:,end),...
%                                     fusion.track_fusion_set(track_fusion_index).P,...
%                                     fusion.radar_track_set(radar_track_index).X, fusion.radar_track_set(radar_track_index).P);
                                [fusion_X, fusion_P] = fusion.optimalDistributedEstimationFusion(fusion.track_fusion_set(track_fusion_index).X(:,end),...
                                    fusion.track_fusion_set(track_fusion_index).P,...
                                    fusion.radar_track_set(radar_track_index).X, fusion.radar_track_set(radar_track_index).P,...
                                    fusion.radar_track_set(radar_track_index).X_predict, fusion.radar_track_set(radar_track_index).P_predict);   
                                fusion.track_fusion_set(track_fusion_index).X(:,end) = fusion_X;
                                fusion.track_fusion_set(track_fusion_index).P = fusion_P;          
                            else
                                track_fusion_index = all_set(row(i));
                                %�жϵ�ǰ�����Ƿ��ڶ��״﹫��������
                                [public_flag] = fusion.judgeIfInThePublicArea(fusion.track_fusion_set(track_fusion_index).X(1,end),...
                                        fusion.track_fusion_set(track_fusion_index).X(4,end),...
                                        fusion.track_fusion_set(track_fusion_index).X(7,end));
                                if public_flag ==0 %���ڹ�������
                                    fusion.track_fusion_set(track_fusion_index).aloneCnt = 0;
                                    fusion.track_fusion_set(track_fusion_index).connection_status = 1;
                                else
                                    %��������δƥ������ɾ��
                                    fusion.track_fusion_set(track_fusion_index).aloneCnt = fusion.track_fusion_set(track_fusion_index).aloneCnt + 1;
                                end
                            end
                        end   
                        %����δ������ĺ���
                        uncorr = setdiff(all_set, row);%���clusterSet�� ����row�е�Ԫ��
                        for index = 1 : length(uncorr)
                            track_fusion_index = uncorr(index);
                            %�жϵ�ǰ�����Ƿ��ڶ��״﹫��������
                            [public_flag] = fusion.judgeIfInThePublicArea(fusion.track_fusion_set(track_fusion_index).X(1,end),...
                                    fusion.track_fusion_set(track_fusion_index).X(4,end),...
                                    fusion.track_fusion_set(track_fusion_index).X(7,end));
                            if public_flag ==0 %���ڹ�������
                                fusion.track_fusion_set(track_fusion_index).aloneCnt = 0;
                                fusion.track_fusion_set(track_fusion_index).connection_status = 1;
                            else
                                %��������δƥ������ɾ��
                                fusion.track_fusion_set(track_fusion_index).aloneCnt = fusion.track_fusion_set(track_fusion_index).aloneCnt + 1;
                            end              
                        end                            
                    end
                end                       
        end
        
        %��δ�����ķ�վ������Ϊϵͳ������ʼ
        radar_track_index_set = [];
        for radar_track_index = 1 : size(fusion.radar_track_set,2)
            if fusion.radar_track_set(radar_track_index).connection_status == 0
                radar_track_index_set = [radar_track_index_set ,...
                    radar_track_index];
            end
        end       
        if ~isempty(radar_track_index_set)
            num = fusion.track_fusion_num;
            for track_index = 1 : size(radar_track_index_set,2)
                radar_track = fusion.radar_track_set(radar_track_index_set(track_index));
                fusion.track_fusion_set = [fusion.track_fusion_set,...
                    Track_Fusion(radar_track.X, radar_track.P, ...
                    num + track_index,...
                    radar_track.track_report_index, radar_index)];
            end            
        end
    end   
end

