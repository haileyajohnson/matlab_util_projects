function Process( data, t )
hfig = figure();
set(hfig, 'position', [100 100 800 800]);

[rows, cols] = size(data);
R = [];
C = [];

for r = (1:1:rows)
    for c = (1:1:cols)
        if data(r,c) ~= 0 && data(r,c) ~= 1
            C(end+1) = c-.5;
            R(end+1) = r-1 + data(r,c);
        end
    end
end    

plot(C, R, 'o');

xlim([-1 cols+1]);
ylim([0 rows]);
set(gca, 'XTick', (0:1:cols));
set(gca, 'YTick', (1:1:rows));
grid on

print(['output/output', num2str(t)], '-dpng');
close
end