function rs_labels(ax, S, xl, yl)
if ~isempty(xl), xlabel(ax, xl, 'FontName', S.font, 'FontSize', S.label); end
if ~isempty(yl), ylabel(ax, yl, 'FontName', S.font, 'FontSize', S.label); end
end
