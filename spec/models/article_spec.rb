# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_title    (title) UNIQUE
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  let(:user_id) { user.id }
  let(:user) { create(:user) }
  context "titleを指定してる時" do
    it "記事が作られる" do
      article = build(:article, user_id: user_id)
      expect(article).to be_valid
    end
  end

  context "titleを指定していない時" do
    it "記事作成が失敗する" do
      article = build(:article, title: nil, user_id: user_id)
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "titleが重複している場合" do
    before { create(:article, title: "foo", user_id: user_id) }

    it "記事作成が失敗する" do
      article = build(:article, title: "foo", user_id: user_id)
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :taken
    end
  end
end
