# frozen_string_literal: true

require 'hashie'
require 'elasticsearch'
require 'elasticsearch/persistence'
require 'elasticsearch/dsl'

MAPPINGS = JSON.parse(File.read('config/elasticsearch/mappings/logs.json'), symbolize_names: true).freeze

class DashboardController < ApplicationController
  include Elasticsearch::DSL

  def index
    @repo = Repository.new

    @interval = '100d'
    # @repo.client.indices.put_mapping(index:"extension__url", body: MAPPINGS)

    # creating new index and injecting logs in it
    # @new_repo.create_index! force: true
    # @new_repo.save(log)

    # below are aggreagation queries written with ES DSL logic

    # aggregate response based on term counts,
    # first hash is to filter before aggreagating, e.g { type : 'phishing'}, leave empty to mathch all

    # dashboard aggregation queries:
    top_10_isolated_categories = filter_and_agg({ "message.isolated": 'true' }, @interval, 'message.category_name.keyword')
    top_10_allowed_categories = filter_and_agg({ "message.blocked": 'false' }, @interval, 'message.category_name.keyword')
    top_10_phishing_hostnames = filter_and_agg({ type: 'phishing' }, @interval, 'message.host.keyword')

    top_10_blocked_hostnames = filter_and_agg({ "message.blocked": 'true' }, @interval, 'message.host.keyword')
    top_10_browsed = filter_and_agg({}, @interval, 'message.host.keyword')

    top_10_blocked_categories = filter_and_agg({ "message.blocked": 'true' }, @interval, 'message.category_name.keyword')
    top_10_isolated_allowed_hostnames = filter_and_agg({ "message.blocked": 'false' }, @interval, 'message.category_name.keyword')

    @match_all = match_all({})

    # queries for kibana_sample_data_flights

    @last_100d = filter_and_agg({ "message.user_id": '26' }, '100d', 'message.category_name.keyword')

    @filtered = search do
      query do
        bool do
          filter do
            term "message.blocked": 'true'
          end
          filter do
            range :timestamp do
              gte 'now-100d'
            end
          end
        end
      end
    end

    @last = search do
      query do
        bool do
          filter do
            range :timestamp do
              gte 'now-100d'
            end
          end
        end
      end
    end

    # @response = @repository.search(last_120d)

    #  @aggregated_hostnames = repository.search(by_hostname_isolated).response.aggregations.my_aggregation.buckets
    #  @aggregated_categories = repository.search(by_category_isolated).response.aggregations.my_aggregation.buckets
    #  @chart_data = to_chart_data(@aggregated_hostnames)

    # bar chart 1
    @chart_1 = bucket_data(top_10_isolated_categories)
    # bar chart 2
    @chart_2 = bucket_data(top_10_allowed_categories)
    # column chart
    @chart_3 = bucket_data(top_10_phishing_hostnames)
    # pie chart 1
    @chart_4 = bucket_data(top_10_blocked_hostnames)
    # pie chart 2
    @chart_5 = bucket_data(top_10_browsed)

    # bar chart 3
    @chart_6 = bucket_data(top_10_blocked_categories)
  end

  #  below are DSL methods for creating queries, https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl

  def match_all(option)
    search do
      query do
        match_all option
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

      aggregation :my_aggregation do
        terms do
          field agg_term
        end
      end
    end
  end

  def filter_and_agg(filter_term, interval, agg_term)
    search do
      if filter_term == {}
        query do
          match_all {}
        end
      else
        query do
          bool do
            filter do
              term filter_term
            end
            filter do
              range :timestamp do
                gte 'now-' + interval
              end
            end
          end
        end
      end
      aggregation :my_aggregation do
          terms do
            field agg_term
          end
      end
    end
  end


  def bucket_data(query)
    buckets = @repo.search(query).response.aggregations.my_aggregation.buckets
    buckets.map { |bucket| [bucket['key'], bucket['doc_count']] }
  end
end
