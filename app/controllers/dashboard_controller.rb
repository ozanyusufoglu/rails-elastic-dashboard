# frozen_string_literal: true

require 'hashie'
require 'elasticsearch/dsl'
include Elasticsearch::DSL

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


    # aggregate response based on term counts,
    # first hash is to filter before aggreagating, e.g { type : 'phishing'}
    # leave empty to mathch all

    by_hostname = aggregate_by_term({}, 'message_host')
    by_category = aggregate_by_term({}, 'message_category_name')
    by_category_isolated = aggregate_by_term({message_isolated:'true'}, 'message_category_name')
    by_hostname_isolated = aggregate_by_term({message_isolated:'true'}, 'message_host')
    match_all = match_all({})

    @all = repository.search(match_all).response

    @phishing = repository.search(by_category_isolated).response

    @aggregated_hostnames = repository.search(by_hostname_isolated).response.aggregations.message_host.buckets

    @chart_data = to_chart_data(@aggregated_hostnames)
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
                }, 'aggs' => {
                  'by_category' => {
                    'terms' => {
                      'field' => 'message_category_name'
                    }
                  }
                })
  end

  def group_by_isolated(repo)
    repo.search('query' => {
                  'match' => {
                    'message_isolated' => 'true'
                  }
                }, 'aggs' => {
                  'by_category' => {
                    'terms' => {
                      'field' => 'message_host'
                    }
                  }
                })
  end


  #  below are DSL methods for creating queries, https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl

  def match_all(option)
      search do
        query do
          match_all option
        end
      end
  end

  def match_by_term (match_term)
                  search do
                      query do
                        match match_term
                      end
                    end
                end

  def aggregate_by_term(match_term, agg_term)

        search do
            if match_term == {}
              query do
                match_all {}
              end
            else
              query do
                  match match_term
              end
            end

              aggregation :message_host do
                    terms do
                      field agg_term
                    end
              end
        end
  end


  def to_chart_data(buckets)
    buckets.map { |bucket| [bucket['key'], bucket['doc_count']] }
  end

end
