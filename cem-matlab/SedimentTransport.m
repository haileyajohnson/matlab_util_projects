function [ cells_out, shoreline_out ] = SedimentTransport( cells, shoreline, wave_angle, wave_period, wave_height, shelf_slope, shoreface_slope, ref_pos, ref_depth, min_depth, cell_size )
    
    WaveTransformation( cells, wave_angle, wave_period, wave_height, shoreline);
    
    GetAvailableSupply(shoreline, cells, ref_pos, ref_depth, shelf_slope, shoreface_slope, min_depth );
    
    NetVolumeChange(shoreline);
    
    shoreline_out = TransportSediment(shoreline, cells, ref_pos, ref_depth, shelf_slope, shoreface_slope, min_depth);
    
    cells_out = cells;
end

%%
function WaveTransformation ( cells, deep_angle, period, deep_height, shoreline)
    
    start_depth = 3 * deep_height;  % (meters) depth to begin refraction calculation
    refract_step = 0.2;             % (meters) step size to iterate through depth
    kbreak = 0.5;                   % coeffcient such that waves break at Hs > kbreak*depth
    g = 9.80665;                    % m/s^2
    
    curr = shoreline;
    do = 1;
    while ~eq(curr, shoreline) | do
        do = 0;
        curr.TransportPotential = 0;
        
        if CheckIfInShadow(curr, cells, deep_angle)
            curr = curr.Next;
            continue;
        end
        
        [shore_angle, dir] = curr.ChooseAppropriateAngle(deep_angle);
        if(dir == 0)
            alpha_deep = pi/4;
        else
            alpha_deep = deep_angle - shore_angle;
        end

        if abs(alpha_deep) > (0.995 * pi/2)  % if over 90 degress, should be in shadow
            curr = curr.Next;
            continue;
        end

        wave_height = deep_height;
        c_deep = (g * period)/(2 * pi);
        l_deep = c_deep * period;
        depth = start_depth;

        while (1)    
          % non-iterative eqn for L, from Fenton & McKee
          wave_length = l_deep * tanh(((depth/g)*((2*pi/period)^2))^(3/4))^(2/3);
          c = wave_length / period;

          % n = 1/2(1+2kh/sinh(kh)) Komar 5.21 
          % First Calculate kh = 2 pi Depth/L  from k = 2 pi/L
          kh = 2 * pi * depth / wave_length;
          n = 0.5 * (1 + 2.0 * kh / sinh(2.0 * kh));

          % Calculate angle, assuming shore parallel contours and no conv/div of rays, from Komar 5.47
          alpha = asin(c / c_deep * sin(alpha_deep));

          % Determine Wave height from refract calcs, from Komar 5.49
          wave_height = deep_height * sqrt((c_deep * cos(alpha_deep)) / (c * 2 * n * cos(alpha)));      

          if wave_height > kbreak * depth || depth < refract_step  
              break;
          end
          % step
          depth = depth - refract_step;
        end
        
        curr.BreakerAlpha = alpha;
        curr.BreakerHeight = wave_height;
        
        % sed transport
        [curr.TransportPotential] = GetTransportVolumePotential(curr.BreakerAlpha, curr.BreakerHeight);
        if isnan(curr.TransportPotential)
            error('transport potential is NaN')
        end
        curr = curr.Next;
    end
        
end

%%
function [ transport_volume_potential ] = GetTransportVolumePotential( alpha, height )
    rho = 1020;                     % (kg/m^3) density of salt water
    g = 9.80665;                    % m/s^2
    transport_volume_potential = abs(1.1*rho*g^(3/2)*height^(5/2)*cos(alpha)*sin(alpha));
end

%%
function GetAvailableSupply( shoreline, cells, ref_pos, shelf_depth_at_ref_pos, shelf_slope, shoreface_slope, min_depth )
    curr = shoreline;
    cell_area = shoreline.Size^2;
    do = 1;
    while do | ~eq(curr, shoreline)
        do = 0;
        
        volume_needed_left = 0;
        volume_needed_right = 0;
        switch curr.FlowDirection()
            case 'R'
                volume_needed_right = curr.TransportPotential;
            case 'D'
                volume_needed_right = curr.TransportPotential;
                volume_needed_left = curr.Prev.TransportPotential;                
            case 'C'
            case 'L'
                volume_needed_left = curr.Prev.TransportPotential;
        end
        
        total_volume_needed = volume_needed_left + volume_needed_right;
        shore_angle = curr.GetSurroundingAngle();
        depth = GetDepthOfClosure(curr, ref_pos, shelf_depth_at_ref_pos, shelf_slope, shoreface_slope, shore_angle, min_depth);
        
        volume_available = curr.FracFull*curr.Size*depth;
        cell_behind = GetCellsInDir(curr, GetDir(shore_angle), cells);
        if ~isempty(cell_behind) && cell_behind.FracFull == 1
            volume_available = volume_available + cell_area*depth;
        end
        
        if total_volume_needed > volume_available
            curr.Prev.TransportPotential = (volume_needed_left/total_volume_needed)*volume_available;
            curr.TransportPotential = (volume_needed_right/total_volume_needed)*volume_available;
        end
        
        if isnan(curr.TransportPotential)
            error('transport potential is NaN')
        end
        
        curr = curr.Next;
    end
end

%%
function NetVolumeChange( shoreline )
    curr = shoreline;
    do = 1;
    while do | ~eq(curr, shoreline)
        do = 0;
        volume_in = NaN;
        volume_out = NaN;
        switch curr.FlowDirection()
            case 'R'
                volume_in = curr.Prev.TransportPotential;
                volume_out = curr.TransportPotential;
            case 'D'
                volume_in = 0;
                volume_out = curr.TransportPotential + curr.Prev.TransportPotential;                
            case 'C'
                volume_in = curr.Prev.TransportPotential + curr.TransportPotential;
                volume_out = 0;
            case 'L'
                volume_in = curr.TransportPotential;
                volume_out = curr.Prev.TransportPotential;
        end
        curr.NetVolumeChange = volume_in-volume_out;
        if isnan(curr.NetVolumeChange)
            error('net volume change is NaN')
        end
        curr = curr.Next;
    end
end


%%
function [ shoreline ] = TransportSediment(  shoreline, cells, ref_pos, shelf_depth_at_ref_pos, shelf_slope, shoreface_slope, min_depth )
    curr = shoreline;
    cell_area = shoreline.Size^2;
    do = 1;
    while do | ~eq(curr, shoreline)
        do = 0;
        
        shore_angle = curr.GetSurroundingAngle();        
        depth = GetDepthOfClosure(curr, ref_pos, shelf_depth_at_ref_pos, shelf_slope, shoreface_slope, shore_angle, min_depth);
        net_area_change = curr.NetVolumeChange / depth;
        curr.FracFull = curr.FracFull + net_area_change/cell_area;
        
        firstNode = BeachNode.empty;
        lastNode = firstNode;
        if curr.FracFull < 0
            [firstNode, lastNode] = OopsImEmpty(curr, cells);
        elseif curr.FracFull > 1
            [firstNode, lastNode] = OopsImFull(curr, cells);
        end
        
        if eq(curr, shoreline) && ~isempty(firstNode);
            shoreline = firstNode;
        end
        
        if ~isempty(lastNode)
            curr = lastNode;
        end
        curr = curr.Next;
    end
end

function [ first_node, last_node ] =  OopsImEmpty( node, cells )
    neighbors = node.Get4Neighbors(cells);
    full_indices = [];
    for i = (1:1:length(neighbors))
        if neighbors(i).FracFull == -1
            continue;
        end
        if neighbors(i).FracFull >= 1
            full_indices(end+1) = i;
        end            
    end
    
    if isempty(full_indices)
        for i = (1:1:length(neighbors))
            if neighbors(i).FracFull == -1
                continue;
            end
            if neighbors(i).FracFull > 0
                full_indices(end+1) = i;
            end            
        end
    end
    
    full_cells = length(full_indices);
    for i = full_indices
        neighbors(i).FracFull =  neighbors(i).FracFull + node.FracFull/full_cells;
    end
    node.FracFull = 0;

    % TODO: adjust shoreline
    [first_node, last_node] = node.ReplaceNode(cells, 1);
end

function [ first_node, last_node ] =  OopsImFull( node, cells )
    neighbors = node.Get4Neighbors(cells);
    
    empty_indices = [];
    for i = (1:1:length(neighbors))
        if neighbors(i).FracFull == -1
            continue;
        end
        if neighbors(i).FracFull <= 0
            empty_indices(end+1) = i;
        end            
    end
    
    if isempty(empty_indices)
        for i = (1:1:length(neighbors))
            if neighbors(i).FracFull == -1
                continue;
            end
            if neighbors(i).FracFull < 1
                empty_indices(end+1) = i;
            end            
        end
    end
    
    empty_cells = length(empty_indices);
    for i = empty_indices
        neighbors(i).FracFull =  neighbors(i).FracFull + (node.FracFull-1)/empty_cells;
    end
    node.FracFull = 1;
    
    % TODO: adjust shoreline
    [first_node, last_node] = node.ReplaceNode(cells, 0);
end

%% Helper functions

function [ closure_depth ] = GetDepthOfClosure( node, ref_pos, shelf_depth_at_ref_pos, shelf_slope, shoreface_slope, shore_angle, min_shelf_depth_at_closure )

    %% Eq 1
    local_shelf_depth = shelf_depth_at_ref_pos + ((node.R - ref_pos)*node.Size*shelf_slope);

    %% Eq 2
    cross_shore_distance_to_closure = local_shelf_depth/(shoreface_slope-(cos(shore_angle)*shelf_slope));

    %% Eq 3
    cross_shore_pos_of_closure = node.R*node.Size + sin(shore_angle)*cross_shore_distance_to_closure;

    %% Eq 4
    closure_depth = shelf_depth_at_ref_pos +(cross_shore_pos_of_closure - ref_pos*node.Size)*shelf_slope;
    if closure_depth < min_shelf_depth_at_closure
        closure_depth = min_shelf_depth_at_closure;
    end
    
end

function [ b ] = mod( a, m )
    sign = a/abs(a);
    a = abs(a);
    c = floor(a/m);
    c = c*sign;
    a = a*sign;
    b = a - m*c;
    
end


function [ rounded_angle ] = RoundRadians(angle, round_to, bias )

    m90 = mod(angle, pi/2);
    m180 = mod(angle, pi);
    if m90 ~= m180
        bias = (pi/2)-bias;
    end
    rounded_angle = angle - m90;
    if abs(m90) >= bias
        rounded_angle = rounded_angle + (m90/abs(m90))*pi/2;
    end
    
end

function [ dir ] = GetDir( shore_angle )
    shore_normal = shore_angle - pi/2;
    dir = RoundRadians(shore_normal, pi/2, pi/6);
end
    
function [ new_node ] = GetCellsInDir( node, dir, cells )

    [rows, cols] = size(cells);
    
    r = node.R;
    c = node.C;
    if cos(dir) > 0.00001
        col = c + 1;
    elseif cos(dir) < -0.00001
        col = c - 1;
    else
        col = c;
    end
    
    % periodic boundary conditions
    if col == 0
        col = cols;
    elseif col > cols
        col = 1;
    end
    
    if sin(dir) > 0.00001
        row = r + 1;
    elseif sin(dir) < -0.00001
        row = r - 1;
    else
        row = r;
    end
    
    if row <= 0 || row > size(cells,1)
        new_node = BeachNode.empty;
        return;
    end
    
    new_node = cells(row, col);
        
end


function [ inShadow ] = CheckIfInShadow( node, cells, wave_angle )
    inShadow = 0;
    step_size = .5;
    
    [num_rows, num_cols] = size(cells);

    row = node.R;
    i = 1;

    while row <= num_rows

        row = node.R + fix(i * step_size * cos(wave_angle));
        col = node.C + fix(-i * step_size * sin(wave_angle));

        if row >= num_rows || row < 1
            return;
        end
        
        while col < 1
            col = num_cols + col;
        end
        while col > num_cols
            col = col - num_cols;
        end
        
        % row + 1?       
        if cells(row, col).FracFull == 1 && (row + 1) > node.R + node.FracFull + abs((col - node.C) / tan(wave_angle))
            inShadow = 1;
            return
        end
        if cells(row, col).FracFull > 0 && row + cells(row, col).FracFull > node.R + node.FracFull + abs((col - node.C) / tan(wave_angle))
            inShadow = 1;
            return
        end
        i = i+1;
    end
end
