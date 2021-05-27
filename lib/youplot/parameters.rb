# frozen_string_literal: true

module YouPlot
  # UnicodePlot parameters.
  # * Normally in a Ruby program, you might use hash for the parameter object.
  # * Here, I use Struct for 2 safety reason.
  # * The keys are static in Struct.
  # * Struct does not conflict with keyword arguments. Hash dose.
  Parameters = Struct.new(
    # Sort me!
    :title,
    :width,
    :height,
    :border,
    :margin,
    :padding,
    :color,
    :xlabel,
    :ylabel,
    :labels,
    :symbol,
    :xscale,
    :nbins,
    :closed,
    :canvas,
    :xlim,
    :ylim,
    :grid,
    :name
  ) do
    def to_hc
      to_h.compact
    end
  end
end
