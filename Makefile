all: commands

## commands: show available commands (*)
commands:
	@grep -h -E '^##' ${MAKEFILE_LIST} \
	| sed -e 's/## //g' \
	| column -t -s ':'

## clean: clean up
clean:
	@find . -path ./.venv -prune -o -type f -name '*~' -exec rm {} +

## check: check HTML
check:
	@mccole check --src . --dst docs

## site: build site
site:
	@mccole build --src . --dst docs
	@touch docs/.nojekyll
	@zip -q -j -r docs/databases.zip db/*.db

## serve: serve documentation
serve:
	python -m http.server -d docs
