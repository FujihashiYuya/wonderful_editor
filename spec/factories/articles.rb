# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :integer          default("draft")
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
FactoryBot.define do
  status_randam = ["draft", "published"]
  factory :article do
    title { Faker::Book.title }
    body { Faker::Lorem.sentence }
    status { status_randam[Faker::Number.between(from: 0, to: 1)] }
    user
  end
end
