#!/bin/bash

ES_HOST="$1"
INDICES="$2"
IFS=" " read -ra INDEX_PAIRS <<< "$INDICES"

delete_index() {
  local index_name="$1"
  echo "Deleting index: $index_name"
  curl -X DELETE "$ES_HOST/$index_name"
  echo ""
}

create_index() {
  local index_name="$1"
  echo "Creating index: $index_name"
  curl -X PUT "$ES_HOST/$index_name" -H "Content-Type: application/json" -d '{
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 1
    }
  }'
  echo ""
}

reindex_index() {
  local source_index="$1"
  local dest_index="$2"
  echo "Reindexing from: $source_index to: $dest_index"
  curl -X POST "$ES_HOST/_reindex" -H "Content-Type: application/json" -d '{
    "source": {
      "index": "'$source_index'"
    },
    "dest": {
      "index": "'$dest_index'"
    }
  }'
  echo ""
}

for index_pair in "${INDEX_PAIRS[@]}"; do
  source_index="${index_pair%%:*}"
  dest_index="${index_pair#*:}"
  echo "--------------------"
  echo "Starting reindex for $source_index to $dest_index"

  delete_index "$dest_index"
  create_index "$dest_index"
  reindex_index "$source_index" "$dest_index"

  echo "Reindexing completed for $source_index to $dest_index"
  echo "--------------------"
done
