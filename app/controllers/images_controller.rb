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

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(tag_ids: [])
  end
end
