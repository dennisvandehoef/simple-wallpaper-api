# frozen_string_literal: true

module TagSelector
  # Provides holiday-based system tags for a given date.
  class HolidayService
    class << self
      def tags(date = Date.current)
        date = date.to_date
        [].tap do |ary|
          ary << christmas_tag(date)
          ary << easter_tag(date)
          ary << valentine_tag(date)
          ary << new_year_tag(date)
        end.compact
      end

      private

      def christmas_tag(date)
        christmas = Date.new(date.month == 1 ? date.year - 1 : date.year, 12, 25)
        window_start = christmas - 21 # 3 weeks before
        window_end   = christmas + 10 # 10 days after
        return unless date.between?(window_start, window_end)
        Tag.find_by(name: "Christmas", system: true)
      end

      def easter_tag(date)
        easter = easter_sunday(date.year)
        window_start = easter - 7  # 1 week before
        window_end   = easter + 1  # 1 day after
        return unless date.between?(window_start, window_end)
        Tag.find_by(name: "Easter", system: true)
      end

      def valentine_tag(date)
        return unless date.month == 2 && date.day == 14
        Tag.find_by(name: "Valentine's Day", system: true)
      end

      def new_year_tag(date)
        return unless (date.month == 12 && date.day == 31) || (date.month == 1 && date.day == 1)
        Tag.find_by(name: "New Year's Eve", system: true)
      end

      # Meeus/Jones/Butcher algorithm
      def easter_sunday(year)
        a = year % 19
        b = year / 100
        c = year % 100
        d = b / 4
        e = b % 4
        f = (b + 8) / 25
        g = (b - f + 1) / 3
        h = (19 * a + b - d - g + 15) % 30
        i = c / 4
        k = c % 4
        l = (32 + 2 * e + 2 * i - h - k) % 7
        m = (a + 11 * h + 22 * l) / 451
        month = (h + l - 7 * m + 114) / 31
        day   = ((h + l - 7 * m + 114) % 31) + 1
        Date.new(year, month, day)
      end
    end
  end
end
