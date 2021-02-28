FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com"}

    trait :without_membership do
      before(:create) { |user| user.class.skip_callback(:create, :after, :create_membership) }
      after(:create) { |user| user.class.set_callback(:create, :after, :create_membership) }
    end

    trait :with_basic_membership do
      without_membership
      after(:create) do |user|
        user.membership = create(:membership, plan: 'basic')
        user.subscriptions.create(channel_id: Channel::OFFICIAL_CHANNEL_ID)
      end
    end
  end
end
