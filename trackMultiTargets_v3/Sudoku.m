% Author: Shen Kailun
% Date  : 2023-11-15
function [locSet] = Sudoku(locNum, rangeStep, aziStep, distanceMax, distanceMin, aziMax, aziMin)
%�������ܣ� ��Ŀ�꺽�����ڷ���Ϊ���� ��������Χ���ڵķ����ı�� ������Ŵ�0��ʼ
%����˵����  locNum  Ŀ�꺽�����ڵķ������ 
%           rangeStep ����ά�ķ�������
%           aziStep �����ά�ķ�������
    number = fix((distanceMax-distanceMin)/rangeStep);
    locNumMax = fix((aziMax -  aziMin) / aziStep) * number ;
    locSet = [locNum];
    
    if mod(locNum, number) == 0
        if mod(locNum, number) == number - 1 
            if locNum + number > locNumMax
                locSet = locSet;
            else
                locSet = [locSet (locNum + number)];
            end

            if locNum - number < 0
                locSet = locSet;
            else
                locSet = [locSet (locNum - number) ];
            end            
        else
            locSet = [locSet (locNum + 1)];
            if locNum + number > locNumMax
                locSet = locSet;
            else
                locSet = [locSet (locNum + number) ];
                locSet = [locSet (locNum + number + 1) ];
            end

            if locNum - number < 0
                locSet = locSet;
            else
                locSet = [locSet (locNum - number) ];
                locSet = [locSet (locNum - number + 1)];
            end                
        end
    else
        if mod(locNum, number) == number - 1
            locSet = [locSet (locNum - 1)];
            if locNum + number > locNumMax
                locSet = locSet;
            else
                locSet = [locSet (locNum + number) ];
                locSet = [locSet (locNum + number -1)];
            end

            if locNum - number < 0
                locSet = locSet;
            else
                locSet = [locSet (locNum - number) ];
                locSet = [locSet (locNum - number - 1) ];
            end        
        else
            locSet = [locSet (locNum - 1)];
            locSet = [locSet (locNum + 1)];
            if locNum + number > locNumMax
                locSet = locSet;
            else
                locSet = [locSet (locNum + number + 1)];
                locSet = [locSet (locNum + number) ];
                locSet = [locSet (locNum + number -1)];
            end

            if locNum - number < 0
                locSet = locSet;
            else
                locSet = [locSet (locNum - number + 1)];
                locSet = [locSet (locNum - number) ];
                locSet = [locSet (locNum - number - 1) ];
            end               
        end
    end
    locSet = locSet + 1;
end

