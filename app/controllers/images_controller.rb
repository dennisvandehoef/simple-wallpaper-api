class ImagesController < ApplicationController
  before_action :set_image, only: [ :show, :edit, :update, :destroy ]

  # GET /images
  def index
    @images = Image.order(created_at: :desc)
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # POST /images
  def create
    @image = Image.new(image_params)

    if @image.save
      if params[:image][:file].present?
        @image.file.attach(params[:image][:file])
      end

      redirect_to images_path, notice: "Image uploaded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /images/:id
  def show; end

  # GET /images/:id/edit
  def edit; end

  # PATCH/PUT /images/:id
  def update
    if @image.update(image_params)
      if params[:image][:file].present?
        @image.file.purge if @image.file.attached?
        @image.file.attach(params[:image][:file])
      end

      redirect_to @image, notice: "Image was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /images/:id
  def destroy
    @image.destroy
    redirect_to images_path, notice: "Image was successfully deleted."
  end

  # GET /random_image
  def random
    # Build active tags grouped by their tag_group_id (seasons & holidays)
    grouped_active = {}
    season_and_holiday_tags = TagSelector::SeasonService.tags + TagSelector::HolidayService.tags

    # Ensure holiday group is present even if no active holiday tags (to exclude out-of-season holiday images).
    holiday_group = TagGroup.find_by(name: "Holidays")
    grouped_active[holiday_group.id] ||= [] if holiday_group

    season_and_holiday_tags.each do |tag|
      (grouped_active[tag.tag_group_id] ||= []) << tag.id
    end

    # Fetch current weather and include its tag(s) if available
    begin
      weather_data = OpenMeteoService.fetch
      weather_code = weather_data.dig("daily", "weather_code", 0)
      weather_tags = ::TagSelector::WeatherService.tags(weather_code)
      weather_tags.each do |tag|
        (grouped_active[tag.tag_group_id] ||= []) << tag.id
      end
    rescue StandardError => e
      Rails.logger.error("Weather tag retrieval failed: #{e.message}")
    end

    # Preload tags to avoid N+1
    images_scope = Image.joins(:file_attachment).includes(:tags)

    # Retrieve a list of candidate images in random order and pick first that satisfies rules
    image = images_scope.order(Arel.sql("RANDOM()")).detect do |img|
      grouped_active.all? do |group_id, active_tag_ids|
        img_tags_in_group = img.tags.select { |t| t.tag_group_id == group_id }

        if img_tags_in_group.empty?
          # Image has no tags for this group – group does not affect eligibility
          true
        else
          # Image has tags in this group; if there are active tags, require overlap, otherwise exclude
          active_tag_ids.present? && img_tags_in_group.any? { |t| active_tag_ids.include?(t.id) }
        end
      end
    end

    unless image&.file&.attached?
      head :not_found and return
    end

    width_param  = params[:width].to_i if params[:width].present?
    height_param = params[:height].to_i if params[:height].present?

    if width_param.present? && width_param > 0 && height_param.present? && height_param > 0
      gravity_option = image.crop_gravity.presence || "Center"

      variant = image.file.variant(resize_to_fill: [ width_param, height_param, { gravity: gravity_option } ]).processed
      redirect_to url_for(variant), allow_other_host: true
    else
      redirect_to url_for(image.file), allow_other_host: true
    end
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:crop_gravity, tag_ids: [])
  end
end
