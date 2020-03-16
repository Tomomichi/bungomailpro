class Search::AuthorsController < Search::ApplicationController
  def index
    expires_now

    @results = params[:author_name].present? ? AozoraBook.where("REPLACE(author, ' ', '') LIKE ?", "%#{params[:author_name].delete(' ')}%").pluck(:author_id, :author).to_h : {}
    return redirect_to author_category_books_path(author_id: @results.first[0], category_id: params[:category_id]) if @results.count == 1

    @meta_title = "「#{params[:author_name]}」の検索結果"
    @breadcrumbs << { name: '検索結果' }
  end
end
