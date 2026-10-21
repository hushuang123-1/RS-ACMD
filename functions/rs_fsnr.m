function [fsnr, pk, nf] = rs_fsnr(P_half, oa, f_coeff, P_den, o_max)
if nargin < 4 || isempty(P_den), P_den = P_half; end
if nargin < 5 || isempty(o_max), o_max = oa(end); end
d_oa  = oa(2) - oa(1);
halfw = max(3, round(0.02*f_coeff/d_oa));
[~,ib] = min(abs(oa - f_coeff));
lo = max(1, ib-halfw);
hi = min(numel(P_half), ib+halfw);
pk = max(P_half(lo:hi));
nm = true(1, numel(oa));
[~,ic3] = min(abs(oa-3));
nm(1:ic3) = false;
nm(oa > o_max) = false;
for n = 1:5
    [~,ic] = min(abs(oa - n*f_coeff));
    nm(max(1,ic-halfw-3):min(numel(nm),ic+halfw+3)) = false;
end
if ~any(nm), nm(end-round(numel(nm)/10):end) = true; end
nf   = mean(P_den(nm));
fsnr = pk / max(nf, eps);
end
