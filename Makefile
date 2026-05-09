.PHONY: help up down restart logs clean up-proxy down-proxy

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

up: ## Start stack (local mode)
	@docker compose up -d

down: ## Stop stack
	@docker compose down

restart: ## Restart all services
	@docker compose restart

logs: ## Follow logs
	@docker compose logs -f

clean: ## Stop and remove all volumes (**deletes data**)
	@docker compose down -v

up-proxy: ## Start stack behind reverse proxy
	@docker compose -f docker-compose.yml -f docker-compose.proxy.yml up -d

down-proxy: ## Stop proxy stack
	@docker compose -f docker-compose.yml -f docker-compose.proxy.yml down
