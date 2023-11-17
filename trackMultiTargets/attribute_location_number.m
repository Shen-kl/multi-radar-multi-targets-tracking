% Author: Shen Kailun
% Date  : 2023-11-14
function [zone_number]=attribute_location_number(PolarX, distanceStep, aziStep, distanceMax, distanceMin, aziMin)
    %����������
    %input  PolarX ������ϵ�µ�����
    %input  rangeStep �����ϵķ�������
    %input  aziStep ��λ���ϵķ�������
    %output number ������� ��0��ʼ
    
    R=PolarX(1);
    azi = PolarX(2); % 180 ~ 180
    number1 = fix((R-distanceMin)/distanceStep);
    number2 = fix((azi - aziMin)/aziStep);
    
    number3 = fix((distanceMax-distanceMin)/distanceStep);
    
    zone_number = number2 * number3 + number1 + 1;
end