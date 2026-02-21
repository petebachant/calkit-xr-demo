% Additional MATLAB plots that are convenient with built-in functions.

raw_path = fullfile('data', 'raw.csv');
fig_dir = fullfile('paper', 'figures');
if ~exist(fig_dir, 'dir')
	mkdir(fig_dir);
end

tbl = readtable(raw_path);
tbl = rmmissing(tbl);

var_names = tbl.Properties.VariableNames;
is_num = varfun(@isnumeric, tbl, 'OutputFormat', 'uniform');
num_tbl = tbl(:, is_num);
num_names = var_names(is_num);

if isempty(num_names)
	error('No numeric columns found in raw data.');
end

time_name = '';
for i = 1:numel(var_names)
	lower_name = lower(var_names{i});
	if any(strcmp(lower_name, {'time', 't', 'timestamp'}))
		time_name = var_names{i};
		break;
	end
end

if ~isempty(time_name)
	t = tbl.(time_name);
else
	t = (1:height(tbl))';
end

data = table2array(num_tbl);

% Correlation heatmap.
fig = figure('Color', 'w');
corr_mat = corr(data, 'Rows', 'complete');
imagesc(corr_mat);
axis equal tight;
colormap(parula);
colorbar;
set(gca, 'XTick', 1:numel(num_names), 'XTickLabel', num_names, ...
	'YTick', 1:numel(num_names), 'YTickLabel', num_names, ...
	'XTickLabelRotation', 45);
title('Raw data correlation');
saveas(fig, fullfile(fig_dir, 'raw_correlation.png'));

% Parallel coordinates of standardized values.
fig = figure('Color', 'w');
standard = (data - mean(data, 1)) ./ std(data, 0, 1);
parallelcoords(standard, 'Labels', num_names);
title('Parallel coordinates (standardized)');
saveas(fig, fullfile(fig_dir, 'raw_parallelcoords.png'));

% 3D scatter using first three numeric columns.
if size(data, 2) >= 3
	fig = figure('Color', 'w');
	scatter3(data(:, 1), data(:, 2), data(:, 3), 30, t, 'filled');
	xlabel(num_names{1});
	ylabel(num_names{2});
	zlabel(num_names{3});
	title('3D scatter colored by time');
	grid on;
	colorbar;
	saveas(fig, fullfile(fig_dir, 'raw_scatter3d.png'));
end

% Spectrogram of the first numeric series.
if numel(t) >= 64
	fig = figure('Color', 'w');
	x = data(:, 1);
	fs = 1 / median(diff(t));
	if ~isfinite(fs) || fs <= 0
		fs = 1;
	end
	spectrogram(x, 64, 48, 128, fs, 'yaxis');
	title(['Spectrogram: ', num_names{1}]);
	saveas(fig, fullfile(fig_dir, 'raw_spectrogram.png'));
end
