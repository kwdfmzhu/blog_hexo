.PHONY: generate server

generate:
	hexo generate

server: generate
	hexo server
