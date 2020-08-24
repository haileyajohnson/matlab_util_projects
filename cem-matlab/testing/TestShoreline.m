function TestShoreline( shoreline, beach_grid )

%% plot reconstructed shoreline
hfig = figure();
set(hfig, 'position', [100 100 800 800]);

curr = shoreline;
do = 1;
while ~eq(curr, shoreline) | do
    do = 0;
    plot([curr.C-1, curr.C], [curr.R-1 + curr.FracFull, curr.R-1 + curr.FracFull], 'b-', 'linewidth', 1.5);
    hold on
    curr = curr.Next;
end

xlim([-1 size(beach_grid, 2)+1]);
ylim([0 size(beach_grid, 1)]);
set(gca, 'XTick', (0:1:size(beach_grid, 2)));
set(gca, 'YTick', (1:1:size(beach_grid, 1)));
grid on

%% plot left angles
curr = shoreline;
do = 1;
while ~eq(curr, shoreline) | do
    do = 0;
    [angle, dist] = GetAngle(curr.Prev, curr);
    angle = angle + atan2(curr.FracFull - curr.Prev.FracFull, dist);
    delta_c = cos(angle)/2;
    delta_r = sin(angle)/2;
    plot([curr.C-1-delta_c, curr.C-1+delta_c], [curr.R-delta_r , curr.R+delta_r], 'r-', 'linewidth', 1.3);
    hold on
    curr = curr.Next;
end

%% plot right angles
curr = shoreline;
do = 1;
while ~eq(curr, shoreline) | do
    do = 0;
    [angle, dist] = GetAngle(curr, curr.Next);
    angle = angle + atan2(curr.Next.FracFull - curr.FracFull, dist);
    delta_c = cos(angle)/2;
    delta_r = sin(angle)/2;
    plot([curr.C-delta_c, curr.C+delta_c], [curr.R-delta_r , curr.R+delta_r], 'm-', 'linewidth', 1.2);
    hold on
    curr = curr.Next;
end


%% plot surrounding angles
curr = shoreline;
do = 1;
while ~eq(curr, shoreline) | do
    do = 0;
    [angle, dist] = GetAngle(curr.Prev, curr.Next);
    angle = angle + atan2(curr.Next.FracFull - curr.Prev.FracFull, dist);
    delta_c = cos(angle);
    delta_r = sin(angle)/2;
    plot([curr.C-1-delta_c, curr.C+delta_c], [curr.R-delta_r , curr.R+delta_r], 'g', 'linewidth', 1.15);
    hold on
    curr = curr.Next;
end

%%
curr = shoreline;
do = 1;
while ~eq(curr, shoreline) | do
    do = 0;
    [~, dir] = curr.ChooseAppropriateAngle(pi/4);
    if dir < 0
        plot(curr.C, curr.R, 'm*');
    elseif dir > 0
        plot(curr.C, curr.R, 'r*');
    else
        plot(curr.C, curr.R, 'g*');
    end
    curr = curr.Next;
end

set(gca, 'ydir', 'reverse')


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

function [ orientation, distance ] = GetOrientation( node1, node2 )

orientation = (pi/4) * (round(atan2(node2.R - node1.R, node2.C - node1.C)/(pi/4)));
distance = sqrt((node2.R-node1.R)^2 + (node2.C - node1.C)^2);

end
