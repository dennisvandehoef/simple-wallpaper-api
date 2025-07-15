# frozen_string_literal: true

module TagSelector
  # Provides season-based system tag(s) for a given date.
  # Seasons follow the meteorological (northern hemisphere) definition.
  class SeasonService
    class << self
      def tags(date = Date.current)
        date = date.to_date

        name = case date.month
        when 12, 1, 2
                 "Winter"
        when 3, 4, 5
                 "Spring"
        when 6, 7, 8
                 "Summer"
        else
                 "Fall"
        end

        [ Tag.find_by(name: name, system: true) ].compact
      end
    end
  end
end
