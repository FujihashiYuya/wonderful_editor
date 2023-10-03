require 'rails_helper'

RSpec.describe ArticleLike, type: :model do
  let(:user_id){ user.id }
  let(:user){ create(:user) }
  let(:article_id){ article.id }
  let(:article){ create(:article) }
  context "bodyを指定してる時" do
    it "いいねできる" do
      article_like = build(:article_like, user_id:user_id, article_id:article_id)
      expect(article_like).to be_valid
    end
  end
end
