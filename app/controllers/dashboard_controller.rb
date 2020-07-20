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

    # elasticlient.indices.put_mapping(index:"isoolate_lastday", body: mappings)

    # configure the repository by pssing the client instance, index name and klass (doesn't work yet)

    @repository = LogRepository.new(client: elasticlient, index_name: :isoolate_lastday, type: :_doc, klass: Log)

    # below are aggreagation queries
    ## aggregate response based on term counts,
    ## first hash is to filter before aggreagating, e.g { type : 'phishing'}, leave empty to mathch all

    top_hostnames = aggregate_by_term({}, 'message_host')
    top_categories = aggregate_by_term({}, 'message_category_name')

    # dashboard aggregation queries:
    top_10_isolated_categories = aggregate_by_term({ message_isolated: 'true' }, 'message_category_name')
    top_10_allowed_categories = aggregate_by_term({ message_blocked: 'false' }, 'message_category_name')
    top_10_phishing_hostnames = aggregate_by_term({ type: 'phishing' }, 'message_host')

    @top_10_blocked_hostnames = aggregate_by_term({message_blocked:'true'}, 'message_host')
    top_10_browsed = aggregate_by_term({}, 'message_host')

      top_10_blocked_categories = aggregate_by_term({ message_blocked: 'true' }, 'message_category_name')
    top_10_isolated_allowed_hostnames = aggregate_by_term({ message_blocked: 'false' }, 'message_category_name')

    match_all = match_all({})

    @all = @repository.search(match_all)
    @isolated = match_by_term({ message_isolated: 'true' })
    @date_histogram = aggregate_by_date({ message_isolated: 'true' }, 'minute')

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
    @chart_4 = bucket_data(@top_10_blocked_hostnames)
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

  def match_by_term(match_term)
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

      aggregation :my_aggregation do
        terms do
          field agg_term
        end
      end
    end
  end

  def aggregate_by_date(match_term, interval)
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

      aggregation :count_over_time do
        date_histogram do
          field 'timestamp'
          interval 'minutes'
        end
      end
    end
  end

  def bucket_data(query)
    buckets = @repository.search(query).response.aggregations.my_aggregation.buckets
    buckets.map { |bucket| [bucket['key'], bucket['doc_count']] }
  end
end
