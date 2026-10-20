function [fig, ax] = rs_new_figure(w, h, pos)
if nargin < 3 || isempty(pos), pos = [0.15 0.16 0.80 0.78]; end
fig = figure('Color', 'w', 'Position', [100 100 w h], 'Visible', 'off');
ax  = axes('Parent', fig, 'Position', pos);
hold(ax, 'on');
end
