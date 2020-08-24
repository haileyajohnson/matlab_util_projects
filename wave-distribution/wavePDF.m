close all; clear all;
%% Generate wave angles
A = [.9, .75, .5, .3];
U = [.9, .75, .5, .3];

numWaves = 1000; % number of wave angles to generate

waves = NaN(numWaves, length(A), length(U));  % holds wave angles for A and U values

for i = (1:1:numWaves)
    angle = rand() * (pi/4);    % random angle 0 - pi/4
    asym = rand();              % random variable determining direction of approach
    highness = rand();          % random variable determining above or below 45 degrees 
    waves(i,:,:) = angle;
    for j = (1:1:length(A))
        for k = (1:1:length(U))
            % add pi/4 to angle for any U such that highness > U(k)
            if highness >= U(k)
                waves(i,j,k) = waves(i,j,k) + pi/4;
            end
        end
        % change sign of angle (approach from righ) for any A such than asym > A(j)
        if asym >= A(j)
            waves(i,j,:) = -waves(i,j,:);
        end
    end
    
end

%% create rose plots
hfig = figure();
set(hfig, 'Position', [200, 30, 1200, 1200]);

for j = (1:1:length(A))
    for k = (1:1:length(U))
        subplot(length(A), length(U), sub2ind([length(A) length(U)], k, j))
        rose(waves(:, j, k), 30);
        if k == 1
            ylabel(['A = ' num2str(A(j))])
        end
        if j == length(A)
            xlabel(['U = ' num2str(U(k))])
        end
    end
end


%% create histograms
hfig = figure();
set(hfig, 'Position', [200, 30, 1200, 1200]);

deg_waves = rad2deg(waves);  % convert rad to degrees to ease of labeling
for j = (1:1:length(A))
    for k = (1:1:length(U))
        subplot(length(A), length(U), sub2ind([length(A) length(U)], k, j))
        histogram(deg_waves(:, j, k), 16);
        if k == 1
            ylabel(['A = ' num2str(A(j))])
        end
        if j == length(A)
            xlabel(['U = ' num2str(U(k))])
        end
        xlim([-90 90])
        ylim([0 200])
        set(gca, 'xdir', 'reverse')  % reverse so that positive is left, as in CEM
        grid on
    end
end