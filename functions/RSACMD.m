function [eIF, eIA, IMF, info] = RSACMD(Sig, SampFreq, guide_IF, eta)
if nargin < 4 || isempty(eta), eta = 0.4; end
alpha = 1e-7; beta = 1e-8; tol = 1e-30;
h_list = [1, 2, 0.5, 3, 1.5];
K = numel(h_list);

s   = Sig(:)';
res = s;
N   = length(s);
guide_IF   = guide_IF(:)';
mean_guide = mean(guide_IF);

EIF  = zeros(K, N);
EIA  = zeros(K, N);
EIMF = zeros(K, N);
info = struct('stop_reason','hypothesis_exhausted','n_mode',0);
n_acc = 0;
last  = struct('IF',[],'IA',[],'IMF',[]);

for i = 1:K
    IF0 = h_list(i) * guide_IF;
    [IFset, IAest, sset] = ACMD(res, SampFreq, IF0, alpha, beta, tol);
    IF_i  = IFset(end,:);
    IA_i  = IAest(end,:);
    IMF_i = sset(end,:);
    last.IF = IF_i; last.IA = IA_i; last.IMF = IMF_i;

    if mean(IF_i) < 0 || mean(IF_i) > SampFreq/2
        info.stop_reason = 'physical';
        break
    end
    if min(abs(mean(IF_i) - h_list*mean_guide)) / abs(mean(IF_i)) > eta
        info.stop_reason = 'relevance';
        break
    end

    n_acc = n_acc + 1;
    EIF(n_acc,:)  = IF_i;
    EIA(n_acc,:)  = IA_i;
    EIMF(n_acc,:) = IMF_i;
    res = res - IMF_i;

    if sum(res.^2) / sum(s.^2) < 0.1
        info.stop_reason = 'energy';
        break
    end
    res = TVLP(res, SampFreq, IF_i, max(IF_i));
end

if n_acc == 0
    n_acc = 1;
    EIF(1,:) = last.IF; EIA(1,:) = last.IA; EIMF(1,:) = last.IMF;
end
eIF = EIF(1:n_acc,:);
eIA = EIA(1:n_acc,:);
IMF = EIMF(1:n_acc,:);
info.n_mode = n_acc;
end

function s = TVLP(Sig, SampFreq, EIF, Cpass)
Cpass = min(max(Cpass, 1e-3*SampFreq), 0.45*SampFreq);
t     = 0:1/SampFreq:(length(Sig)-1)/SampFreq;
phase = 2*pi*cumtrapz(t, EIF - Cpass);
z     = hilbert(Sig) .* exp(-1j * phase);
s     = real(lowpass(z, Cpass, SampFreq) .* exp(1j * phase));
end
