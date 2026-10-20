clear; close all; clc;
root = fileparts(mfilename('fullpath'));
if isempty(root), root = pwd; end
addpath(fullfile(root, '..', 'functions'));
rs_check_dependencies();
fig_dir = fullfile(root, 'Figures');
tab_dir = fullfile(root, 'Tables');
res_dir = fullfile(root, 'Results');
cellfun(@(d) exist(d,'dir') || mkdir(d), {fig_dir, tab_dir, res_dir});
S = rs_style();

fs_env      = 1000;
T_sim       = 12;
N_env       = T_sim*fs_env;
t_env       = (0:N_env-1)/fs_env;
pts_per_rev = 200;
fr_high = 30; fr_low = 10;
fr_env  = fr_high - (fr_high-fr_low)/T_sim*t_env;
fr_norm = (fr_env - fr_low)/(fr_high - fr_low);
c_BPFI    = 5.2;
guide_env = c_BPFI*fr_env;
th_exact  = 2*pi*(fr_high*t_env - (fr_high-fr_low)/(2*T_sim)*t_env.^2);

comp_i1    = 0.22*(0.4+0.6*fr_norm).*cos(2*th_exact);
comp_i2    = 0.15*(0.4+0.6*fr_norm).*cos(3*th_exact);
comp_fault = 0.04*(0.3+0.7*fr_norm).*(1+cos(c_BPFI*th_exact))/2;
bg = zeros(1,N_env); rng(42);
for k = 1:25
    ord_k = 0.3+rand*13.5; amp_k = 0.006+rand*0.012;
    bg = bg + amp_k*(0.3+0.7*fr_norm).*cos(ord_k*th_exact+2*pi*rand);
end
rng(2024);
noise_env = 0.012*(0.5+0.5*fr_norm).*randn(1,N_env);
env_ds = comp_i1 + comp_i2 + comp_fault + bg + noise_env;
env_ds = env_ds - mean(env_ds);
N_ang  = 2*round(th_exact(end)/(2*pi)*pts_per_rev/2);
oa     = (0:N_ang/2)/(N_ang/pts_per_rev);

fprintf('\nSection 3.1  Simulated signal\n');
fprintf('  Mean amplitude ratio 2xfr interference / fault component: %.1f\n', ...
    mean(abs(comp_i1)) / mean(abs(comp_fault - mean(comp_fault))));
fprintf('  Energy share of the fault component: %.2f %% (%.2f %% after removing its mean)\n', ...
    rms(comp_fault)^2/rms(env_ds)^2*100, rms(comp_fault-mean(comp_fault))^2/rms(env_ds)^2*100);

fprintf('\nSection 3.2  RS-ACMD on the simulated signal\n');
t0 = tic;
[eIF, ~, IMF, info] = RSACMD(env_ds, fs_env, guide_env, 0.4);
[im, IF_rs, IMF_rs] = rs_select_mode(eIF, IMF, guide_env);
t_rs = toc(t0);
P_rs = rs_order_spec(IMF_rs, th_exact, N_ang);
mae  = mean(abs(IF_rs - guide_env));
fsnr = rs_fsnr(P_rs, oa, c_BPFI);
er   = sum(IMF_rs.^2)/sum(env_ds.^2);
rs_write_table(tab_dir, 'Section3_2_RSACMD', {'Quantity','Value'}, ...
    {'IF MAE (Hz)', rs_fmt(mae); 'FSNR', rs_fmt(fsnr); 'E_ratio', rs_fmt(er,'%.4f'); ...
     'Modes extracted', sprintf('%d', info.n_mode); 'Selected mode (Eq. (14))', sprintf('%d', im); ...
     'Stop reason', info.stop_reason; 'Computation time (s)', rs_fmt(t_rs)}, ...
    'Section 3.2  RS-ACMD on the simulated signal (Figs. 6(d) and 7(d))');

[fig, ax] = rs_new_figure(900, 420, [0.13 0.20 0.83 0.72]);
plot(ax, t_env, env_ds, 'LineWidth', 0.6, 'Color', S.blue);
rs_labels(ax, S, 'Time (s)', 'Amplitude'); rs_set_axes(ax, S); xlim(ax, [0 T_sim]);
rs_save_figure(fig, fig_dir, 'Fig03');

comps = {comp_i1(1:5:end), comp_i2(1:5:end), comp_fault(1:5:end)};
ccol  = {S.red, S.red, S.green};
tags  = {'a','b','c'};
for k = 1:3
    [fig, ax] = rs_new_figure(1100, 230, [0.09 0.30 0.87 0.62]);
    plot(ax, t_env(1:5:end), comps{k}, 'LineWidth', 0.9, 'Color', ccol{k});
    if k == 3, xl = 'Time (s)'; else, xl = ''; end
    rs_labels(ax, S, xl, 'Amp.'); rs_set_axes(ax, S); xlim(ax, [0 T_sim]);
    ylim(ax, [min(comps{k})*1.3, max(comps{k})*1.3]);
    rs_save_figure(fig, fig_dir, ['Fig04' tags{k}]);
end

[fig, ax] = rs_new_figure(900, 420, [0.13 0.20 0.83 0.72]);
plot(ax, t_env(1:10:end), fr_env(1:10:end), 'LineWidth', S.lw_ref, 'Color', S.blue);
rs_labels(ax, S, 'Time (s)', 'f_r (Hz)'); rs_set_axes(ax, S); xlim(ax, [0 T_sim]); ylim(ax, [8 33]);
rs_save_figure(fig, fig_dir, 'Fig05a');
[fig, ax] = rs_new_figure(900, 420, [0.13 0.20 0.83 0.72]);
plot(ax, t_env(1:10:end), guide_env(1:10:end), 'LineWidth', S.lw_ref, 'Color', S.red);
rs_labels(ax, S, 'Time (s)', 'BPFI (Hz)'); rs_set_axes(ax, S); xlim(ax, [0 T_sim]);
ylim(ax, [min(guide_env)*0.92, max(guide_env)*1.08]);
rs_save_figure(fig, fig_dir, 'Fig05b');

[fig, ax] = rs_new_figure(700, 680, [0.17 0.13 0.78 0.82]);
h1 = plot(ax, t_env, guide_env, 'b-', 'LineWidth', S.lw_ref);
h2 = plot(ax, t_env, IF_rs, '--', 'LineWidth', S.lw_signal, 'Color', S.green);
rs_labels(ax, S, 'Time (s)', 'Frequency (Hz)');
legend(ax, [h1 h2], {'True BPFI','Extracted IF'}, 'FontName', S.font, 'FontSize', S.leg, 'Location', 'northeast');
rs_set_axes(ax, S); xlim(ax, [0 T_sim]);
rs_save_figure(fig, fig_dir, 'Fig06d_RSACMD');

[fig, ax] = rs_new_figure(940, 630, [0.13 0.15 0.82 0.80]);
plot(ax, oa, P_rs, 'LineWidth', 0.8, 'Color', S.green);
xlim(ax, [1 15]); ylim(ax, [0 max(P_rs)*1.20]);
rs_labels(ax, S, 'Order', 'Amplitude'); rs_set_axes(ax, S);
rs_save_figure(fig, fig_dir, 'Fig07d_RSACMD');

fprintf('\nSection 3.3  Verification against the ground truth (1.5 %% slip)\n');
slip     = 0.015*(1+0.3*sin(2*pi*0.15*t_env));
IF_true  = c_BPFI*fr_env.*(1-slip);
fault_tr = 0.04*(0.3+0.7*fr_norm).*(1+cos(2*pi*cumsum(IF_true)/fs_env))/2;
mae_th = zeros(1,5); mae_tr = zeros(1,5);
for k = 1:5
    rng(3000+k);
    xk = comp_i1 + comp_i2 + fault_tr + bg + 0.012*(0.5+0.5*fr_norm).*randn(1,N_env);
    xk = xk - mean(xk);
    [eIF, ~, IMF] = RSACMD(xk, fs_env, guide_env, 0.4);
    [~, IFk] = rs_select_mode(eIF, IMF, guide_env);
    mae_th(k) = mean(abs(IFk - guide_env));
    mae_tr(k) = mean(abs(IFk - IF_true));
    if k == 1, IF_ext = IFk; end
end
rs_write_table(tab_dir, 'Section3_3_ground_truth', {'Quantity','Value'}, ...
    {'Mean |theoretical IF - true IF| (Hz)', rs_fmt(mean(abs(guide_env-IF_true))); ...
     'IF MAE w.r.t. theoretical IF (Hz)', rs_pm(mae_th, '%.3f'); ...
     'IF MAE w.r.t. true IF (Hz)', rs_pm(mae_tr, '%.3f')}, ...
    'Section 3.3  Ground-truth verification (seeds 3001-3005)');

[fig, ax] = rs_new_figure(700, 640, [0.17 0.14 0.78 0.81]);
h1 = plot(ax, t_env, IF_true, 'b-', 'LineWidth', 2);
h2 = plot(ax, t_env, guide_env, 'k:', 'LineWidth', 1.8);
h3 = plot(ax, t_env, IF_ext, '--', 'LineWidth', 1.2, 'Color', S.green);
rs_labels(ax, S, 'Time (s)', 'Frequency (Hz)');
legend(ax, [h1 h2 h3], {'True fault IF','Theoretical (init)','Extracted IF'}, ...
    'FontName', S.font, 'FontSize', 13, 'Location', 'northeast');
rs_set_axes(ax, S); xlim(ax, [0 T_sim]);
rs_save_figure(fig, fig_dir, 'Fig08a');
[fig, ax] = rs_new_figure(700, 640, [0.17 0.14 0.78 0.81]);
plot(ax, t_env, IF_ext - guide_env, 'LineWidth', 1.0, 'Color', S.red);
plot(ax, [0 T_sim], [0 0], 'k--', 'LineWidth', 1.5);
rs_labels(ax, S, 'Time (s)', 'IF_{ext} - IF_{init} (Hz)'); rs_set_axes(ax, S); xlim(ax, [0 T_sim]);
rs_save_figure(fig, fig_dir, 'Fig08b');

fprintf('\nSection 3.4  Noise robustness\n');
sig_clean = comp_fault + comp_i1 + comp_i2;
snr_lv = [20 15 10 5 0 -5];
mae_snr = zeros(1, numel(snr_lv));
for si = 1:numel(snr_lv)
    npw = rms(sig_clean)^2/10^(snr_lv(si)/10);
    rng(si*100); ni = sqrt(npw)*randn(1,N_env);
    bgi = zeros(1,N_env); rng(si*200);
    for k = 1:25
        ord_k = 0.3+rand*13.5; amp_k = 0.006+rand*0.012;
        bgi = bgi + amp_k*(0.3+0.7*fr_norm).*cos(ord_k*th_exact+2*pi*rand);
    end
    env_i = sig_clean + bgi + ni.*(0.5+0.5*fr_norm);
    env_i = env_i - mean(env_i);
    [eIF, ~, IMF] = RSACMD(env_i, fs_env, guide_env, 0.4);
    [~, IFi] = rs_select_mode(eIF, IMF, guide_env);
    mae_snr(si) = mean(abs(IFi - guide_env));
end
rs_write_table(tab_dir, 'Fig09_RSACMD_noise', {'SNR (dB)','RS-ACMD IF MAE (Hz)'}, ...
    [arrayfun(@(v) sprintf('%d', v), snr_lv', 'UniformOutput', false), ...
     arrayfun(@(v) rs_fmt(v), mae_snr', 'UniformOutput', false)], 'Fig. 9  IF MAE of RS-ACMD versus SNR');
[fig, ax] = rs_new_figure(900, 500, [0.13 0.20 0.83 0.72]);
plot(ax, snr_lv, mae_snr, '-d', 'Color', S.green, 'LineWidth', S.lw_ref, 'MarkerSize', 9, 'MarkerFaceColor', S.green);
rs_labels(ax, S, 'SNR (dB)', 'IF MAE (Hz)'); rs_set_axes(ax, S); xlim(ax, [-7 22]); ylim(ax, [0 max(mae_snr)*1.5]);
rs_save_figure(fig, fig_dir, 'Fig09_RSACMD');

save(fullfile(res_dir, 'simulation_results.mat'), 'mae', 'fsnr', 'er', 'mae_th', 'mae_tr', 'snr_lv', 'mae_snr');
fprintf('\nFigures: %s\nTables: %s\n', fig_dir, tab_dir);
