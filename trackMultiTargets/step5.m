function [state ,step] = step5(state)
%     Step5��Construct a series of alternating primed and starred zeros as follows.
%     Let Z0 represent the uncovered primed zero found in Step 4.
%     Let Z1 denote the starred zero in the column of Z0 (if any).
%     Let Z2 denote the primed zero in the row of Z1 (there will always be one).
%     Continue until the series terminates at a primed zero that has no starred
%     zero in its column. Unstar each starred zero of the series, star each
%     primed zero of the series, erase all primes and uncover every line in the
%     matrix. Return to Step 3
% 
% 	��������һϵ�н������ɫ�ͼ��Ǻŵ��㣺
%      ��Z0�����ڲ���4�з��ֵ�δ���ǵ�׼���õ��� 0'��
%      ��Z1��ʾZ0���е��Ǻ��� 0*������еĻ�����
%      ��Z2��ʾZ1���е�׼���õ��� 0'��ʼ��Ϊ1������
%      ����ֱ��0'������û���Ǳ�0*����ֹ�����С�ȡ����ÿ���Ѽ��Ǳ������Ǳ꣬��ϵ���е�ÿ��0'���Ǳ꣬ȥ�����е�'�͸����ߡ� ���ز���3��
%     """
    count = 1;
    path = state.path;
    path(count, 1) = state.Z0_r;
    path(count, 2) = state.Z0_c;

    while (1)
%         # Find the first starred element in the col defined by
%         # the path.
        [M,row] = max(state.marked(:, path(count, 2)) == 1);
        if  state.marked(row, path(count, 2)) ~= 1
%             # Could not find one
            break;
        else
            count = count + 1 ;
            path(count, 1) = row;
            path(count, 2) = path(count - 1, 2);
        end
%         # Find the first prime element in the row defined by the
%         # first path step
        [M,col] = max(state.marked(path(count, 1),:) == 2);
        if state.marked(row, col) ~= 2
            col = size(state.marked,1) ;
        end
        count = count + 1;
        path(count, 1) = path(count - 1, 1);
        path(count, 2) = col;        
    end
%     # Convert paths
    for i =1 : count
        if state.marked(path(i, 1), path(i, 2)) == 1
            state.marked(path(i, 1), path(i, 2)) = 0;
        else
            state.marked(path(i, 1), path(i, 2)) = 1;
        end
    end

    state  = clear_covers(state);
%     # Erase all prime markings
    state.marked(state.marked == 2) = 0;
    state.path = path;
    step ='step3';
    return;
    

end

