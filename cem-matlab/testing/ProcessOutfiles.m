close all, clear all
%%
dir_name = '../../../cem/output';
dir_contents = dir(dir_name);

for i = (1:1:length(dir_contents))
    file = dir_contents(i);
    if ~file.isdir
        time_step_str = regexp(file.name,'\d*', 'match');
        time_step  = str2num(time_step_str{1});
        file_id = fopen([dir_name, '/', file.name]);
        dims = strsplit(fgetl(file_id));
        data = fscanf(file_id, '%f', [str2num(dims{2}), str2num(dims{1})]);
        Process(flipud(data'), time_step);
        fclose(file_id);
    end
end