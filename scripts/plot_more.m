% Additional MATLAB plots that are convenient with built-in functions.

raw_path = '../data/raw.csv';
fig_dir = '../paper/figures';
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
fig = figure('Color', 'white');
% Compute correlation using corrcoef (no toolbox required)
corr_mat = corrcoef(data);
imagesc(corr_mat);
axis equal tight;
colormap(parula);
colorbar;
set(gca, 'XTick', 1:numel(num_names), 'XTickLabel', num_names, ...
	'YTick', 1:numel(num_names), 'YTickLabel', num_names, ...
	'XTickLabelRotation', 45, 'Color', 'white');
title('Raw data correlation');
saveas(fig, '../paper/figures/raw_correlation.png');
close(fig);

% 3D scatter using first three numeric columns.
if size(data, 2) >= 3
	fig = figure('Color', 'white');
	scatter3(data(:, 1), data(:, 2), data(:, 3), 30, t, 'filled');
	xlabel(num_names{1});
	ylabel(num_names{2});
	zlabel(num_names{3});
	title('3D scatter colored by time');
	grid on;
	set(gca, 'Color', 'white');
	colorbar;
	saveas(fig, '../paper/figures/raw_scatter3d.png');
	close(fig);
end

% Frequency spectrum of the first numeric series.
if numel(t) >= 64
	fig = figure('Color', 'white');
	x = data(:, 1);
	fs = 1 / median(diff(t));
	if ~isfinite(fs) || fs <= 0
		fs = 1;
	end
	% Compute FFT
	n = length(x);
	X = fft(x);
	freqs = (0:n-1) * fs / n;
	mag = abs(X) / n;
	% Plot one-sided spectrum
	plot(freqs(1:n/2), mag(1:n/2));
	xlabel('Frequency');
	ylabel('Magnitude');
	title(['Frequency spectrum: ', num_names{1}]);
	set(gca, 'Color', 'white');
	grid on;
	saveas(fig, '../paper/figures/raw_spectrogram.png');
	close(fig);
end
