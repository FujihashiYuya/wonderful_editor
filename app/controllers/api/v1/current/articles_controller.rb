class Api::V1::Current::ArticlesController < Api::V1::BaseApiController
  before_action :authenticate_api_v1_user!, only: [:index]
  before_action :current_api_v1_user, only: [:index]
  def index
    articles = current_api_v1_user.articles.where(status: 1).order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end
end
