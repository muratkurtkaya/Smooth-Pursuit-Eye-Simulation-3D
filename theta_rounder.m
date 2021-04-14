function [roundedTheta] = theta_rounder(dTheta)
%THETA_ROUNDER rounds the Theta difference to known theta
%values(0.1,0.5,1,5,10,20 and 30)
%   Detailed explanation goes here


if  dTheta <= 0.05 
    dTheta = 0;
elseif  dTheta>0.05 && dTheta<0.2
    dTheta = 0.1;
elseif dTheta>0.2 && dTheta<0.75
    dTheta = 0.5;
elseif dTheta>0.75 && dTheta<2.5
    dTheta = 1;
elseif dTheta>2.5 && dTheta<7.5
    dTheta=5;
elseif dTheta>7.5 && dTheta<15
    dTheta=10;
elseif dTheta>15 && dTheta<25
    dTheta=20;
elseif dTheta>25
    dTheta=30;
end

roundedTheta = dTheta;
end

