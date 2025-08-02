# frozen_string_literal: true

module TagSelector
  # Provides season-based system tag(s) for a given date.
  # Seasons follow the meteorological (northern hemisphere) definition.
  class SeasonService
    class << self
      # Returns the season tag based on astronomical season start dates
      # Northern hemisphere dates (fixed):
      # Spring  → 20 Mar, Summer → 21 Jun, Fall → 22 Sep, Winter → 21 Dec
      # Winter spans the end of the year into the following year up to Spring start.
      def tags(date = Date.current)
        date = date.to_date

        year = date.year

        spring_start = Date.new(year, 3, 20)
        summer_start = Date.new(year, 6, 21)
        fall_start   = Date.new(year, 9, 22)
        winter_start = Date.new(year, 12, 21)

        name = if date >= winter_start || date < spring_start
                 "Winter"
        elsif date >= spring_start && date < summer_start
                 "Spring"
        elsif date >= summer_start && date < fall_start
                 "Summer"
        else
                 "Fall"
        end

        [ Tag.find_by(name: name, system: true) ].compact
      end
    end
  end
end
