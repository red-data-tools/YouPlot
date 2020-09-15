module Uplot
  class Command
    Params = Struct.new(
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
end
