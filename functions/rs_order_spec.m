function P_half = rs_order_spec(sig, th_env, N_ang)
th_uni = linspace(0, th_env(end), N_ang);
sig_rs = interp1(th_env, sig(:)', th_uni, 'linear', 'extrap');
sig_rs = sig_rs - mean(sig_rs);
P_full = abs(fft(sig_rs, N_ang)) / N_ang * 2;
P_half = P_full(1:N_ang/2+1);
end
