.PHONY: up down restart logs clean up-proxy down-proxy

up:
	@docker compose up -d

down:
	@docker compose down

restart:
	@docker compose restart

logs:
	@docker compose logs -f

clean:
	@docker compose down -v

up-proxy:
	@docker compose -f docker-compose.yml -f docker-compose.proxy.yml up -d

down-proxy:
	@docker compose -f docker-compose.yml -f docker-compose.proxy.yml down
