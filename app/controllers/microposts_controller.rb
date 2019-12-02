class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i[create destsroy]
  before_action :correct_user, only: %i[destroy]

  def create
    @mictopost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Your post has created"
      redirect_to root_url
    else
      @feed_items = []
      render "static_pages/home"
    end
  end

  def destroy
    @mictopost.destroy
    flash[:success] = "Micropost deleted"
    redirect_back(fallback_location: root_url)
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end

  def correct_name
    @mictopost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url if @mictopost.nil?
  end
end
