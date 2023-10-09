# Load environment variables from .env file
include .env
export

# Elasticsearch Migration by EWZ Tribe's
#
# Usage:
#   - To start Elasticsearch migration:       make migrate
#   - To start reindexing:                    make reindex
#   - To kill a specific migration process:   make kill INDEX_DEST=<your_index_dest>
#   - To kill all migration processes:        make kill-all
#
# Makefile targets:
#   - migrate: Initiates Elasticsearch data migration for specified indices.
#   - delete-index: Delete the destination Elasticsearch index.
#   - kill: Terminates a specific migration process based on INDEX_DEST.
#   - kill-all: Terminates all migration processes.

.PHONY: migrate migrate-index reindex kill kill-all

TIMESTAMP = $(shell date +'%Y-%m-%d_%H%M%S')
LOG_FOLDER = logs

# Start Elasticsearch migration for all specified indices
migrate:
	mkdir -p $(LOG_FOLDER)
	for index_pair in $(INDEX_MAP); do \
		source_index=$$(echo $$index_pair | cut -d ':' -f 1); \
		dest_index=$$(echo $$index_pair | cut -d ':' -f 2); \
  		mkdir -p $(LOG_FOLDER)/$$dest_index; \
		LOG_FILE=$(LOG_FOLDER)/$$dest_index/output-$(TIMESTAMP).log; \
		PID_FILE=$(LOG_FOLDER)/$$dest_index/nohup.pid; \
		$(MAKE) delete-index INDEX_DEST=$$dest_index; \
		$(MAKE) migrate-index INDEX_SOURCE=$$source_index INDEX_DEST=$$dest_index LOG_FILE=$$LOG_FILE PID_FILE=$$PID_FILE; \
	done

# Start Elasticsearch migration for a single index
migrate-index:
	nohup sh -c 'elasticdump --input=$(SOURCE_HOST)/$(INDEX_SOURCE) --output=$(DEST_HOST)/$(INDEX_DEST) --type=data > $(LOG_FILE) 2>&1 & echo $$! > $(PID_FILE)' &

# Start Elasticsearch reindexing for all specified indices
reindex:
	mkdir -p $(LOG_FOLDER); \
	mkdir -p $(LOG_FOLDER)/reindex; \
	export PID_FILE=$(LOG_FOLDER)/reindex/nohup.pid; \
	export LOG_FILE=$(LOG_FOLDER)/reindex/output-$(TIMESTAMP).log; \
	nohup ./scripts/reindex.sh $(DEST_HOST) "$(REINDEX_INDICES)" > $$LOG_FILE 2>&1 & echo $$! > $$PID_FILE

# Delete the destination Elasticsearch index
delete-index:
	curl -XDELETE "$(DEST_HOST)/$(INDEX_DEST)"

# Kill a specific migration process based on INDEX_DEST
kill:
	if [ -z "$(INDEX_DEST)" ]; then \
		echo "Please specify INDEX_DEST: make kill INDEX_DEST=your_index_dest"; \
	else \
		PID_FILE=$(LOG_FOLDER)/$(INDEX_DEST)/nohup.pid; \
		if [ -f $$PID_FILE ]; then \
			echo "Killing process for $(INDEX_DEST)"; \
			kill -9 $$(cat $$PID_FILE); \
			rm -f $$PID_FILE; \
		else \
			echo "No PID file found for $(INDEX_DEST)"; \
		fi; \
	fi

# Kill all migration processes
kill-all:
	for index_pair in $(INDEX_MAP); do \
		dest_index=$$(echo $$index_pair | cut -d ':' -f 2); \
		PID_FILE=$(LOG_FOLDER)/$$dest_index/nohup.pid; \
		if [ -f $$PID_FILE ]; then \
			echo "Killing process for $$dest_index"; \
			kill -9 $$(cat $$PID_FILE); \
			rm -f $$PID_FILE; \
		fi; \
	done
