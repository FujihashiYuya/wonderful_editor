require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }  # 認証トークンを作成
  describe "GET /api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let!(:article1) { create(:article, status: 0, updated_at: 7.days.ago, user: current_user) }
    let!(:article2) { create(:article, status: 0, updated_at: 13.days.ago, user: current_user) }
    let!(:article3) { create(:article, status: 0, user: current_user) }
    let!(:article4) { create(:article, status: 1, updated_at: 3.days.ago, user: current_user) }
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

  describe "GET /api/v1/articles/drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    let(:article_id) { article.id }
    let(:article) { create(:article, status: 0, user: current_user) }
    context "指定したidの記事が存在する時" do
      it "記事のレコードが取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["status"]).to eq article.status
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
end
