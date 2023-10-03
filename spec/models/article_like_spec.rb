# == Schema Information
#
# Table name: article_likes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_article_likes_on_article_id  (article_id)
#  index_article_likes_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe ArticleLike, type: :model do
  let(:user_id) { user.id }
  let(:user) { create(:user) }
  let(:article_id) { article.id }
  let(:article) { create(:article) }
  context "bodyを指定してる時" do
    it "いいねできる" do
      article_like = build(:article_like, user_id: user_id, article_id: article_id)
      expect(article_like).to be_valid
    end
  end
end
