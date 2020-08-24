function [ cells ] = Initialize( input_grid, cell_size )
% Initialize  model run

[rows, cols] = size(input_grid);

for r = (1:1:rows)
    for c = (1:1:cols)
        fraction_full = input_grid(r, c);
        cells(r, c) = BeachNode(fraction_full, r,  c, cell_size);
    end
end

end