function [fname, fc, label] = rs_ottawa(C, name)
switch name(1)
    case 'I'
        sub = '2 Data collected from a bearing with inner race fault'; fc = 5.415; label = 'BPFI';
    case 'O'
        sub = '3 Data collected from a bearing with outer race fault'; fc = 3.585; label = 'BPFO';
    otherwise
        sub = '1 Data collected from a healthy bearing'; fc = NaN; label = '';
end
fname = fullfile(C.data_dir, sub, [name '.mat']);
if ~exist(fname, 'file')
    error('Data file not found: %s', fname);
end
end
