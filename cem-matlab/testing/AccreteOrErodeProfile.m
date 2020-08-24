close all; clear all;
%%inputs
delta_volume = 100000;
cross_shore_pos = 20;
local_shoreline_angle = 0;
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
plot(cross_shore_distances, continental_shelf, 'k', 'linewidth', 2);
hold on
ylabel('Elevation (m)')
xlabel('cross-shore distance (m)')
set(gca, 'fontsize', 14)
%     plot(cross_shore, shoreface, 'r', 'linewidth', 2)
plot([c_cross_shore_reference_pos*c_cell_size, c_cross_shore_reference_pos*c_cell_size], [-15, 25], 'r--');
plot([0, c_cell_size*c_grid_size], [0, 0], 'r--');

shoreface = -c_shoreface_slope*(cross_shore_distances-(cross_shore_pos*c_cell_size));
shoreface(cross_shore_distances < cross_shore_pos*c_cell_size) = 0;
plot(cross_shore_distances, shoreface, 'k--', 'linewidth', 2);

%% Accrete
pos = cross_shore_pos;
widths = NaN(1,30);
depths = NaN(1,30);
for i = (1:1:10)
    %% Eq 1
    local_shelf_depth = c_shelf_depth_at_reference_pos + ((cross_shore_pos - c_cross_shore_reference_pos)*c_cell_size*c_shelf_slope);
    
    %% Eq 2
    cross_shore_distance_to_closure = local_shelf_depth/(c_shoreface_slope-c_shelf_slope * cosd(local_shoreline_angle));

    %% Eq 3
    cross_shore_pos_of_closure = pos*c_cell_size + cross_shore_distance_to_closure*cosd(local_shoreline_angle);

    %% Eq 4

    shelf_depth_at_closure = c_shelf_depth_at_reference_pos + ((cross_shore_pos_of_closure-(c_cross_shore_reference_pos*c_cell_size))*c_shelf_slope);
    if shelf_depth_at_closure < c_min_shelf_depth_at_closure
        shelf_depth_at_closure = c_min_shelf_depth_at_closure;
    end

    %% actual erosion/accretion

    base = delta_volume/(c_cell_size*shelf_depth_at_closure);
    x_corners_actual = [pos*c_cell_size - base, pos*c_cell_size, cross_shore_pos_of_closure, cross_shore_pos_of_closure - base, pos*c_cell_size - base];
    z_corners_actual = [ 0, 0, -shelf_depth_at_closure, -shelf_depth_at_closure, 0];
    plot(x_corners_actual + base, z_corners_actual, '--', 'color', [0 1 0 0.4], 'linewidth', 1.5);
    
    pos = pos+1;
    widths(i+29) = base;
    depths(i+29) = shelf_depth_at_closure;
end

%% Accrete
pos = cross_shore_pos;
for i = (1:1:30)
    %% Eq 1
    local_shelf_depth = c_shelf_depth_at_reference_pos + ((cross_shore_pos - c_cross_shore_reference_pos)*c_cell_size*c_shelf_slope);
    
    %% Eq 2
    cross_shore_distance_to_closure = local_shelf_depth/(c_shoreface_slope-c_shelf_slope * cosd(local_shoreline_angle));

    %% Eq 3
    cross_shore_pos_of_closure = pos*c_cell_size + cross_shore_distance_to_closure*cosd(local_shoreline_angle);
    plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [-15, 25], 'b--');

    %% Eq 4

    shelf_depth_at_closure = c_shelf_depth_at_reference_pos + ((cross_shore_pos_of_closure-(c_cross_shore_reference_pos*c_cell_size))*c_shelf_slope);
    if shelf_depth_at_closure < c_min_shelf_depth_at_closure
        shelf_depth_at_closure = c_min_shelf_depth_at_closure;
    end
    plot([cross_shore_pos_of_closure, cross_shore_pos_of_closure], [0, 0-shelf_depth_at_closure], 'b-');

    %% actual erosion/accretion

    base = delta_volume/(c_cell_size*shelf_depth_at_closure);
    x_corners_actual = [pos*c_cell_size - base, pos*c_cell_size, cross_shore_pos_of_closure, cross_shore_pos_of_closure - base, pos*c_cell_size - base];
    z_corners_actual = [ 0, 0, -shelf_depth_at_closure, -shelf_depth_at_closure, 0];
    plot(x_corners_actual, z_corners_actual, '--', 'Color', [1 .4 .6 0.4], 'linewidth', 1.5);
    
    pos = pos-1;
    widths(31-i) = base;
    depths(31-i) = shelf_depth_at_closure;
end

xlim([0, 4000])
ylim([-15, 25])

hfig2 = figure();
plot((1:1:length(widths)), widths./10, '*', 'color', [0 0 1 .5]);
hold on
plot((1:1:length(widths)), depths, '*', 'color', [ 1 0 0 .5]);

legend('Width of paralellogram (100m)', 'Depth of parallelogram (m)');
xlabel('Cell index');
