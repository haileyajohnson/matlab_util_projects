function [ angle ] = FindWaveAngle( U, A )
% INPUTS:
%   U: fraction stable, low angle waves
%   A: asymmetry (fraction approaching from the left)
% OUTPUT:
%   angle: wave angle in radians

angle = rand() * (pi/4);    % random angle 0 - pi/4
if rand() >= U          % random variable determining above or below 45 degrees 
    angle = angle + pi/4;
end
if rand() >= A              % random variable determining direction of approach
    angle = -angle;
end

end