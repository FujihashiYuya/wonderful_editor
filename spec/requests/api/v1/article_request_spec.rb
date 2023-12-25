require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    # rubocop:disable all
    let!(:article1) { create(:article, status: 1, updated_at: 7.days.ago) }
    let!(:article2) { create(:article, status: 1, updated_at: 13.days.ago) }
    let!(:article3) { create(:article, status: 1) }
    let!(:article4) { create(:article, status: 0, updated_at: 3.days.ago) }
    # rubocop:enable all
    it "記事の一覧が取得できる" do
      subject
      res = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(res.length).to eq 3
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email", "password"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    let(:article_id) { article.id }
    let(:article) { create(:article, status: 1) }
    # rubocop:disable RSpec/ExampleLength
    context "指定したidの記事が存在する時" do
      it "記事のレコードが取得できる" do
    # rubocop:enable RSpec/ExampleLength
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["status"]).to eq article.status
        # expect(res["updated_at"]).to eq article.updated_at
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email", "password"]
      end
    end

    context "指定したidの記事が存在しない時" do
      let(:article_id) { 10000 }
      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:res) { JSON.parse(response.body) }
    let(:current_user) { create(:user) }
    # before{allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user)}
    let(:headers) { current_user.create_new_auth_token } # 認証トークンを作成
    context "適切なパラメータを送信した時" do
      let(:params) do
        { article: attributes_for(:article) }
      end
      it "記事のレコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq params[:article][:status]
        expect(response).to have_http_status(:ok)
      end
    end

    context "ステータスが公開で送信した場合" do
      let(:params) do
        { article: attributes_for(:article, status: "published") }
      end
      it "記事のレコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq params[:article][:status]
        expect(response).to have_http_status(:ok)
      end
    end

    context "ステータスが下書きで送信した場合" do
      let(:params) do
        { article: attributes_for(:article, status: "draft") }
      end
      it "記事のレコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq params[:article][:status]
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なパラメータを送信した時" do
      let(:params) { attributes_for(:article) }
      it "記事のレコードが作成できない" do
        expect { subject }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article_id), params: params, headers: headers) }

    let(:params) do
      { article: attributes_for(:article, status: "published") }
    end
    let(:current_user) { create(:user) }
    # before{allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user)}
    let(:headers) { current_user.create_new_auth_token } # 認証トークンを作成
    let(:article_id) { article.id }
    context "自分が所持している記事のレコードを更新しようとするとき" do
      let(:article) { create(:article, status: "draft", user: current_user) }
      it "記事を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status])
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分ではない記事のレコードを更新しようとするとき" do
      let(:other_user) { create(:user) }
      let(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article_id)) }

    let(:current_user) { create(:user) }
    let(:article_id) { article.id }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_api_v1_user).and_return(current_user) }

    context "自分の記事を削除しようとするとき" do
      let!(:article) { create(:article, user: current_user) }
      it "任意のユーザーの記事を削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
      end
    end

    context "他人が所持している記事のレコードを削除しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "記事を削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
