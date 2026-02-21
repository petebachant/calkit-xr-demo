#!/usr/bin/env julia

using CSV
using DataFrames
using Statistics

const DEFAULT_INPUT = "data/raw.csv"
const DEFAULT_OUTPUT = "data/processed.csv"
const DEFAULT_WINDOW = 5

function detect_time_column(df::DataFrame)
	for name in names(df)
		lower = lowercase(String(name))
		if lower in ("time", "t", "timestamp")
			return name
		end
	end
	return nothing
end

function moving_average(x::Vector{T}, window::Int) where {T<:Real}
	n = length(x)
	half = max(0, window ÷ 2)
	out = similar(x, Float64)
	for i in 1:n
		lo = max(1, i - half)
		hi = min(n, i + half)
		out[i] = mean(x[lo:hi])
	end
	return out
end

function time_derivative(x::Vector{T}, t::Vector{T}) where {T<:Real}
	n = length(x)
	out = similar(x, Float64)
	if n == 1
		out[1] = 0.0
		return out
	end

	# Forward/backward at edges, central in the middle.
	out[1] = (x[2] - x[1]) / (t[2] - t[1])
	for i in 2:(n - 1)
		out[i] = (x[i + 1] - x[i - 1]) / (t[i + 1] - t[i - 1])
	end
	out[n] = (x[n] - x[n - 1]) / (t[n] - t[n - 1])
	return out
end

function process(input_path::String, output_path::String; window::Int = DEFAULT_WINDOW)
	df = CSV.read(input_path, DataFrame)
	df = dropmissing(df)

	time_col = detect_time_column(df)
	if time_col !== nothing && eltype(df[!, time_col]) <: Real
		sort!(df, time_col)
		t = Float64.(df[!, time_col])
	else
		# Fall back to row index as time.
		t = collect(1.0:1.0:nrow(df))
	end

	numeric_cols = [name for name in names(df) if eltype(df[!, name]) <: Real]

	for name in numeric_cols
		x = Float64.(df[!, name])
		df[!, Symbol(name, "_smooth")] = moving_average(x, window)
		df[!, Symbol(name, "_dt")] = time_derivative(x, t)
	end

	CSV.write(output_path, df)
end

function main(args)
	input_path = length(args) >= 1 ? args[1] : DEFAULT_INPUT
	output_path = length(args) >= 2 ? args[2] : DEFAULT_OUTPUT
	process(input_path, output_path)
end

if abspath(PROGRAM_FILE) == @__FILE__
	main(ARGS)
end
