function [state ,step] = step3(state)
%     Step3��Cover each column containing a starred zero. If n columns are covered,
%     the starred zeros describe a complete set of unique assignments.
%     In this case, Go to DONE, otherwise, Go to Step 4.
%     
%     ����ÿ�а������Ǻŵ��㡣���������n�У����Ǻŵ����ʾ������Ψһ�������

    marked = (state.marked == 1);
    [row,col]=find(marked == true);
    state.col_uncovered(col) = false;

    if sum(sum(marked,1)) < size(state.C,1)
        step ='step4';
        return ;
    end
    
    step ='None';
    return ;
end

