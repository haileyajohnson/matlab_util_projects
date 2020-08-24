close all; clear all;
addpath('testing');
%%
load('input/config.mat');
beach_grid = xlsread(read_file, 'Sheet1');

%% Initialize

cells = Initialize(beach_grid, c_cell_size);

%% FindBeach

shoreline = FindBeach(cells);

%% MAIN LOOP
for t = (1:1:c_timesteps)

disp(t)

% if mod(t, c_animation_step) == 0
%    TestShoreline(shoreline, beach_grid);
%    PlotShoreline(shoreline, beach_grid);
% end

%% FindWaveAngle

wave_angle = pi/4; % FindWaveAngle(U, A);

%% SedTransport

[cells, shoreline] = SedimentTransport(cells, shoreline, wave_angle, c_wave_period, c_wave_height, c_shelf_slope, c_shoreface_slope, c_cross_shore_reference_pos, c_shelf_depth_at_reference_pos, c_minimum_shelf_depth_at_closure, c_cell_size);

%% Save as output

if mod(t, c_animation_step) == 0
    process(shoreline, wave_angle, beach_grid, t);
    % output = process(cells, 1);
    % imwrite(output, ['output/output', num2str(t), '.png']);
    % frames(length(frames)+1) = im2frame(['output/', num2str(t), '.png']);
end

%% reset for next timestep
cells = ZeroVars(cells);

end
%% END MAIN LOOP

%% post-process
% movie(frames);

