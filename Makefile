.PHONY: gitpush clean generate server deploy

generate: clean
	hexo generate

server: generate
	hexo server

deploy: generate
	hexo deploy

clean:
	hexo clean

gitpush: generate
	git add .
	git commit -m 'update'
	git push
