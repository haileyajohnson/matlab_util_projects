close all; clear all;
%%inputs
delta_volume = 100000;
cross_shore_pos = 20;
local_shoreline_angle = 90;
%%
c_cell_size = 100;
c_grid_size = 40;

c_shelf_slope = 0.001;
c_shoreface_slope = 0.01;
c_cross_shore_reference_pos = 10;
c_shelf_depth_at_reference_pos = 10;
c_min_shelf_depth_at_closure = 10;

max_dist = c_cell_size*c_grid_size;
cross_shore_distances = (0:c_cell_size:max_dist);
long_shore_distances = (-max_dist/2: c_cell_size: max_dist/2);
continental_shelf = -c_shelf_slope*(cross_shore_distances-(c_cross_shore_reference_pos*c_cell_size)) - c_shelf_depth_at_reference_pos;
shelf_z = repmat(continental_shelf, length(continental_shelf), 1);

hfig_profile = figure();
set(hfig_profile, 'Position', [100, 200, 1200, 600]);

surf(cross_shore_distances, long_shore_distances, shelf_z, 'edgecolor', 'none');
hold on
z = zeros(length(cross_shore_distances));
surf(cross_shore_distances, long_shore_distances, z, 'FaceColor', [0 1 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none');

x = long_shore_distances*tand(local_shoreline_angle) + cross_shore_pos*c_cell_size;
x(x < 0 | x > max_dist) = NaN;
plot3(x, long_shore_distances, zeros(1, length(x)), 'k--', 'linewidth', 2);

%% Eq 1
local_shelf_depth = c_shelf_depth_at_reference_pos + ((cross_shore_pos - c_cross_shore_reference_pos)*c_cell_size*c_shelf_slope);
plot3([cross_shore_pos*c_cell_size, cross_shore_pos*c_cell_size], [0 0], [0 -local_shelf_depth], 'b-.', 'linewidth', 2);

%% Eq 2
effective_slope = c_shoreface_slope-(cosd(local_shoreline_angle)*c_shelf_slope);
cross_shore_distance_to_closure = local_shelf_depth/effective_slope;
% plot3([cross_shore_pos*c_cell_size, cross_shore_pos*c_cell_size+cross_shore_distance_to_closure], [0 0 ], [0 0], 'm--', 'linewidth', 2);

%% Eq 3
cross_shore_pos_of_closure = (cross_shore_pos*c_cell_size + cosd(local_shoreline_angle)*cross_shore_distance_to_closure);
long_shore_pos_of_closure = sind(local_shoreline_angle)*(-cross_shore_distance_to_closure);
plot3([cross_shore_pos*c_cell_size, cross_shore_pos_of_closure], [0 long_shore_pos_of_closure], [0 0], 'm-', 'linewidth', 1);
%plot3([cross_shore_pos_of_closure, cross_shore_pos*c_cell_size + cross_shore_distance_to_closure], [long_shore_pos_of_closure 0], [0 0], 'm-', 'linewidth', 1);

%% Eq 4

shelf_depth_at_closure = c_shelf_depth_at_reference_pos +(cross_shore_pos_of_closure - c_cross_shore_reference_pos*c_cell_size)*c_shelf_slope;
if shelf_depth_at_closure < c_min_shelf_depth_at_closure
    shelf_depth_at_closure = c_min_shelf_depth_at_closure;
end

projected_x = cross_shore_pos_of_closure;
projected_y = long_shore_pos_of_closure;
projected_z = -shelf_depth_at_closure;
plot3([projected_x projected_x],...
    [projected_y projected_y],...
    [0, projected_z], 'b-', 'linewidth', 2);
% plot3([cross_shore_pos*c_cell_size + cross_shore_distance_to_closure, cross_shore_pos*c_cell_size + cross_shore_distance_to_closure],...
%     [0, 0],...
%     [0, -shelf_depth_at_closure], 'b-', 'linewidth', 2);


%% shoreface

shoreface = -c_shoreface_slope*(cross_shore_distances-(cross_shore_pos*c_cell_size));
z = NaN(length(shoreface));
for i = (0:1:length(shoreface)-1)
    long_shore_pos = (i*c_cell_size)-max_dist/2;
    z(i+1, :) = -(cosd(local_shoreline_angle))*c_shoreface_slope*(cross_shore_distances - (cross_shore_pos*c_cell_size) - long_shore_pos*tand(local_shoreline_angle));
end
z(z > 0) = 0;
z(z < shelf_z - 4) = NaN;

plot3([cross_shore_pos*c_cell_size, projected_x],...
    [0, projected_y],...
    [0, projected_z], 'k--', 'linewidth', 2);

surf(cross_shore_distances, long_shore_distances, z, 'facecolor', [.5 .5 .5], 'edgecolor', 'none', 'facealpha', 0.7);

%% plot volume change
width = c_cell_size;
length = delta_volume/(c_cell_size*shelf_depth_at_closure);
height = shelf_depth_at_closure;
dist = cross_shore_distance_to_closure;
y = -dist*sind(local_shoreline_angle);

x_corners1 = [cross_shore_pos*c_cell_size - length,...
    cross_shore_pos*c_cell_size,...
    cross_shore_pos*c_cell_size,...
    cross_shore_pos*c_cell_size - length];
x_corners2 = [projected_x - length,...
    projected_x,...
    projected_x,...
    projected_x - length];
y_corners1 = [width/2, width/2, -width/2, -width/2];
y_corners2 = [y+(width/2), y+(width/2), y-(width/2), y-(width/2)];
z_corners1 = (.2)*ones(4);
z_corners2 = (projected_z+.1)*ones(4);
surf(x_corners1, y_corners1, z_corners1, 'facecolor', [1 .4 .6], 'edgecolor', 'none', 'facealpha', 0.8);
hold on
surf(x_corners2, y_corners2, z_corners2, 'facecolor', [1 .4 .6], 'edgecolor', 'none', 'facealpha', 0.8);
plot3([x_corners1(1) x_corners2(1)], [y_corners1(1) y_corners2(1)], [z_corners1(1) z_corners2(1)], 'color', [1 .4 .6 0.8]);
plot3([x_corners1(2) x_corners2(2)], [y_corners1(2) y_corners2(2)], [z_corners1(2) z_corners2(2)], 'color', [1 .4 .6 0.8]);
plot3([x_corners1(3) x_corners2(3)], [y_corners1(3) y_corners2(3)], [z_corners1(3) z_corners2(3)], 'color', [1 .4 .6 0.8]);
plot3([x_corners1(4) x_corners2(4)], [y_corners1(4) y_corners2(4)], [z_corners1(4) z_corners2(4)], 'color', [1 .4 .6 0.8]);

x_corners1 = [cross_shore_pos*c_cell_size + length,...
    cross_shore_pos*c_cell_size,...
    cross_shore_pos*c_cell_size,...
    cross_shore_pos*c_cell_size + length];
x_corners2 = [projected_x + length,...
    projected_x,...
    projected_x,...
    projected_x + length];

surf(x_corners1, y_corners1, z_corners1, 'facecolor', [0 1 0], 'edgecolor', 'none', 'facealpha', 0.4);
hold on
surf(x_corners2, y_corners2, z_corners2, 'facecolor', [0 1 0], 'edgecolor', 'none', 'facealpha', 0.4);
plot3([x_corners1(1) x_corners2(1)], [y_corners1(1) y_corners2(1)], [z_corners1(1) z_corners2(1)], 'color', [0 1 0 0.4]);
plot3([x_corners1(2) x_corners2(2)], [y_corners1(2) y_corners2(2)], [z_corners1(2) z_corners2(2)], 'color', [0 1 0 0.4]);
plot3([x_corners1(3) x_corners2(3)], [y_corners1(3) y_corners2(3)], [z_corners1(3) z_corners2(3)], 'color', [0 1 0 0.4]);
plot3([x_corners1(4) x_corners2(4)], [y_corners1(4) y_corners2(4)], [z_corners1(4) z_corners2(4)], 'color', [0 1 0 0.4]);

% label

zlabel('Elevation (m)')
xlabel('cross-shore distance (m)')
set(gca, 'fontsize', 14)
view(30, 30); % 45 30
zlim([-20, 5]);
% xlim([0, max_dist]);
% title({'Cross-shore schematic for volume change'; ['delta\_volume = ', num2str(delta_volume) ' m^3']}, 'fontsize', 14)
% 
% legend(['c\_shelf\_slope = ', num2str(c_shelf_slope)],...
% ['c\_cross\_shore\_reference\_pos = ', num2str(c_cross_shore_reference_pos)],...
% ['local\_shoreline\_cross\_shore\_pos = ', num2str(cross_shore_pos)],...
% ['cross\_shore\_distance\_to\_closure = ', num2str(cross_shore_distance_to_closure)],...
% ['cross\_shore\_pos\_of\_closure = ', num2str(cross_shore_pos_of_closure)],...
% ['shelf\_depth\_at\_closure = ', num2str(shelf_depth_at_closure)],...
% ['c\_shoreface\_slope = ', num2str(c_shoreface_slope)],...
% ['Erosion potential cross-section'],...
% ['Accretion potential cross-section'],...
% ['Actual erosion cross-section'],...
% ['Actual accretion cross-section'],...
% 'location', 'northeastoutside')

%% intersection of the two planes
% shore1 = [cross_shore_pos*c_cell_size, 0, 0];
% shore2 = [cross_shore_pos*c_cell_size+cross_shore_distance_to_closure, 0, -shelf_depth_at_closure];
% shore3 = [-c_cell_size*tand(local_shoreline_angle)+(cross_shore_pos*c_cell_size), -c_cell_size, 0];
% 
% shore_normal = cross((shore2-shore1),(shore3-shore1));
% shelf_normal = cross([0 1 0], [1, 0, -c_shelf_slope]);
% intersection = cross(shore_normal,shelf_normal);
% intersection = (intersection./norm(intersection)).*1000;
% 
% 
% plot3([cross_shore_pos*c_cell_size + cross_shore_distance_to_closure, cross_shore_pos*c_cell_size + cross_shore_distance_to_closure + intersection(1)],...
%     [0, intersection(2)],...
%     [-shelf_depth_at_closure, -shelf_depth_at_closure + intersection(3)], 'r-', 'linewidth', 2);
% 
% 

hfig = figure();
set(hfig, 'position', [100 100 1200 500]);
angles = (0:5:90);

effective_slopes = c_shoreface_slope-(c_shelf_slope.*cosd(angles));
cross_shore_dists = local_shelf_depth./effective_slopes;
cross_shore_closure = cross_shore_pos*c_cell_size + cosd(angles).*cross_shore_dists;
shelf_depths = c_shelf_depth_at_reference_pos + ((cross_shore_closure-(c_cross_shore_reference_pos*c_cell_size)).*c_shelf_slope);

set(gca, 'fontsize', 15)
subplot(1, 3, 1)
plot(angles, effective_slopes, 'k--');
title('Effective shore slope');
xlim([0 90]);
subplot(1, 3, 2)
plot(angles, cross_shore_dists, 'm--');
xlabel('Shore angle (degrees)');
title('Cross-shore distance to closure (m)');
xlim([0 90]);
subplot(1, 3, 3)
plot(angles, shelf_depths, 'b-');
hold on
plot([0 90], [local_shelf_depth local_shelf_depth], 'b--')
xlim([0 90]);
title('Shelf depth at closure(m)')
