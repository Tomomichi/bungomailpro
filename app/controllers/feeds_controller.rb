class FeedsController < ApplicationController
  def show
    @feed = Feed.find(params[:id])
    @campaign = @feed.campaign
    @word_count = @feed.content.gsub(" ", "").length

    @meta_title = "#{@campaign.author_and_book_name}(#{@feed.index}/#{@campaign.count}"
    @breadcrumbs = [ {text: @campaign.author_and_book_name, link: campaign_path(@campaign)}, {text: @feed.index} ]
    @no_index = true
  end
end
