class TransactionsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_transactions, only: [:index, :create]

  def index
  end

  private

  def get_transactions
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @transactions = Franchise.find(params[:franchise_id]).transactions
      else
        @transactions = Transaction.all
      end
    else
      @transactions = current_user.franchise.transactions
    end
  end
end
