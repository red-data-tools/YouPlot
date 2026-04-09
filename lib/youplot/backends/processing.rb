# frozen_string_literal: true

module YouPlot
  # plotting functions.
  module Backends
    module Processing
      module_function

      def count_values(arr, tally: true, reverse: false)
        # tally was added in Ruby 2.7
        result = \
          if tally && Enumerable.method_defined?(:tally)
            arr.tally
          else
            # value_counts Enumerable::Statistics
            arr.value_counts(dropna: false)
          end

        sort_cache = {}

        # sorting
        result = result.sort do |a, b|
          # compare values
          r = b[1] <=> a[1]
          # If the values are the same, compare by name
          r = natural_compare(a[0], b[0], sort_cache) if r.zero?
          r
        end

        # --reverse option
        result.reverse! if reverse

        # prepare for barplot
        result.transpose
      end

      # Natural order comparison for tie-breaking when counts are equal.
      # Fast paths handle text-only and pure numeric labels.
      # Mixed labels still use chunked comparison (e.g. "chr1" vs "chr10").
      def natural_compare(a, b, cache = nil)
        aa = natural_sort_key(a, cache)
        bb = natural_sort_key(b, cache)

        # Fast path: both labels are text-only, so plain string comparison is enough.
        return aa[:string] <=> bb[:string] if aa[:type] == :text && bb[:type] == :text

        # Fast path: both labels are pure numbers, so compare numerically first.
        if aa[:type] == :numeric && bb[:type] == :numeric
          r = aa[:numeric] <=> bb[:numeric]
          return r unless r.zero?

          # Tiebreaker for equivalent numeric values (e.g. "1" and "01")
          return aa[:string] <=> bb[:string]
        end

        # Fallback path: at least one label mixes text and digits.
        ta = ensure_natural_tokens(aa)
        tb = ensure_natural_tokens(bb)
        max = [ta.size, tb.size].max

        0.upto(max - 1) do |i|
          xa = ta[i]
          xb = tb[i]

          return -1 if xa.nil?
          return 1 if xb.nil?

          r = if xa[0] == :num && xb[0] == :num
                compare_integer_strings(xa[1], xb[1])
              else
                xa[1] <=> xb[1]
              end

          return r unless r.zero?
        end

        aa[:string] <=> bb[:string]
      end

      # Classifies a value for natural sorting and caches the result per label.
      def natural_sort_key(value, cache = nil)
        str = value.to_s
        return cache[str] if cache && cache.key?(str)

        key = if str.match?(/\d/)
                numeric = parse_numeric(str)
                if numeric
                  # Pure numeric labels get a dedicated fast path.
                  { type: :numeric, string: str, numeric: numeric }
                else
                  # Mixed labels fall back to chunked natural comparison.
                  { type: :mixed, string: str, tokens: nil }
                end
              else
                # Text-only labels get a dedicated fast path.
                { type: :text, string: str, tokens: nil }
              end

        cache ? cache[str] = key : key
      end

      # Memoizes token pairs for fallback chunked comparison.
      def ensure_natural_tokens(key)
        key[:tokens] ||= natural_tokens(key[:string])
      end

      # Parses a string as a numeric value if it matches pure number format.
      # Returns Float or nil.
      def parse_numeric(str)
        return nil unless str.match?(/\A[+-]?(?:\d+(?:\.\d+)?|\.\d+)\z/)

        str.to_f
      end

      # Splits a string into [type, token] pairs for natural comparison.
      # Type is :num for digit-only chunks, :text for anything else.
      # E.g. "chr10" => [[:text, "chr"], [:num, "10"]]
      def natural_tokens(str)
        str.scan(/\d+|\D+/).map do |tok|
          kind = tok.match?(/\A\d+\z/) ? :num : :text
          [kind, tok]
        end
      end

      # Compares two numeric strings, handling leading zeros.
      # Order: by length (sans leading zeros), then numeric value, then original.
      def compare_integer_strings(a, b)
        aa = a.sub(/\A0+/, '')
        bb = b.sub(/\A0+/, '')
        aa = '0' if aa.empty?
        bb = '0' if bb.empty?

        r = aa.length <=> bb.length
        return r unless r.zero?

        r = aa <=> bb
        return r unless r.zero?

        a <=> b
      end
    end
  end
end
