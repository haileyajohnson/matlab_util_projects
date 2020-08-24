function [] = process( shoreline, wave_angle, beach_grid, t )
hfig = figure();
set(hfig, 'position', [100 100 800 800]);

curr = shoreline;
do = 1;
R = [];
C = [];
while ~eq(curr, shoreline) | do
    if curr.C == 1 && ~do
        C(end+1) = size(beach_grid, 2)+.5;
    else
        C(end+1) = curr.C-.5;
    end
    R(end+1) = curr.R - 1 + curr.FracFull;
    do = 0;
    curr = curr.Next;
end

plot(C, R, '-o');

xlim([-1 size(beach_grid, 2)+1]);
ylim([0 size(beach_grid, 1)]);
set(gca, 'XTick', (0:1:size(beach_grid, 2)));
set(gca, 'YTick', (1:1:size(beach_grid, 1)));
grid on

axes('Position',[.68 .68 .2 .2])
rose(wave_angle);
view(270, 90);
axis off

print(['output/output', num2str(t)], '-dpng');
close
end

