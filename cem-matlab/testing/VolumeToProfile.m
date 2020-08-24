close all; clear all;
addpath('arrow');
%%inputs
delta_volume = 100000;
cross_shore_pos = 20;
local_shoreline_angle = 30;
percent_full_sand = .5;
%%
c_cell_size = 100;
c_grid_size = 40;

c_shelf_slope = 0.001;
c_shoreface_slope = 0.01;
c_cross_shore_reference_pos = 10;
c_shelf_depth_at_reference_pos = 10;
c_min_shelf_depth_at_closure = 10;

cross_shore_distances = (0:c_cell_size:c_cell_size*c_grid_size);
continental_shelf = -c_shelf_slope*(cross_shore_distances-(c_cross_shore_reference_pos*c_cell_size)) - c_shelf_depth_at_reference_pos;

hfig_profile = figure();
set(hfig_profile, 'Position', [100, 200, 1000, 600])
h1 = plot(cross_shore_distances, continental_shelf, 'k', 'linewidth', 2);
hold on
ylabel('Elevation (m)')
xlabel('cross-shore distance (m)')
set(gca, 'fontsize', 14)
%     plot(cross_shore, shoreface, 'r', 'linewidth', 2)
h2 = plot([c_cross_shore_reference_pos*c_cell_size, c_cross_shore_reference_pos*c_cell_size], [-15, 25], 'r--');
plot([0, c_cell_size*c_grid_size], [0, 0], 'r--');

%% Eq 1
local_shelf_depth = c_shelf_depth_at_reference_pos + ((cross_shore_pos - c_cross_shore_reference_pos)*c_cell_size*c_shelf_slope);
h3 = plot([cross_shore_pos*c_cell_size, cross_shore_pos*c_cell_size], [0 -local_shelf_depth], 'm-.', 'linewidth', 1);

%% Eq 2
cross_shore_distance_to_closure = local_shelf_depth/(c_shoreface_slope-c_shelf_slope * cosd(local_shoreline_angle));
h4 = plot([cross_shore_pos*c_cell_size, cross_shore_pos*c_cell_size+cross_shore_distance_to_closure], [-local_shelf_depth, -local_shelf_depth], 'm--');

%% Eq 3
cross_shore_pos_of_closure = cross_shore_pos*c_cell_size + cross_shore_distance_to_closure*cosd(local_shoreline_angle);
h5 = plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [-15, 25], 'b--');

%% Eq 4

shelf_depth_at_closure = c_shelf_depth_at_reference_pos + ((cross_shore_pos_of_closure-(c_cross_shore_reference_pos*c_cell_size))*c_shelf_slope);
if shelf_depth_at_closure < c_min_shelf_depth_at_closure
    shelf_depth_at_closure = c_min_shelf_depth_at_closure;
end
h6 = plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [0, 0-shelf_depth_at_closure], 'b-');

%% shoreface

shoreface = -c_shoreface_slope*(cross_shore_distances-(cross_shore_pos*c_cell_size));
shoreface(shoreface < -shelf_depth_at_closure) = NaN;
project_point_of_closure = cross_shore_distances(find(~isnan(shoreface), 1, 'last'));
shoreface(cross_shore_distances < cross_shore_pos*c_cell_size) = 0;
h7 = plot(cross_shore_distances, shoreface, 'k--', 'linewidth', 2);

%% potential erosion/accretion

base = c_cell_size + percent_full_sand*c_cell_size;
x_corners = [cross_shore_pos*c_cell_size - base, cross_shore_pos*c_cell_size, project_point_of_closure, project_point_of_closure - base, cross_shore_pos*c_cell_size - base];
z_corners = [ 0, 0, -shelf_depth_at_closure, -shelf_depth_at_closure, 0];
h8 = plot(x_corners, z_corners, 'Color', [1 .4 .6 0.4], 'linewidth', 2);
h9 = plot(x_corners + base, z_corners, 'color', [0 1 0 0.4], 'linewidth', 2);

%% actual erosion/accretion

base = delta_volume/(c_cell_size*shelf_depth_at_closure);
x_corners_actual = [cross_shore_pos*c_cell_size - base, cross_shore_pos*c_cell_size, project_point_of_closure, project_point_of_closure - base, cross_shore_pos*c_cell_size - base];
z_corners_actual = [ 0, 0, -shelf_depth_at_closure, -shelf_depth_at_closure, 0];
h10 = plot(x_corners_actual, z_corners_actual, '--', 'Color', [1 .4 .6 0.4], 'linewidth', 1.5);
h11 = plot(x_corners_actual + base, z_corners_actual, '--', 'color', [0 1 0 0.4], 'linewidth', 1.5);

legend([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11],['c\_shelf\_slope = ', num2str(c_shelf_slope)],...
['c\_cross\_shore\_reference\_pos = ', num2str(c_cross_shore_reference_pos)],...
['local\_shoreline\_cross\_shore\_pos = ', num2str(cross_shore_pos)],...
['cross\_shore\_distance\_to\_closure = ', num2str(cross_shore_distance_to_closure)],...
['cross\_shore\_pos\_of\_closure = ', num2str(cross_shore_pos_of_closure)],...
['shelf\_depth\_at\_closure = ', num2str(shelf_depth_at_closure)],...
['c\_shoreface\_slope = ', num2str(c_shoreface_slope)],...
['Erosion potential cross-section'],...
['Accretion potential cross-section'],...
['Actual erosion cross-section'],...
['Actual accretion cross-section'],...
'location', 'northeast')

title({'Cross-shore schematic for volume change'; ['delta\_volume = ', num2str(delta_volume) ' m^3']}, 'fontsize', 14)

%% map view
axes('Position', [.15, .62, .2, .25])
box on
shore_width = sind(local_shoreline_angle)*c_cell_size*c_grid_size;
ah = annotation('arrow',...
    'headStyle','cback1','HeadLength',8,'HeadWidth',5);
set(ah,'parent',gca);
set(ah,'position',...
    [0 0 c_cell_size*c_grid_size 0]);
hold on

plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [-c_cell_size*c_grid_size/2, c_cell_size*c_grid_size/2], 'b--');
plot([-shore_width/2 shore_width/2],...
    [-c_cell_size*c_grid_size/2, c_cell_size*c_grid_size/2], 'g');

intercept = -c_cell_size*c_grid_size*sind(local_shoreline_angle);
plot([0, cross_shore_pos_of_closure], [0, intercept], 'k--', 'linewidth', 1.2)

set(gca, 'XTick', [], 'YTick', [])
xlim([-shore_width/2 c_cell_size*c_grid_size])
ylim([-c_cell_size*c_grid_size/2, c_cell_size*c_grid_size/2])

% %% Next timestep
% %%
% %% Erode
% 
% %%inputs
% cross_shore_pos = cross_shore_pos - 1;
% percent_full_sand = (1+percent_full_sand)-(base/c_cell_size);
% 
% hfig_profile2 = figure();
% set(hfig_profile2, 'Position', [100, 200, 1000, 600])
% h1 = plot(cross_shore_distances, continental_shelf, 'k', 'linewidth', 2);
% hold on
% ylabel('Elevation (m)')
% xlabel('cross-shore distance (m)')
% set(gca, 'fontsize', 14)
% h2 = plot([c_cross_shore_reference_pos*c_cell_size, c_cross_shore_reference_pos*c_cell_size], [-15, 25], 'r--');
% plot([0, c_cell_size*c_grid_size], [0, 0], 'r--');
% 
% %% Eq 1
% local_shelf_depth = c_shelf_depth_at_reference_pos + ((cross_shore_pos - c_cross_shore_reference_pos)*c_cell_size*c_shelf_slope);
% h3 = plot(cross_shore_pos*c_cell_size, -local_shelf_depth, 'm*', 'linewidth', 2);
% 
% %% Eq 2
% cross_shore_distance_to_closure = local_shelf_depth/(c_shoreface_slope-c_shelf_slope * cosd(local_shoreline_angle));
% h4 = plot([cross_shore_pos*c_cell_size, cross_shore_pos*c_cell_size+cross_shore_distance_to_closure], [-local_shelf_depth, -local_shelf_depth], 'm--');
% 
% %% Eq 3
% cross_shore_pos_of_closure = cross_shore_pos*c_cell_size + cross_shore_distance_to_closure*cosd(local_shoreline_angle);
% h5 = plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [-15, 25], 'b--');
% 
% %% Eq 4
% 
% shelf_depth_at_closure = c_shelf_depth_at_reference_pos + ((cross_shore_pos_of_closure-(c_cross_shore_reference_pos*c_cell_size))*c_shelf_slope);
% h6 = plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [0, 0-shelf_depth_at_closure], 'b-');
% 
% %% shoreface
% 
% shoreface = -c_shoreface_slope*(cross_shore_distances-(cross_shore_pos*c_cell_size));
% shoreface(cross_shore_distances > cross_shore_pos_of_closure) = NaN;
% shoreface(cross_shore_distances < cross_shore_pos*c_cell_size) = 0;
% plot(cross_shore_distances, shoreface, 'k--', 'linewidth', 2);
% 
% plot(x_corners_actual, z_corners_actual, '--', 'Color', [1 .4 .6 0.4], 'linewidth', 1.5);
% 
% %% Erode
% 
% %%inputs
% cross_shore_pos = cross_shore_pos + 2;
% percent_full_sand = (percent_full_sand-1)+(base/c_cell_size);
% 
% %% Eq 1
% local_shelf_depth = c_shelf_depth_at_reference_pos + ((cross_shore_pos - c_cross_shore_reference_pos)*c_cell_size*c_shelf_slope);
% plot(cross_shore_pos*c_cell_size, -local_shelf_depth, 'm*', 'linewidth', 2);
% 
% %% Eq 2
% cross_shore_distance_to_closure = local_shelf_depth/(c_shoreface_slope-c_shelf_slope * cosd(local_shoreline_angle));
% plot([cross_shore_pos*c_cell_size, cross_shore_pos*c_cell_size+cross_shore_distance_to_closure], [-local_shelf_depth, -local_shelf_depth], 'm--');
% 
% %% Eq 3
% cross_shore_pos_of_closure = cross_shore_pos*c_cell_size + cross_shore_distance_to_closure*cosd(local_shoreline_angle);
% plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [-15, 25], 'b--');
% 
% %% Eq 4
% 
% shelf_depth_at_closure = c_shelf_depth_at_reference_pos + ((cross_shore_pos_of_closure-(c_cross_shore_reference_pos*c_cell_size))*c_shelf_slope);
% plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [0, 0-shelf_depth_at_closure], 'b-');
% 
% %% shoreface
% 
% shoreface = -c_shoreface_slope*(cross_shore_distances-(cross_shore_pos*c_cell_size));
% shoreface(shoreface < cross_shore_pos_of_closure) = NaN;
% shoreface(cross_shore_distances < cross_shore_pos*c_cell_size) = 0;
% plot(cross_shore_distances, shoreface, 'k--', 'linewidth', 2);
% 
% plot(x_corners_actual + base, z_corners_actual, '--', 'color', [0 1 0 0.4], 'linewidth', 1.5);
