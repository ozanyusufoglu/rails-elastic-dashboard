# frozen_string_literal: true

require 'elasticsearch'
require 'elasticsearch/persistence'
require 'json'
require 'elasticsearch/dsl'


class Log
  attr_reader :attributes
  def initialize(attributes = {}) # pass empty by default
    @attributes = attributes
  end

  def to_hash
    @attributes
  end
end

class Repository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name 'extension__url'
  #document_type '_doc'
  klass Log

  client Elasticsearch::Client.new(
    url: 'http://localhost:9200',
    retry_on_failure: 5,
    request_timeout: 30,
    adapter: :typhoeus,
    log: Rails.env.development?
  )

  settings number_of_shards: 1 do
    mapping do
        # indexes :message.hostname, type: 'keyword'
        # indexes :message.category_name, type: 'keyword'
        # indexes :message.blocked, type: 'boolean'
        # indexes :isolated, type: 'boolean'
        indexes :timestamp, type: 'date'
      end
  end
end

class LogRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name 'my_logs'
# document_type 'log'
  klass Log

  client Elasticsearch::Client.new(
    url: 'http://localhost:9200',
    retry_on_failure: 5,
    request_timeout: 30,
    adapter: :typhoeus,
    log: Rails.env.development?
  )

  settings number_of_shards: 1 do
    mapping do
        # indexes :message_hostname, type: 'keyword'
        # indexes :message_category_name, type: 'keyword'
        # indexes :message_blocked, type: 'boolean'
        # indexes :message_isolated, type: 'boolean'
        # indexes :timestamp, type: 'date'
      end
    end
end

    class SampleRepo
      include Elasticsearch::Persistence::Repository
      include Elasticsearch::Persistence::Repository::DSL

      index_name 'kibana_sample_data_flights'
      document_type '_doc'
      klass Log

      client Elasticsearch::Client.new(
        url: 'http://localhost:9200',
        retry_on_failure: 5,
        request_timeout: 30,
        adapter: :typhoeus,
        log: Rails.env.development?
      )



      settings number_of_shards: 1 do
        mapping do
            # indexes :message_hostname, type: 'keyword'
            # indexes :message_category_name, type: 'keyword'
            # indexes :message_blocked, type: 'boolean'
            # indexes :message_isolated, type: 'boolean'
            # indexes :timestamp, type: 'date'
          end
        end

      end
