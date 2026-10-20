function rs_write_table(folder, name, header, rows, caption)
if nargin < 5, caption = name; end
if ~exist(folder, 'dir'), mkdir(folder); end
fid = fopen(fullfile(folder, [name '.csv']), 'w');
fprintf(fid, '%s\n', strjoin(header, ','));
for i = 1:size(rows, 1)
    fprintf(fid, '%s\n', strjoin(cellfun(@csv_cell, rows(i,:), 'UniformOutput', false), ','));
end
fclose(fid);
w = zeros(1, numel(header));
for j = 1:numel(header)
    w(j) = numel(header{j});
    for i = 1:size(rows, 1)
        w(j) = max(w(j), numel(rows{i,j}));
    end
end
fprintf('\n%s\n', caption);
fprintf('%s\n', pad_row(header, w));
fprintf('%s\n', repmat('-', 1, sum(w) + 2*numel(w)));
for i = 1:size(rows, 1)
    fprintf('%s\n', pad_row(rows(i,:), w));
end
fprintf('  saved %s\n', fullfile(folder, [name '.csv']));
end

function s = pad_row(c, w)
s = '';
for j = 1:numel(c)
    s = [s, c{j}, repmat(' ', 1, w(j) - numel(c{j}) + 2)];
end
end

function s = csv_cell(s)
if any(s == ',') || any(s == '"')
    s = ['"' strrep(s, '"', '""') '"'];
end
end
