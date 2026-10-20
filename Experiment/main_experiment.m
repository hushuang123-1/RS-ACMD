clear; close all; clc;
root = fileparts(mfilename('fullpath'));
if isempty(root), root = pwd; end
addpath(fullfile(root, '..', 'functions'));
rs_check_dependencies();
C.data_dir = fullfile(root, 'Data');
fig_dir = fullfile(root, 'Figures');
tab_dir = fullfile(root, 'Tables');
res_dir = fullfile(root, 'Results');
cellfun(@(d) exist(d,'dir') || mkdir(d), {fig_dir, tab_dir, res_dir});
S = rs_style();

RUN.figs14_17_tables6_7 = true;
RUN.table8              = true;
RUN.fig20_table10       = true;
RUN.fig21_table11       = true;

main6 = {'I-A-2','I-A-3','I-B-1','O-A-2','O-A-3','O-B-1'};
N_REP = 3;

if RUN.figs14_17_tables6_7
    [fname, fc, lab] = rs_ottawa(C, 'O-A-2');
    fprintf('\nSection 4.1.2  RS-ACMD on O-A-2\n');
    P = rs_preprocess(fname, fc);
    [eIF, ~, IMF, info] = RSACMD(P.env_ds, P.cfg.fs_env, P.guide, 0.4);
    [im, IF_rs, IMF_rs] = rs_select_mode(eIF, IMF, P.guide);
    P_rs = rs_order_spec(IMF_rs, P.th_env, P.N_ang);
    fprintf('  %d modes (stop: %s), mode %d selected, IF MAE %.2f Hz, FSNR %.2f\n', ...
        info.n_mode, info.stop_reason, im, mean(abs(IF_rs - P.guide)), rs_fsnr(P_rs, P.oa, fc));

    t_orig = (0:length(P.ch1_orig)-1)/P.cfg.fs_orig;
    [fig, ax] = rs_new_figure(900, 440, [0.13 0.20 0.83 0.72]);
    plot(ax, t_orig(1:100:end), P.ch1_orig(1:100:end), 'LineWidth', 0.5, 'Color', S.blue);
    rs_labels(ax, S, 'Time (s)', 'Acceleration (m/s^2)'); rs_set_axes(ax, S); xlim(ax, [0 10]);
    rs_save_figure(fig, fig_dir, 'Fig14');
    idx = 1:500:length(P.t_fr);
    [fig, ax] = rs_new_figure(900, 420, [0.13 0.20 0.83 0.72]);
    plot(ax, P.t_fr(idx), P.fr_sm(idx), 'LineWidth', S.lw_ref, 'Color', S.blue);
    rs_labels(ax, S, 'Time (s)', 'f_r (Hz)'); rs_set_axes(ax, S); xlim(ax, [0 10]);
    rs_save_figure(fig, fig_dir, 'Fig15a');
    [fig, ax] = rs_new_figure(900, 420, [0.13 0.20 0.83 0.72]);
    plot(ax, P.t_fr(idx), P.FCF_sm(idx), 'LineWidth', S.lw_ref, 'Color', S.red);
    rs_labels(ax, S, 'Time (s)', [lab ' (Hz)']); rs_set_axes(ax, S); xlim(ax, [0 10]);
    ylim(ax, [min(P.FCF_sm(idx))*0.95, max(P.FCF_sm(idx))*1.05]);
    rs_save_figure(fig, fig_dir, 'Fig15b');
    [fig, ax] = rs_new_figure(680, 680, [0.17 0.13 0.78 0.82]);
    h1 = plot(ax, P.t_env, P.guide, 'b-', 'LineWidth', S.lw_ref);
    h2 = plot(ax, P.t_env, IF_rs, '--', 'LineWidth', S.lw_signal, 'Color', S.green);
    rs_labels(ax, S, 'Time (s)', 'Frequency (Hz)');
    legend(ax, [h1 h2], {['Theoretical ' lab], 'Extracted IF'}, 'FontName', S.font, 'FontSize', S.leg, 'Location', 'northwest');
    rs_set_axes(ax, S); xlim(ax, [0 10]);
    rs_save_figure(fig, fig_dir, 'Fig16d_RSACMD');
    [fig, ax] = rs_new_figure(820, 740, [0.15 0.13 0.80 0.82]);
    plot(ax, P.oa, P_rs, 'LineWidth', 0.8, 'Color', S.green);
    xlim(ax, [2 15]); ylim(ax, [0 max(P_rs)*1.20]);
    rs_labels(ax, S, 'Order', 'Amplitude'); rs_set_axes(ax, S);
    rs_save_figure(fig, fig_dir, 'Fig17d_RSACMD');

    fprintf('\nSection 4.1.3  RS-ACMD on the six datasets of Table 4\n');
    n = numel(main6);
    V = zeros(n, 5);
    for di = 1:n
        [fname, fc] = rs_ottawa(C, main6{di});
        P = rs_preprocess(fname, fc);
        [eIF, ~, IMF, info] = RSACMD(P.env_ds, P.cfg.fs_env, P.guide, 0.4);
        [im, IF_rs, IMF_rs] = rs_select_mode(eIF, IMF, P.guide);
        tt = zeros(1, N_REP);
        for r = 1:N_REP, t0 = tic; RSACMD(P.env_ds, P.cfg.fs_env, P.guide, 0.4); tt(r) = toc(t0); end
        V(di,:) = [mean(abs(IF_rs - P.guide)), rs_fsnr(rs_order_spec(IMF_rs, P.th_env, P.N_ang), P.oa, fc), ...
                   sum(IMF_rs.^2)/sum(P.env_ds.^2), info.n_mode, mean(tt)];
        fprintf('  %s  IF MAE %.2f Hz  FSNR %.2f\n', main6{di}, V(di,1), V(di,2));
    end
    rows = cell(n+1, 6);
    for di = 1:n
        rows(di,:) = {main6{di}, rs_fmt(V(di,1)), rs_fmt(V(di,2)), rs_fmt(V(di,3),'%.4f'), sprintf('%d', V(di,4)), rs_fmt(V(di,5))};
    end
    m = mean(V, 1);
    rows(end,:) = {'Average', rs_fmt(m(1)), rs_fmt(m(2)), rs_fmt(m(3),'%.4f'), rs_fmt(m(4),'%.1f'), rs_fmt(m(5))};
    rs_write_table(tab_dir, 'Tables6_7_RSACMD', {'Dataset','IF MAE (Hz)','FSNR','E_ratio','Modes','Time (s)'}, rows, ...
        sprintf('Tables 6 and 7 (RS-ACMD), E_ratio and computation time (mean of %d runs)', N_REP));
    save(fullfile(res_dir, 'tables6_7_RSACMD.mat'), 'main6', 'V');
end

if RUN.table8
    fprintf('\nSection 4.1.3  RS-ACMD on all 24 faulty records\n');
    faults = {'I','O'}; fnames = {'Inner race','Outer race'};
    profiles = {'A','B','C','D'};
    pnames = {'Increasing','Decreasing','Increasing-decreasing','Decreasing-increasing'};
    MAE8 = zeros(2,4,3); FSNR8 = MAE8;
    for fi = 1:2
        for pf = 1:4
            for tr = 1:3
                name = sprintf('%s-%s-%d', faults{fi}, profiles{pf}, tr);
                [fname, fc] = rs_ottawa(C, name);
                P = rs_preprocess(fname, fc);
                [eIF, ~, IMF] = RSACMD(P.env_ds, P.cfg.fs_env, P.guide, 0.4);
                [~, IF_rs, IMF_rs] = rs_select_mode(eIF, IMF, P.guide);
                MAE8(fi,pf,tr)  = mean(abs(IF_rs - P.guide));
                FSNR8(fi,pf,tr) = rs_fsnr(rs_order_spec(IMF_rs, P.th_env, P.N_ang), P.oa, fc);
                fprintf('  %s  IF MAE %.2f Hz  FSNR %.1f\n', name, MAE8(fi,pf,tr), FSNR8(fi,pf,tr));
            end
        end
    end
    rows = cell(9, 3); i = 0;
    for fi = 1:2
        for pf = 1:4
            i = i + 1;
            rows(i,:) = {[fnames{fi} ' / ' pnames{pf}], rs_pm(squeeze(MAE8(fi,pf,:))), rs_pm(squeeze(FSNR8(fi,pf,:)), '%.1f')};
        end
    end
    rows(9,:) = {'All 24 records', rs_pm(MAE8(:)), rs_pm(FSNR8(:), '%.1f')};
    rs_write_table(tab_dir, 'Table8_RSACMD', {'Fault / speed profile','IF MAE (Hz)','FSNR'}, rows, ...
        'Table 8 (RS-ACMD)  mean +/- standard deviation over three trials');
    save(fullfile(res_dir, 'table8_RSACMD.mat'), 'MAE8', 'FSNR8');
end

if RUN.fig20_table10
    fprintf('\nSection 4.1.5  Sensitivity to the guidance-frequency offset\n');
    delta = [-0.15 -0.12 -0.10 -0.08 -0.06 -0.05 -0.04 -0.03 -0.02 -0.01 0 ...
              0.01 0.02 0.03 0.04 0.05 0.06 0.08 0.10 0.12 0.15];
    nd = numel(delta); i0 = find(delta == 0); n = numel(main6);
    MAE_d = zeros(n, nd); FSNRm_d = MAE_d; mean_ff = zeros(1, n); coef = zeros(1, n);
    for di = 1:n
        [fname, fc] = rs_ottawa(C, main6{di});
        coef(di) = fc;
        P = rs_preprocess(fname, fc);
        mean_ff(di) = mean(P.guide);
        P_env = rs_order_spec(P.env_ds, P.th_env, P.N_ang);
        for ei = 1:nd
            gb = max(P.guide*(1+delta(ei)), 1);
            [eIF, ~, IMF] = RSACMD(P.env_ds, P.cfg.fs_env, gb, 0.4);
            [~, IFb, IMFb] = rs_select_mode(eIF, IMF, gb);
            MAE_d(di,ei)   = mean(abs(IFb - P.guide));
            FSNRm_d(di,ei) = rs_fsnr(rs_order_spec(IMFb, P.th_env, P.N_ang), P.oa, fc, P_env);
        end
        fprintf('  %s  IF MAE (Hz), delta = -15 ... +15 %%:', main6{di}); fprintf(' %.2f', MAE_d(di,:)); fprintf('\n');
    end
    rows = cell(n, 5); win = zeros(n, 2);
    for di = 1:n
        ok = MAE_d(di,:) <= 3*MAE_d(di,i0);
        lo = i0; while lo > 1  && ok(lo-1), lo = lo - 1; end
        hi = i0; while hi < nd && ok(hi+1), hi = hi + 1; end
        win(di,:) = delta([lo hi]);
        rows(di,:) = {main6{di}, rs_fmt(coef(di),'%.3f'), rs_fmt(mean_ff(di),'%.1f'), rs_fmt(MAE_d(di,i0)), ...
                      sprintf('[%+.0f%%, %+.0f%%]', 100*win(di,1), 100*win(di,2))};
    end
    rs_write_table(tab_dir, 'Table10_tolerance_window', {'Dataset','c_fault','mean f_fault (Hz)','MAE at delta = 0 (Hz)','Tolerance window'}, rows, ...
        'Table 10  Tolerance window of the guidance-frequency offset (IF MAE within three times its value at delta = 0)');
    fprintf('  Window contained in every dataset: +/-%.0f %%\n', 100*min(min(abs(win(:,1))), min(win(:,2))));
    colors = lines(n);
    [fig, ax] = rs_new_figure(1000, 760, [0.13 0.13 0.82 0.82]);
    thr = 0.05*mean_ff;
    patch([-17 17 17 -17], [min(thr) min(thr) max(thr) max(thr)], [1 0.85 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Parent', ax);
    hl = zeros(1, n);
    for di = 1:n
        hl(di) = plot(ax, delta*100, MAE_d(di,:), '-o', 'Color', colors(di,:), 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', colors(di,:));
    end
    rs_labels(ax, S, 'Guidance frequency offset \delta (%)', 'IF MAE (Hz)');
    legend(ax, hl, main6, 'FontName', S.font, 'FontSize', 13, 'Location', 'north');
    rs_set_axes(ax, S); xlim(ax, [-17 17]); ylim(ax, [0 20]);
    rs_save_figure(fig, fig_dir, 'Fig20a');
    [fig, ax] = rs_new_figure(1050, 760, [0.14 0.13 0.81 0.82]);
    for di = 1:n
        hl(di) = plot(ax, delta*100, FSNRm_d(di,:), '-s', 'Color', colors(di,:), 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', colors(di,:));
    end
    set(ax, 'YScale', 'log');
    rs_labels(ax, S, 'Guidance frequency offset \delta (%)', 'FSNR_{mix} (log scale)');
    legend(ax, hl, main6, 'FontName', S.font, 'FontSize', 13, 'Location', 'south');
    rs_set_axes(ax, S); xlim(ax, [-17 17]);
    rs_save_figure(fig, fig_dir, 'Fig20b');
    save(fullfile(res_dir, 'fig20_table10.mat'), 'delta', 'MAE_d', 'FSNRm_d', 'win', 'mean_ff');
end

if RUN.fig21_table11
    fprintf('\nSection 4.1.6  Healthy (12 cases) and faulty (6 cases) bearings\n');
    hnames = {'H-A-1','H-A-2','H-A-3','H-B-1','H-B-2','H-B-3'};
    cases = {};
    for k = 1:numel(hnames)
        cases(end+1,:) = {[hnames{k} ' / BPFI'], hnames{k}, 5.415, 0};
        cases(end+1,:) = {[hnames{k} ' / BPFO'], hnames{k}, 3.585, 0};
    end
    for k = 1:numel(main6)
        [~, fc] = rs_ottawa(C, main6{k});
        cases(end+1,:) = {main6{k}, main6{k}, fc, 1};
    end
    ns = size(cases, 1); lbl = cell2mat(cases(:,4));
    desc = {'FSNR (Eq. (18))','FSNR with envelope noise floor','Peak amplitude / envelope RMS','E_ratio','Kurtosis of instantaneous amplitude'};
    W = zeros(ns, 5);
    for si = 1:ns
        fc = cases{si,3};
        P  = rs_preprocess(rs_ottawa(C, cases{si,2}), fc);
        [eIF, ~, IMF] = RSACMD(P.env_ds, P.cfg.fs_env, P.guide, 0.4);
        [~, ~, IMF_rs] = rs_select_mode(eIF, IMF, P.guide);
        P_mode = rs_order_spec(IMF_rs, P.th_env, P.N_ang);
        P_env  = rs_order_spec(P.env_ds, P.th_env, P.N_ang);
        [f_self, pk] = rs_fsnr(P_mode, P.oa, fc);
        W(si,:) = [f_self, rs_fsnr(P_mode, P.oa, fc, P_env), pk/rms(P.env_ds), ...
                   sum(IMF_rs.^2)/sum(P.env_ds.^2), rs_kurtosis(abs(hilbert(IMF_rs)))];
        fprintf('  %-14s FSNR %8.2f  FSNR_mix %7.2f  A_norm %.4f  E_ratio %.4f  Kurt %.2f\n', cases{si,1}, W(si,:));
    end
    spec = {'%.2f','%.2f','%.4f','%.4f','%.2f'};
    rows = cell(5, 4);
    for k = 1:5
        vh = W(lbl==0,k); vf = W(lbl==1,k);
        rows(k,:) = {desc{k}, rs_fmt(max(vh), spec{k}), rs_fmt(min(vf), spec{k}), rs_fmt(rs_auc(vh, vf), '%.3f')};
    end
    rs_write_table(tab_dir, 'Table11_separability', {'Indicator','Healthy (max)','Faulty (min)','AUC'}, rows, ...
        'Table 11  Separability of healthy (12 cases) and faulty (6 cases) bearings');
    fprintf('  E_ratio threshold: %.4f\n', sqrt(max(W(lbl==0,4))*min(W(lbl==1,4))));
    show = [4 3]; tags = {'a','b'}; ylab = {'E\_ratio','A\_norm'};
    for p = 1:2
        v = W(:,show(p));
        [fig, ax] = rs_new_figure(900, 660, [0.17 0.12 0.78 0.83]);
        plot(ax, ones(sum(lbl==0),1), v(lbl==0), 'o', 'LineStyle', 'none', 'MarkerSize', 10, 'MarkerFaceColor', S.blue, 'MarkerEdgeColor', 'k');
        plot(ax, 2*ones(sum(lbl==1),1), v(lbl==1), 'o', 'LineStyle', 'none', 'MarkerSize', 10, 'MarkerFaceColor', S.green, 'MarkerEdgeColor', 'k');
        if min(v(lbl==1)) > max(v(lbl==0))
            plot(ax, [0.5 2.5], sqrt(max(v(lbl==0))*min(v(lbl==1)))*[1 1], 'r--', 'LineWidth', 2);
        end
        set(ax, 'YScale', 'log', 'XTick', [1 2], 'XTickLabel', {'Healthy','Faulty'}, 'FontName', S.font, ...
            'FontSize', 18, 'LineWidth', 2, 'Box', 'on', 'TickDir', 'out');
        xlim(ax, [0.5 2.5]);
        ylabel(ax, ylab{p}, 'FontName', S.font, 'FontSize', 20);
        rs_save_figure(fig, fig_dir, ['Fig21' tags{p}]);
    end
    save(fullfile(res_dir, 'fig21_table11.mat'), 'cases', 'W');
end
fprintf('\nFigures: %s\nTables: %s\n', fig_dir, tab_dir);
