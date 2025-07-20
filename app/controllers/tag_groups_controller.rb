class TagGroupsController < ApplicationController
  before_action :set_tag_group, only: %i[ show edit update destroy ]
  before_action :ensure_editable, only: %i[ edit update destroy ]

  # GET /tag_groups
  def index
    @tag_groups = TagGroup.order(:name)
  end

  # GET /tag_groups/new
  def new
    @tag_group = TagGroup.new
  end

  # GET /tag_groups/:id/edit
  def edit; end

  # GET /tag_groups/:id
  def show
    # Preload tags together with count of attached images to avoid N+1 queries
    @tags = @tag_group.tags
                         .left_joins(:images)
                         .select("tags.*, COUNT(images.id) AS images_count")
                         .group("tags.id")
                         .order(:name)

    # Count images that do NOT have any tag belonging to this group
    images_with_group_tag_ids = Image.joins(:tags).where(tags: { tag_group_id: @tag_group.id }).select(:id)
    @images_without_group_tag = Image.where.not(id: images_with_group_tag_ids).count
  end

  # POST /tag_groups
  def create
    @tag_group = TagGroup.new(tag_group_params)

    if @tag_group.save
      redirect_to tag_groups_path, notice: "Tag group was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tag_groups/:id
  def update
    if @tag_group.update(tag_group_params)
      redirect_to tag_groups_path, notice: "Tag group was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tag_groups/:id
  def destroy
    @tag_group.destroy
    redirect_to tag_groups_path, notice: "Tag group was successfully deleted."
  end

  def ensure_editable
    redirect_to @tag_group, alert: "System tag groups cannot be modified." if @tag_group.system?
  end

  private

  def set_tag_group
    @tag_group = TagGroup.find(params[:id])
  end

  def tag_group_params
    params.require(:tag_group).permit(:name)
  end
end
