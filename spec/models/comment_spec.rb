require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user_id){ user.id }
  let(:user){ create(:user) }
  let(:article_id){ article.id }
  let(:article){ create(:article) }
  context "bodyを指定してる時" do
    it "コメントが作られる" do
      comment = build(:comment, user_id:user_id, article_id:article_id)
      expect(comment).to be_valid
    end
  end
  context "bodyを指定していない時" do
    it "コメント作成が失敗する" do
      comment = build(:comment, body:nil, user_id:user_id, article_id:article_id)
      expect(comment).to be_invalid
      expect(comment.errors.details[:body][0][:error]).to eq :blank
    end
  end
end
