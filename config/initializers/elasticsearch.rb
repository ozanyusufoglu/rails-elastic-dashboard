# frozen_string_literal: true

require 'elasticsearch'
require 'elasticsearch/persistence'
require 'base64'
require 'json'

class LogRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  settings number_of_shards: 1 do
    mapping do
      indexes :text, analyzer: 'english'
    end
  end


end

class Log

  attr_reader :attributes

  def initialize(attributes={}) # pass empty by default
    @attributes = attributes
  end

  def to_hash
    @attributes
  end
end

Elasticlient = Elasticsearch::Client.new(
  url: 'http://localhost:9200',
  retry_on_failure: 5,
  request_timeout: 30,
  adapter: :typhoeus,
  log: Rails.env.development?
)

Repository = LogRepository.new(client: Elasticlient, index_name: :isoolate_lastday, type: :_doc, klass: Log )
