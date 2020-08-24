sed = [.5 .5 .5 .0053 .0053 .9894 .5 .0053 .0053 .5 .9894 .5]
r = [2 2 2 3 4 3 4 4 3 2 1 2];

dr = [r(2:end), r(1)] - [r(end), r(1:end-1)];
dc = [2 2 1 1 2 2 2 2 1 1 2 2];
dist = sqrt(dr.^2 + dc.^2);
dsed = [sed(2:end), sed(1)] - [sed(end), sed(1:end-1)];
%dsed = [0, 0, (.0053-.5), (.0053-.5), (.9894-.0053), (.5-.0053), (.0053-.9894), (.0053-.5), (.5-.0053), (.9894-.0053), 0, (.5-.9894)]

angles_across = rad2deg(atan2(dr, dc) + atan2(dsed, dist))

dr = r - [r(end), r(1:end-1)];
dc = [1 1 1 0 1 1 1 1 1 0 1 1];
dist = sqrt(dr.^2 + dc.^2);
dsed = sed - [sed(end), sed(1:end-1)];
%dsed = [0, 0, (.0053-.5), (.0053-.5), (.9894-.0053), (.5-.0053), (.0053-.9894), (.0053-.5), (.5-.0053), (.9894-.0053), 0, (.5-.9894)]

angles_upwind = 45 - rad2deg(atan2(dr, dc) + atan2(dsed, dist))

dr = [r(2:end), r(1)] - r;
dc = [1 1 0 1 1 1 1 1 0 1 1 1];
dist = sqrt(dr.^2 + dc.^2);
dsed = [sed(2:end), sed(1)] - sed;
%dsed = [0, 0, 0, (.0053-.5), 0, (.9894-.0053), (.5-.9894), (.0053-.9894), (.0053-.5), (.5-.0053), (.9894-.0053), 0, (.5-.9894)]

angles_downwind = 45 - rad2deg(atan2(dr, dc) + atan2(dsed, dist))


alphas = [45 45 45 0 55.17 19.09 45 71.52 90 90 70.9 45];
rho = 1020;                     % (kg/m^3) density of salt water
g = 9.8;                        % m/s^2
height = 2;
transport_volume_potential = abs(1.1*rho*g^(3/2)*height^(5/2).*cosd(alphas).*sind(alphas));