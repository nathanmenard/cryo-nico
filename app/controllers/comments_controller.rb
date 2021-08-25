class CommentsController < ApplicationController
  before_action :authenticate_admin
  before_action :find_comment, only: [:update, :destroy]

  def create
    client = Client.find params[:client_id]
    @comment = client.comments.new comment_params
    @comment.user = current_user
    if @comment.save
      redirect_to @comment.client
    end
  end

  def update
    @comment.update comment_params
    redirect_to @comment.client
  end

  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_comment
    if current_user.superuser
      @comment = Comment.find params[:id]
    else
      @comment = current_user.franchise.comments.find(params[:id])
    end
  end
end
