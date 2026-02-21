#!/usr/bin/env Rscript

suppressPackageStartupMessages({
	library(ggplot2)
	library(readr)
	library(dplyr)
	library(tidyr)
})

raw_path <- "data/raw.csv"
processed_path <- "data/processed.csv"
fig_dir <- "paper/figures"

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

raw <- read_csv(raw_path, show_col_types = FALSE)
processed <- read_csv(processed_path, show_col_types = FALSE)

raw <- raw %>% mutate(.row = row_number())
processed <- processed %>% mutate(.row = row_number())

numeric_cols <- raw %>%
	select(where(is.numeric)) %>%
	names()

if (length(numeric_cols) == 0) {
	stop("No numeric columns found in raw data.")
}

raw_long <- raw %>%
	select(.row, all_of(numeric_cols)) %>%
	pivot_longer(-.row, names_to = "series", values_to = "value")

processed_cols <- processed %>%
	select(where(is.numeric)) %>%
	names()

processed_long <- processed %>%
	select(.row, all_of(processed_cols)) %>%
	pivot_longer(-.row, names_to = "series", values_to = "value")

raw_ts <- ggplot(raw_long, aes(x = .row, y = value, color = series)) +
	geom_line(linewidth = 0.6, alpha = 0.8) +
	labs(title = "Raw time series", x = "Row", y = "Value") +
	theme_minimal(base_size = 12) +
	theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "raw_timeseries.png"), raw_ts, width = 7, height = 4)

processed_ts <- ggplot(processed_long, aes(x = .row, y = value, color = series)) +
	geom_line(linewidth = 0.6, alpha = 0.8) +
	labs(title = "Processed time series", x = "Row", y = "Value") +
	theme_minimal(base_size = 12) +
	theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "processed_timeseries.png"), processed_ts, width = 7, height = 4)

raw_hist <- ggplot(raw_long, aes(x = value, fill = series)) +
	geom_histogram(bins = 30, alpha = 0.7) +
	facet_wrap(~ series, scales = "free") +
	labs(title = "Raw distributions", x = "Value", y = "Count") +
	theme_minimal(base_size = 12) +
	theme(legend.position = "none")

ggsave(file.path(fig_dir, "raw_distributions.png"), raw_hist, width = 7, height = 4)

smooth_cols <- processed_cols[grepl("_smooth$", processed_cols)]
dt_cols <- processed_cols[grepl("_dt$", processed_cols)]

if (length(smooth_cols) > 0 && length(dt_cols) > 0) {
	smooth_long <- processed %>%
		select(.row, all_of(smooth_cols)) %>%
		pivot_longer(-.row, names_to = "series", values_to = "value")
	dt_long <- processed %>%
		select(.row, all_of(dt_cols)) %>%
		pivot_longer(-.row, names_to = "series", values_to = "value")

	smooth_plot <- ggplot(smooth_long, aes(x = .row, y = value, color = series)) +
		geom_line(linewidth = 0.6, alpha = 0.8) +
		labs(title = "Smoothed series", x = "Row", y = "Value") +
		theme_minimal(base_size = 12) +
		theme(legend.position = "bottom")

	ggsave(file.path(fig_dir, "processed_smooth.png"), smooth_plot, width = 7, height = 4)

	dt_plot <- ggplot(dt_long, aes(x = .row, y = value, color = series)) +
		geom_line(linewidth = 0.6, alpha = 0.8) +
		labs(title = "Time derivatives", x = "Row", y = "d/dt") +
		theme_minimal(base_size = 12) +
		theme(legend.position = "bottom")

	ggsave(file.path(fig_dir, "processed_derivative.png"), dt_plot, width = 7, height = 4)
}
