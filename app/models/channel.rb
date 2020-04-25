class Channel < ApplicationRecord
  belongs_to :user
  belongs_to :search_condition, optional: true
  has_many :book_assignments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  validates :title, presence: true

  after_create do
    self.subscriptions.create(user_id: self.user_id)
  end

  def assign_book_and_set_feeds(deliver_now: false)
    # ストック済みの本があればそれを配信
    if (book_assignment = book_assignments.stocked.order(:created_at).first)
      book_assignment.active!
    elsif search_condition
      # 検索条件が保存されてる場合はそこからセレクト
      book_class = search_condition.book_type.constantize
      # TODO: あらかじめbook_idsを保存しておいてクエリ実行せずに選べるようにする
      # TODO: 該当する本がないときのフォールバック処理
      book = book_class.search(search_condition.query).order(Arel.sql("RANDOM()")).first
      book_assignment = self.book_assignments.create(book_type: book.class.name, book_id: book.id, status: :active)
    else
      # それもなければデフォルト条件でセレクト
      book = self.select_book
      book_assignment = self.book_assignments.create(book_type: book.class.name, book_id: book.id, status: :active)
    end
    book_assignment.set_feeds

    # TODO: UTCの配信時間以前なら予約・以降ならすぐに配信される
    UserMailer.feed_email(book_assignment.next_feed).deliver if deliver_now
  end

  def current_book_assignment
    self.book_assignments.includes(:book, :feeds).find_by(status: :active)
  end

  def select_book
    ids = ActiveRecord::Base.connection.select_values("select guten_book_id from guten_books_subjects where subject_id IN (select id from subjects where LOWER(id) LIKE '%fiction%')")
    GutenBook.where(id: ids, language: 'en', rights_reserved: false, words_count: 2000..15000).where("downloads > ?", 50).order(Arel.sql("RANDOM()")).first
  end
end
