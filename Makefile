build:
	zola build

clean:
	rm -rf public

publish:
	./scripts/publish.sh

author:
	./scripts/author.sh $(title)

.PHONY: build clean publish author
