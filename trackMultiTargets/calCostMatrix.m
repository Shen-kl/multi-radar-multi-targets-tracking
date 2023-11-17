function [costMatrix,flagMatrix] = calCostMatrix(tarTracks,clusterSet, measurentSet, obIndexSet,H,Chi_large)
%������۾��� ��ŷ�Ͼ������
%���������з���Ϊ���� �з���Ϊ�۲�㼣
costMatrix = zeros(length(clusterSet),length(obIndexSet));
flagMatrix = zeros(length(clusterSet),length(obIndexSet));
for i =1 : length(clusterSet)
    for j = 1 : length(obIndexSet)
        [D,flag] = Related_gate_track2ob(tarTracks,clusterSet(i),measurentSet,obIndexSet(j),H,Chi_large);
        costMatrix(i,j) = D;
        flagMatrix(i,j) = flag;
    end
end
end

