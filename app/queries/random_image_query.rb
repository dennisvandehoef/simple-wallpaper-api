class RandomImageQuery
  GROUP_NAMES = [
    "Holidays",
    "Weather Conditions",
    "Seasons",
    "Daytime",
    "Temperature"
  ].freeze

  SELECTOR_SERVICES = [
    TagSelector::SeasonService,
    TagSelector::HolidayService,
    TagSelector::DaytimeService,
    TagSelector::TemperatureService,
    TagSelector::WeatherService
  ].freeze

  # Returns a single Image record that matches the current active tag context
  # or nil when no eligible image is found.
  def self.call
    new.call
  end

  def call
    images_scope = Image.joins(:file_attachment).includes(:tags)
    grouped_active = build_grouped_active_tags

    cache_key = "random_image_query:last_image_ids"
    last_ids  = Rails.cache.fetch(cache_key) { [] }

    selected = images_scope.order(Arel.sql("RANDOM()")).detect do |img|
      eligible?(img, grouped_active) && !last_ids.include?(img.id)
    end

    # Fallback: if all eligible images have been returned recently (e.g., fewer than 4 images), allow repeat
    selected ||= images_scope.order(Arel.sql("RANDOM()")).detect { |img| eligible?(img, grouped_active) }

    if selected
      last_ids << selected.id
      last_ids = last_ids.last(3) # remember at most 3 ids
      Rails.cache.write(cache_key, last_ids)
    end

    selected
  end

  private

  def build_grouped_active_tags
    grouped_active = Hash.new { |h, k| h[k] = [] }

    # Ensure the groups exist, even if no active tag is returned for them
    TagGroup.where(name: GROUP_NAMES).find_each { |tg| grouped_active[tg.id] }

    # Collect active tags from each selector service
    SELECTOR_SERVICES.each do |svc|
      svc.tags.each { |tag| grouped_active[tag.tag_group_id] << tag.id }
    end

    grouped_active
  end

  def eligible?(image, grouped_active)
    grouped_active.all? do |group_id, active_tag_ids|
      image_tags_in_group = image.tags.select { |t| t.tag_group_id == group_id }

      if image_tags_in_group.empty?
        # Image has no tags for this group – group does not affect eligibility
        true
      else
        # Image has tags in this group; if there are active tags, require overlap
        active_tag_ids.present? && image_tags_in_group.any? { |t| active_tag_ids.include?(t.id) }
      end
    end
  end
end
