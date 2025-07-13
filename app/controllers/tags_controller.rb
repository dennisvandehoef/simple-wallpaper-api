class TagsController < ApplicationController
  before_action :set_tag_group
  before_action :set_tag, only: %i[edit update destroy]
  before_action :ensure_editable, only: %i[edit update destroy]

  # GET /tag_groups/:tag_group_id/tags/new
  def new
    @tag = @tag_group.tags.new
  end

  # POST /tag_groups/:tag_group_id/tags
  def create
    @tag = @tag_group.tags.new(tag_params)
    if @tag.save
      redirect_to @tag_group, notice: "Tag was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tag_groups/:tag_group_id/tags/:id/edit
  def edit; end

  # PATCH/PUT /tag_groups/:tag_group_id/tags/:id
  def update
    if @tag.update(tag_params)
      redirect_to @tag_group, notice: "Tag was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tag_groups/:tag_group_id/tags/:id
  def destroy
    @tag.destroy
    redirect_to @tag_group, notice: "Tag was successfully deleted."
  end

  def ensure_editable
    if @tag.system?
      redirect_to @tag_group, alert: "System tags cannot be modified." and return
    end
  end

  private

  def set_tag_group
    @tag_group = TagGroup.find(params[:tag_group_id])
  end

  def set_tag
    @tag = @tag_group.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
