function s = rs_fmt(v, spec)
if nargin < 2, spec = '%.2f'; end
s = sprintf(spec, v);
end
