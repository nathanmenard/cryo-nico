class ReviewsController < ApplicationController
  before_action :authenticate_admin, except: [:new, :create]
  before_action :get_reviews, only: [:index, :update]
  before_action :find_review, only: [:update]

  def index
  end

  def new
    @reservation = current_franchise.reservations.find_by_private_key(params[:key])
    render layout: false
  end

  def create
    reservation = current_franchise.reservations.find_by_private_key(params[:key])
    review_params = {
      product_id: reservation.product_price.product_id,
      client_id: reservation.client_id,
      company_client_id: reservation.company_client_id,
      body: params[:body]
    }
    review = Review.new(review_params)
    if review.save
      @success = true
    else
      @success = false
    end
    render :new, layout: false
  end

  def update
    if @review.update(review_params)
      redirect_to reviews_path
    else
      render :index, review: @review
    end
  end

  private

  def review_params
    params.require(:review).permit(:published, :homepage)
  end

  def get_reviews
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @reviews = Franchise.find(params[:franchise_id]).reviews
      else
        @reviews = Review.all
      end
    else
      @reviews = current_user.franchise.reviews
    end
    @reviews = @reviews.order(id: :desc)
  end

  def find_review
    if current_user.superuser
      @review = Review.find params[:id]
    else
      @review = current_user.franchise.reviews.find(params[:id])
    end
  end
end
