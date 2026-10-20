function auc = rs_auc(vh, vf)
cnt = 0;
for i = 1:numel(vh)
    for j = 1:numel(vf)
        if vf(j) > vh(i)
            cnt = cnt + 1;
        elseif vf(j) == vh(i)
            cnt = cnt + 0.5;
        end
    end
end
auc = cnt / (numel(vh)*numel(vf));
end
