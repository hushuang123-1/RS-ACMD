function [imode, IF_sel, IMF_sel] = rs_select_mode(eIF, IMF, guide)
nmode = size(IMF,1);
mg    = mean(guide);
dev   = zeros(1,nmode);
for m = 1:nmode
    dev(m) = abs(mean(eIF(m,:)) - mg);
end
[~, imode] = min(dev);
IF_sel  = eIF(imode,:);
IMF_sel = IMF(imode,:);
end
