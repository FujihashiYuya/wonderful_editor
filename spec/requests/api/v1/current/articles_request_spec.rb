require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token } # 認証トークンを作成
  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    # rubocop:disable all
    let!(:article1) { create(:article, status: 1, updated_at: 7.days.ago, user: current_user) }
    let!(:article2) { create(:article, status: 1, updated_at: 13.days.ago, user: current_user) }
    let!(:article3) { create(:article, status: 1, user: current_user) }
    let!(:article4) { create(:article, status: 0, updated_at: 3.days.ago, user: current_user) } # rubocop/disable all
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
end
