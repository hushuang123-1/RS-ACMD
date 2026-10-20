function P = rs_preprocess(fname, f_coeff, cfg)
if nargin < 3, cfg = struct(); end
if ~isfield(cfg,'fs_orig'),        cfg.fs_orig        = 200000; end
if ~isfield(cfg,'fs_env'),         cfg.fs_env         = 1000;   end
if ~isfield(cfg,'ds_factor'),      cfg.ds_factor      = 200;    end
if ~isfield(cfg,'pulses_per_rev'), cfg.pulses_per_rev = 1000;   end
if ~isfield(cfg,'pts_per_rev'),    cfg.pts_per_rev    = 200;    end
if ~isfield(cfg,'bp_low'),         cfg.bp_low         = 20000;  end
if ~isfield(cfg,'bp_high'),        cfg.bp_high        = 25000;  end

d        = load(fname);
ch1_orig = d.Channel_1(:)' - mean(d.Channel_1);
ch2_orig = d.Channel_2(:)';

ch2_bin = double(ch2_orig > 2.0);
rising  = find(diff(ch2_bin) > 0);
fr_raw  = cfg.fs_orig ./ diff(rising) / cfg.pulses_per_rev;
t_fr    = rising(1:end-1) / cfg.fs_orig;
fr_sm   = movmean(fr_raw, 200);
FCF_sm  = f_coeff * fr_sm(1:length(t_fr));

[b,a]   = butter(4, [cfg.bp_low,cfg.bp_high]/(cfg.fs_orig/2), 'bandpass');
ch1_bp  = filtfilt(b, a, ch1_orig);
env_raw = abs(hilbert(ch1_bp));
env_raw = env_raw - mean(env_raw);
env_ds  = decimate(env_raw, cfg.ds_factor);

N_env = length(env_ds);
t_env = (0:N_env-1) / cfg.fs_env;
guide = max(interp1(t_fr, FCF_sm, t_env, 'linear', 'extrap'), 10);

t_pls  = rising / cfg.fs_orig;
th_pls = (0:length(rising)-1) * (2*pi/cfg.pulses_per_rev);
th_env = max(interp1(t_pls, th_pls, t_env, 'linear', 'extrap'), 0);

N_ang = 2*round(th_env(end)/(2*pi)*cfg.pts_per_rev / 2);
oa    = (0:N_ang/2) / (N_ang/cfg.pts_per_rev);

P = struct('t_env',t_env,'env_ds',env_ds,'guide',guide,...
           't_fr',t_fr,'fr_sm',fr_sm,'FCF_sm',FCF_sm,...
           'th_env',th_env,'N_ang',N_ang,'oa',oa,...
           'ch1_orig',ch1_orig,'cfg',cfg,'f_coeff',f_coeff);
end
