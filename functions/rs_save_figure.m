function rs_save_figure(fig, folder, name)
if ~exist(folder, 'dir'), mkdir(folder); end
print(fig, fullfile(folder, [name '.png']), '-dpng', '-r300');
if ispc
    print(fig, fullfile(folder, [name '.emf']), '-dmeta');
end
close(fig);
fprintf('  saved %s\n', fullfile(folder, [name '.png']));
end
