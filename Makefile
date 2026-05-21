.PHONY: test docs check-docs

test:
	bash scripts/test.sh

docs:
	python3 tools/generate_docs.py

check-docs:
	python3 tools/generate_docs.py --check
