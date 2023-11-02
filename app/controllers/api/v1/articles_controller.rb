module Api::V1
  class ArticlesController < BaseApiController
    before_action :authenticate_api_v1_user!, except: [:index, :show]
    before_action :current_api_v1_user, except: [:index, :show]

    def index
      articles = Article.where(status: 1).order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.find(params[:id])
      render json: article, serializer: Api::V1::ArticleDetailSerializer
    end

    def create
      article = current_api_v1_user.articles.new(article_params)
      article.save!
      render json: article, serializer: Api::V1::ArticleDetailSerializer
    end

    def update
      article = current_api_v1_user.articles.find(params[:id])
      article.update!(article_params)
      render json: article, serializer: Api::V1::ArticleDetailSerializer
    end

    def destroy
      article = current_api_v1_user.articles.find(params[:id])
      article.destroy!
    end

    private

      def article_params
        params.require(:article).permit(:title, :body, :status)
      end
  end
end
