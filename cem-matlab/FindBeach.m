function [ shoreline ] = FindBeach( cells )
% INPUTS:
%   beach_grid: matrix of values [0, 1] describing bathymetry
% OUTPUTS:
%   beach_R: rows of beach cells
%   beach_C: cols of beach cells
%% Prep
[rows, cols] = size(cells);


%% find start
[start_r, start_c] = GetStartCell(cells, rows, cols);
shoreline = cells(start_r, start_c);
shoreline.IsBeach = 1;
curr = shoreline;

if start_c > cols
    return;
end

%% find beach cells
dir_r = 1;
dir_c = 0;
r = start_r;
c = start_c;
% while still in grid bounds
while r > 0 && r <= rows && c > 0 && c <= cols
    % rotate direction of search to the right 90 degrees    
    [dir_r, dir_c] = TurnCounterClockwise(dir_r, dir_c, 6);
    % get cell to start checking
    next_r = r + dir_r;
    next_c = c + dir_c;
    while ~IsBeachCell(cells, next_r, next_c)
        [dir_r, dir_c] = TurnCounterClockwise(dir_r, dir_c, 1);
        next_r = r + dir_r;
        next_c = c + dir_c;
    end
    
    if ~isempty(curr.Prev)
        % break if our next cell is also our previous cell
        if eq(next_r,curr.Prev.R) && eq(next_c,curr.Prev.C)
            break;
        end
    end
    
    r = next_r;
    c = next_c;
    next = cells(r, c);
    curr.Next = next;
    next.Prev = curr;
    curr = next;
    curr.IsBeach = 1;
    
    % break if we make a loop
    if r == start_r && c == start_c
        break;
    end
end

curr.Next = shoreline;
shoreline.Prev = curr;
end


function [isBeach] = IsBeachCell(cells, row, col)
[ rows, cols] = size(cells);
if row < 1 || row > rows || col < 1 || col > cols
    isBeach = 0;
    return;
end

isBeach = cells( row, col).FracFull > 0 && cells(row, col).FracFull < 1;
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