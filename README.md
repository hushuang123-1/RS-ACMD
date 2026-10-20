# RS-ACMD

MATLAB implementation of the rotational speed-guided adaptive chirp mode decomposition (RS-ACMD) of
"Rotational speed-guided adaptive chirp mode decomposition for bearing fault diagnosis under variable speed conditions"
(Structural Health Monitoring).

```
functions/            RSACMD.m and the shared routines (preprocessing, order spectrum, FSNR, mode selection, plotting)
Simulation/           main_simulation.m  -> RS-ACMD results of Section 3 (Figs. 3-5, 6(d), 7(d), 8, 9)
Experiment/           main_experiment.m  -> RS-ACMD results of Section 4.1 (Figs. 14-15, 16(d), 17(d), 20, 21; Tables 6-8 (RS-ACMD), 10, 11)
```

Each main file writes its figures to `Figures/`, its tables to `Tables/` (CSV, also printed in the command window) and the raw results to `Results/`.

## Requirements

* MATLAB R2018b or later with the Signal Processing Toolbox.
* `ACMD.m` of Chen et al. (adaptive chirp mode pursuit, Mechanical Systems and Signal Processing 116 (2019) 566-584), obtained from its authors and placed on the MATLAB path or in `functions/`. RS-ACMD uses it as the single-mode extractor. The time-varying low-pass filtering of the residual follows DD-ACMD (Wang et al.).
* For `Experiment/`: the University of Ottawa variable-speed bearing dataset (Huang and Baddour, Data in Brief 21 (2018) 1745-1749; https://data.mendeley.com/datasets/v43hmbwxpm), unpacked into `Experiment/Data/`:

```
Experiment/Data/1 Data collected from a healthy bearing/H-A-1.mat ...
Experiment/Data/2 Data collected from a bearing with inner race fault/I-A-1.mat ...
Experiment/Data/3 Data collected from a bearing with outer race fault/O-A-1.mat ...
```

## Usage

```matlab
[eIF, eIA, IMF, info] = RSACMD(envelope, fs, guide_IF, 0.4);
[k, IF_fault, mode_fault] = rs_select_mode(eIF, IMF, guide_IF);
```

`guide_IF` is the theoretical fault characteristic frequency computed from the measured rotational speed, sampled like `envelope`.
The comparison methods of the paper were run with the code published by their authors and are not included.
