function [ beach_R, beach_C ] = FindBeach( input_grid )

%% Load
test_dir = 'test_cases/';
beach_grid = xlsread(strcat(test_dir, input_grid),'Sheet1');

%% Prep
grid_size = size(beach_grid);
rows = grid_size(1);
cols = grid_size(2);

%% find start
[start_r, start_c] = GetStartCell(beach_grid, rows, cols);
beach_R = [start_r];
beach_C = [start_c];

if start_c > cols
    return;
end

%% find beach cells
dir_r = 1;
dir_c = 0;
r = start_r;
c = start_c;
% while still in grid bounds
while r > 0 && r < rows+1 && c > 0 && c < cols+1
    % rotate direction of search to the right 90 degrees    
    [dir_r, dir_c] = TurnCounterClockwise(dir_r, dir_c, 6);
    % get cell to start checking
    next_r = r + dir_r;
    next_c = c + dir_c;
    while ~IsBeachCell(beach_grid, next_r, next_c)
        [dir_r, dir_c] = TurnCounterClockwise(dir_r, dir_c, 1);
        next_r = r + dir_r;
        next_c = c + dir_c;
    end
    % break if our next cell is also our previous cell
    if length(beach_R) >= 2 && next_r == beach_R(end-1) && next_c == beach_C(end-1)
        break;
    end
    
    r = next_r;
    c = next_c;
    beach_R = [beach_R, r];
    beach_C = [beach_C, c];
    
    % break if we make a loop
    if r == start_r && c == start_c
        break;
    end
end

plot(beach_C, 26-beach_R, 'r-', 'linewidth', 2);
xlim([1, 26]);
ylim([1, 26]);
end


function [isBeach] = IsBeachCell(beach_grid, row, col)
grid_size = size(beach_grid);
rows = grid_size(1);
cols = grid_size(2);
if row < 1 || row > rows || col < 1 || col > cols
    isBeach = 0;
    return;
end

val = beach_grid(row, col);
isBeach = val > 0 && val < 1;
end

function [r, c] = GetStartCell(beach_grid, rows, cols)
c = 1;
r = 1;

while c <= cols
    if IsBeachCell(beach_grid, r, c)
        break;
    end
    
    r = r+1;
    if r > rows
        r = 0;
        c = c + 1;        
    end
end

end

function [dir_r, dir_c] = TurnCounterClockwise(dir_r, dir_c, num_turns)
    angle = atan2(-dir_r, dir_c);
    angle = angle + num_turns*(pi/4);
    dir_r = -round(sin(angle));
    dir_c = round(cos(angle));
end
