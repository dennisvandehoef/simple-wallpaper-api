# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

# Simple wrapper around the Open-Meteo API that caches responses via Rails.cache.
#
# Usage:
#   data = OpenMeteoService.fetch(latitude: 52.52, longitude: 13.41)
#   code = data.dig('daily', 'weather_code', 0)
#
# The default cache TTL is 5 minutes (configurable per call).
class OpenMeteoService
  BASE_URL = "https://api.open-meteo.com/v1/forecast".freeze
  DEFAULT_PARAMS = {
    daily: %w[weather_code temperature_2m_max temperature_2m_min rain_sum showers_sum snowfall_sum].join(","),
    current: "is_day",
    timezone: "Europe/Berlin",
    forecast_days: 1
  }.freeze

  BERLIN_LAT = 52.52
  BERLIN_LON = 13.41

  # Options:
  #   :expires_in – cache ttl (defaults to 5.minutes)
  #   additional params – merged into query string
  def self.fetch(expires_in: 5.minutes, **params)
    cache_key = "open_meteo:#{BERLIN_LAT},#{BERLIN_LON}"

    Rails.cache.fetch(cache_key, expires_in: expires_in) do
      uri = URI(BASE_URL)
      query_params = DEFAULT_PARAMS.merge(latitude: BERLIN_LAT, longitude: BERLIN_LON).merge(params)
      uri.query = URI.encode_www_form(query_params)

      response = Net::HTTP.get_response(uri)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("OpenMeteoService error: #{response.code} #{response.body.tr('\n', ' ')[0, 120]}")
        raise "Open-Meteo API error: #{response.code}"
      end

      JSON.parse(response.body)
    end
  end
end
