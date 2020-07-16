# frozen_string_literal: true
require 'hashie'

class DashboardController < ApplicationController
  def index

#  setting the elastic ruby client
    elasticlient = Elasticsearch::Client.new(
      url: 'http://localhost:9200',
      retry_on_failure: 5,
      request_timeout: 30,
      adapter: :typhoeus,
      log: Rails.env.development?
    )

# configure the repository by pssing the client instance, index name and klass (doesn't work yet)

    repository = LogRepository.new(client: elasticlient, index_name: :isoolate_lastday, type: :_doc, klass: Log)

    @logs = self.group_by_category(repository)

    @buckets  = @logs.response.aggregations.by_category.buckets

    @chart_data = @buckets.map { |bucket| [ bucket["key"], bucket["doc_count"]] }

  end



# a custom  query method to search for browser born logs


    def search_browser(repo)
      repo.search('query' => {
                    'match' => {
                      'type' => 'phishing'
                    }
                  })
    end

# a query for all logs
    def search_all(repo)
      repo.search('query' => {
                    'match_all' => {}
                  })
    end


    def group_by_category(repo)
      repo.search('query' => {

                    'match_all' => {}
                  },'aggs' => {
                          'by_category' => {
                                "terms" => {
                                  'field' =>  'message_category_name'
                                }
                                }
                              })
    end

end
