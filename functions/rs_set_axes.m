function rs_set_axes(ax, S)
set(ax, 'FontName', S.font, 'FontSize', S.tick, 'LineWidth', S.lw_axis, ...
    'Box', 'on', 'XGrid', 'off', 'YGrid', 'off', 'TickDir', 'out');
end
