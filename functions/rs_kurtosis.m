function k = rs_kurtosis(x)
x = x(:) - mean(x(:));
k = mean(x.^4) / mean(x.^2)^2;
end
