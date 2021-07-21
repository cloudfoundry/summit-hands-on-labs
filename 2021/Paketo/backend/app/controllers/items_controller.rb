class ItemsController < ApplicationController
  def index
    render json: Items.all
  end

  def show
    @item = Items.find(params[:id])
    @item ? render(json: @item) : head(:not_found)
  end

  def create
    render json: Items.create(params)
  end

  def update
    render json: Items.update(params)
  end

  def destroy
    Items.remove(params[:id])
    head :no_content
  end
end
