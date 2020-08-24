%%
% Files in the directory must be names such that the that 8 characters are
% formatted YYYYMMDD.mat
function Create_timeline(directory, start_date, end_date)
% get all file names that match the specified pattern
listing = dir(directory);
pattern = 'DEM_CpCnv_\d{8}.mat';
char_array = reshape((char({listing.name}))', 1, []);
valid_names = regexp(char_array, pattern, 'match');
filenames = char(valid_names);

% extract dates
start_date = datenum(start_date, 'YYYYmmDD');
end_date = datenum(end_date, 'YYYYmmDD');
dates = datenum(filenames(:,(end-11:end-4)), 'YYYYmmDD');
timeline = (start_date:1:end_date);
survey_dates = ismember(timeline(1,:), dates);

% plot survey dates
figure(1)
plot(timeline(survey_dates==0), survey_dates(survey_dates==0), 'b.', 'linewidth', 2); hold on
plot(timeline(survey_dates==1), survey_dates(survey_dates==1), 'r*'); hold off
set(gca, 'ylim',[0, 2], 'ytick', []);
datetick('x', 'DD mmm YYYY');
end