namespace :cron do
  # [月初] Stripe登録状況とSubscriptionを一致させる
  task sync_stripe_subscription: :environment do |_task, _args|
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      # stripeで支払い中のメールアドレス一覧
      emails = User.active_emails_in_stripe

      # 解約した人のstatus更新
      unsubs = User.canceled_in_stripe(emails)
      unsubs.update_all(paid_member: false, updated_at: Time.current)
      p "UnSubscribed users: #{unsubs.map(&:email)}"

      # 契約中の人のstatus更新(新規＋既存両方とも)
      users = User.where(email: emails)
      users.update_all(paid_member: true, updated_at: Time.current)
      p "Subscribing users: #{users.map(&:email)}"

      # 月初時点で有料の人はトライアル体験済みにする
      digests = emails.map{|email| Digest::SHA256.hexdigest(email) }
      EmailDigest.where(digest: digests).update_all(trial_ended: true, updated_at: Time.current)

      # 有料じゃないユーザーのchannel/subscriptionは全部削除
      Channel.by_unpaid_users.where(code: nil).destroy_all
      free_channel_ids = [Channel.find_by(code: 'long-novel')&.id]
      Subscription.by_unpaid_users.where.not(channel_id: free_channel_ids).delete_all

      # 有料ユーザーは全員公式チャネルを購読
      ## TODO: 有料でも公式チャネルの購読on/offしたい
      official_channel_id = Channel.find_by(code: 'bungomail-official').id
      users.each do |user|
        sub = user.subscriptions.find_or_initialize_by(channel_id: official_channel_id)
        next if sub.persisted?
        sub.save!
        p "New subscription: #{user.email}"
      end
    end
  end

  # [Daily?] 決済画面遷移時に作成されるcustomerのうち、決済情報を登録せずに離脱したemailなしcustomerを定期的に削除する
  task clean_stripe_blank_accounts: :environment do |_task, _args|
    has_more = true
    last_id = nil
    emails = []

    # customersの一覧取得
    while has_more do
      list = Stripe::Customer.list({limit: 100, starting_after: last_id})
      last_id = list.data.last&.id
      has_more = list.has_more
      list.data.each do |customer|
        emails << customer.email
        next if customer.email.present?
        Stripe::Customer.delete(customer.id)
        p "Deleted: #{customer.id}, email: #{customer.email}"
      end
    end

    # 重複したemailを表示
    p emails.group_by(&:itself).map{ |k,v| [k, v.count] }.to_h.filter{|k,v| v > 1}.keys
  end
end
