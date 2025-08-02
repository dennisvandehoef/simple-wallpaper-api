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

    last_id = Rails.cache.read("random_image_query:last_image_id")

    selected = images_scope.order(Arel.sql("RANDOM()")).detect do |img|
      eligible?(img, grouped_active) && img.id != last_id
    end

    # Fallback: if all eligible images equal last_id (e.g., only one image), allow repeat
    selected ||= images_scope.order(Arel.sql("RANDOM()")).detect { |img| eligible?(img, grouped_active) }

    Rails.cache.write("random_image_query:last_image_id", selected.id) if selected
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
