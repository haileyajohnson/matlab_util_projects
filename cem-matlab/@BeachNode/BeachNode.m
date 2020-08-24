classdef BeachNode < handle
   
    properties 
        FracFull = NaN
        IsBeach = NaN
        R = NaN
        C = NaN
        Size = NaN
        BreakerHeight = NaN
        BreakerAlpha = NaN
        TransportPotential = NaN
        NetVolumeChange = NaN
        Next = BeachNode.empty
        Prev = BeachNode.empty
    end
    
    methods
        function node = BeachNode(FracFull, R, C, cell_size)
            if (nargin > 0)
                node.FracFull = FracFull;
                node.R = R;
                node.C = C;
                node.Size = cell_size;
                node.IsBeach = 0;
            else
                node.FracFull = -1;
                node.R = -1;
                node.C = -1;
                node.Size = -1;
                node.IsBeach = 0;
            end
        end
        
        function angle = GetLeftAngle(node)
            angle = NaN;
            if ~isempty(node.Prev)
                [angle, dist] = GetAngle(node.Prev, node);
                angle = angle + atan2(node.FracFull - node.Prev.FracFull, dist);
            end
        end
        
        function angle = GetRightAngle(node)
            angle = NaN;
            if ~isempty(node.Next)
                [angle, dist] = GetAngle(node, node.Next);
                angle = angle + atan2(node.Next.FracFull - node.FracFull, dist);
            end
        end
        
        function angle = GetSurroundingAngle(node)
            angle = NaN;
            if ~isempty(node.Prev) && ~isempty( node.Next )
                [angle, dist] = GetAngle(node.Prev, node.Next);
                angle = angle + atan2(node.Next.FracFull - node.Prev.FracFull, dist);
            end
        end
        
        function [ angle, dir ] = ChooseAppropriateAngle( node, wave_angle )
            central = node.GetSurroundingAngle();
            alpha = wave_angle - central;
            U = abs(alpha) >= pi/4;
            U_next = wave_angle - node.Next.GetSurroundingAngle() >= pi/4;
            U_prev = wave_angle - node.Prev.GetSurroundingAngle() >= pi/4;
            if ~U && (U_next || U_prev)
                angle = NaN;
                dir = 0;
            else
                if (alpha > 0 && U) || (alpha < 0 && ~U)
                    angle = node.GetLeftAngle();
                    dir = -1;
                else
                    angle = node.GetRightAngle();
                    dir = 1;
                end
                angle = mod(angle, 2*pi);
            end
        end
        
        
        function [ angle, distance ] = GetAngle( node1, node2 )
            c1 = node1.C;
            c2 = node2.C;
            if abs(c2-c1) >= 4
                if c2-c1 > 0
                    c1 = node2.Size+c1;
                else
                    c1 = 0 - (node1.Size-c1);
                end
            end
            
            angle = atan2(node2.R - node1.R, c2 - c1);
            distance = sqrt((node2.R-node1.R)^2 + (c2 - c1)^2);
        end
                
        function [ flow_dir ] = FlowDirection( node )
            flow_dir = '-';
            if ~isempty(node.Prev)
                if node.BreakerAlpha > 0
                    if node.Prev.BreakerAlpha > 0
                        flow_dir = 'R';
                    else
                        flow_dir = 'D';
                    end
                else
                    if node.Prev.BreakerAlpha > 0
                        flow_dir = 'C';
                    else
                        flow_dir = 'L';
                    end
                end
            end
        end
                        
        function [ firstNode, lastNode ] = ReplaceNode( oldNode, grid, erode )
            neighbors = oldNode.Get8Neighbors(grid, erode);
                        
            % insert nodes
            curr = oldNode.Prev;
            for i = (1:1:length(neighbors))
                temp = neighbors(i);
                if temp.FracFull == -1 || temp.FracFull == 1 || temp.FracFull == 0 || temp.IsBeach
                    continue;
                end
                if eq(temp, oldNode.Next)
                    break;
                end               
                
                temp.IsBeach = 1;
                curr.Next = temp;
                temp.Prev = curr;
                curr = temp;
            end
            
            curr.Next = oldNode.Next;
            oldNode.Next.Prev = curr;
            
            % return start and end node of inserted segment
            firstNode = oldNode.Prev.Next;
            lastNode = curr;
            
            % remove old node
            oldNode.Prev = BeachNode.empty;
            oldNode.Next = BeachNode.empty;
            oldNode.IsBeach = 0;
        end
        
        % return 4-connected neighbors counter-clockwise starting from the
        % left
        %    |4|
        %  |1|0|3|
        %    |2|
        function [ neighbors ] = Get4Neighbors( node, grid )
            cols = [ node.C-1, node.C, node.C+1, node.C ];
            rows = [ node.R, node.R+1, node.R, node.R-1 ];
            
            % remove out of bounds neighbors
            rows(rows<1 | rows>size(grid, 1)) = NaN;
            cols(isnan(rows)) = NaN;
            cols(cols<1) = size(grid, 2);
            cols(cols>size(grid,2)) = 1;
            
            % convert to indices
            indices = sub2ind(size(grid), rows, cols);
            
            neighbors = BeachNode.empty;
            for i = (1:1:length(indices))
                if isnan(indices(i))
                    neighbors(i) = BeachNode(-1, -1, -1, node.Size);
                else
                    neighbors(i) = grid(indices(i));
                end
            end
        end
        
        
        % return 8-connected neighbors counter-clockwise starting from the
        % left
        %  |8|7|6|
        %  |1|0|5|
        %  |2|3|4|
        function [ neighbors ] = Get8Neighbors( node, grid, erode )
            
            cols = [ node.C-1, node.C-1, node.C, node.C+1, node.C+1, node.C+1, node.C, node.C-1 ];
            rows = [ node.R, node.R+1, node.R+1, node.R+1, node.R, node.R-1, node.R-1, node.R-1 ];
                        
            % remove out of bounds neighbors
            rows(rows<1 | rows>size(grid, 1)) = NaN;
            cols(isnan(rows)) = NaN;
            cols(cols<1) = size(grid, 2);
            cols(cols>size(grid,2)) = 1;
            
            % convert to indices
            indices = sub2ind(size(grid), rows, cols);
            
            % reorder
            angle = round(node.Prev.GetAngle(node)/(pi/4))*(pi/4);
            switch angle
                case {0, pi}
                    start_index = 1;
                case pi/4
                    start_index = 8;
                case pi/2
                    start_index = 7;
                case 3*pi/4
                    start_index = 6;
                case {pi, -pi}
                    start_index = 5;
                case -pi/4
                    start_index = 2;
                case -pi/2
                    start_index = 3;
                case -3*pi/4
                    start_index = 4;
            end
            if start_index > 1
                indices = [ indices(start_index: end), indices(1: start_index-1)];
            end
            
            % reverse search direction if retreating            
            if erode
                indices = fliplr(indices);
                indices = [indices(end), indices(1:end-1)];
            end
                
            
            neighbors = BeachNode.empty;
            for i = (1:1:length(indices))
                if isnan(indices(i))
                    neighbors(i) = BeachNode(-1, -1, -1, node.Size);
                else
                    neighbors(i) = grid(indices(i));
                end
            end
        end
    end
end