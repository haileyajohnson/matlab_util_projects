clear all;

%% model controls
c_animation_step = 1;                   % interval at which grid should be saved and plotted
c_timesteps = 3;                        % number of timesteps to run
read_file = 'input/benchmark_config.xlsx';     % name of shoreline initial conditions file

%% input grid
c_cell_size = 100;                      % distance cell width & length represent in meters
c_cross_shore_reference_pos = 10;       % cross-shore distance to a reference point, in # cells
c_shelf_depth_at_reference_pos = 10;    % depth at reference point in meters
c_minimum_shelf_depth_at_closure = 10;  % minimum delf depth maintained by wave action
c_shelf_slope = 0.001;                   % linear slope of continental shelf
c_shoreface_slope = 0.01;              % linear slope of shoreface

%% wave field
A = 0.5;                % asymmetry
U = 0.5;                % highness
c_wave_height = 2;      % initial wave height in meters
c_wave_period = 10;     % wave period in seconds

save('config.mat')