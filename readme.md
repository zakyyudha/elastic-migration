# Elasticsearch Migration

This Makefile provides automation for migrating data from one Elasticsearch index to another using the `elasticdump` tool. It allows you to define source and destination index mappings and manage the migration process easily.

## Prerequisites

Before using this Makefile, ensure you have the following prerequisites installed:

- [elasticdump](https://www.npmjs.com/package/elasticdump)

## Configuration

1. Create a `.env` file in the same directory as the Makefile with the following format:

```env
# Define mappings of source and destination indices
## <INDEX_SOURCE>:<INDEX_DEST>
## Example:
## tds_customer_complex_telkom_product:es-ewz-tds-customer_complex_telkom_product
INDEX_MAP=\
    index1:dest_index1 \
    index2:dest_index2 \
    index3:dest_index3

# Define reindex of source and destination indices
## <INDEX_SOURCE>:<INDEX_DEST>
## Example:
## es-ewz-tds-catalog_classification:cs-ewz-tds-catalog_classification
REINDEX_INDICES=\
    index1:dest_index1 \
    index2:dest_index2 \
    index3:dest_index3

# Specify the source and destination Elasticsearch hosts
SOURCE_HOST=http://production.es.com:9200
DEST_HOST=http://staging.es.com:9200
```

   Modify the `INDEX_MAP`, `SOURCE_HOST`, and `DEST_HOST` variables according to your specific Elasticsearch setup.

## Usage

- To start Elasticsearch migration for all specified indices:

    ```bash
    make migrate
    ```

- To start Elasticsearch migration for a single index (not recommended for typical use):

    ```bash
    make migrate-index INDEX_SOURCE=<source_index> INDEX_DEST=<dest_index>
    ```

- To kill a specific migration process based on the destination index:

    ```bash
    make kill INDEX_DEST=<your_index_dest>
    ```

- To terminate all migration processes:

    ```bash
    make kill-all
    ```
