class TagGroupsController < ApplicationController
  before_action :set_tag_group, only: %i[ show edit update destroy ]

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
    # Renders show view (default) or redirects if needed
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

  private

  def set_tag_group
    @tag_group = TagGroup.find(params[:id])
  end

  def tag_group_params
    params.require(:tag_group).permit(:name)
  end
end
