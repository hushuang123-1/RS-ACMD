function o = rs_omax(th_env, frac)
if nargin < 2 || isempty(frac), frac = 0.8; end
o = frac * pi / max(diff(th_env(:)));
end
