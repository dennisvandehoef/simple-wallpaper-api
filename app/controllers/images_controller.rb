class ImagesController < ApplicationController
  before_action :set_image, only: [ :show, :destroy ]

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
    params.require(:image).permit()
  end
end
