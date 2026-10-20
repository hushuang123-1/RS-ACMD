function s = rs_pm(v, spec)
if nargin < 2, spec = '%.2f'; end
s = sprintf([spec ' +/- ' spec], mean(v), std(v));
end
