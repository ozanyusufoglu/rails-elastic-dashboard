# README

The simplest query you could ask against an Elasticsearch index is "match_all", which will bring you all documents inside an index. 

From the developer toolbox: 

```jsx
GET /kibana_sample_data_flights/_search
{
  "query" : {
    "match_all": {}
    
  }
} 
```

One step further would be to search for documents where a specific field matching a specific value:

```jsx
GET /kibana_sample_data_flights/_search
{
  "query" : {
    "match": {
				"FIELD": "VALUE"
			}
  }
} 
```

There is one thing you should mind about "match" queries. The main difference of ES from a traditional database is that ES designed for searching text. Therefore, when you search for a certain term to match, ES looks for relevancy in the whole database.. TODO

 [https://www.elastic.co/guide/en/elasticsearch/reference/current/query-filter-context.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-filter-context.html)

There is a cheaper way to search in terms of computation:  filtering. When you filter for specific terms, ES doesn't calculate the relevancy score for your query, it filters only the documents fulfilling your query condition completely.  

You might see some documentation or articles showing examples with "filtered", this is a deprecated usage since ES 2.0. From ES 5.0 and on "bool" is the new term to build complex queries. 

```jsx
GET /kibana_sample_data_flights/_search
{
  "query": { 
    "bool": { 
      "filter": [ 
        { "term":  { "language_id": 28  }},
        { "term":  { "some_other_term": "some string value"}},
        { "range": { "created_at_timestamp": { "gt": "2015-01-01" }}} 
      ]
    }
  }
}
```

How would you create the same query with ruby DLS API ? 

```ruby
@filtered = search do
                  query do
                    bool do
                      filter do
                          term DestWeather: "Rain"
                        end
                        filter do
                          term DestCountry: "IT"
                        end
                        filter do
                          range :timestamp do
                            gte 'now-100d'
                        end
                      end
                    end
                  end
                end
```
