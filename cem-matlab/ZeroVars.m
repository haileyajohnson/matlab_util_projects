function [cells_out ] = ZeroVars( cells )

[rows, cols] = size(cells);

for r = (1:1:rows)
    for c = (1:1:cols)
        cells(r,c).BreakerHeight = NaN;
        cells(r,c).BreakerAlpha = NaN;
        cells(r,c).TransportPotential = NaN;
        cells(r,c).NetVolumeChange = NaN;
    end
end

cells_out = cells;

end

