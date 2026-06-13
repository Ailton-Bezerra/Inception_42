.PHONY: up down build fclean logs status shell server help

RED    = \033[0;31m
GREEN  = \033[0;32m
YELLOW = \033[0;33m
NC     = \033[0m

COMPOSE = cd srcs && docker compose

up:
	@echo "$(YELLOW)Starting Docker Compose...$(NC)"
	@$(COMPOSE) up -d
	@echo "$(GREEN)✓ Containers are up$(NC)"

build:
	@echo "$(YELLOW)Building and starting containers...$(NC)"
	@$(COMPOSE) build --no-cache
	@$(COMPOSE) up -d
	@echo "$(GREEN)✓ Build complete$(NC)"

down:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@$(COMPOSE) down
	@echo "$(GREEN)✓ Containers stopped$(NC)"

fclean:
	@echo "$(RED)Removing everything (containers, volumes, images)...$(NC)"
	@$(COMPOSE) down -v --rmi all
	@echo "$(GREEN)✓ Full cleanup complete$(NC)"

logs:
	@$(COMPOSE) logs -f

status:
	@$(COMPOSE) ps -a

shell:
	@$(COMPOSE) exec wordpress /bin/sh

server:
	@curl -k https://ailbezer.42.fr

help:
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  $(YELLOW)make up$(NC)      - Start containers"
	@echo "  $(YELLOW)make build$(NC)   - Build and start containers"
	@echo "  $(YELLOW)make down$(NC)    - Stop containers"
	@echo "  $(YELLOW)make fclean$(NC)  - Remove containers, volumes, images"
	@echo "  $(YELLOW)make logs$(NC)    - Show logs"
	@echo "  $(YELLOW)make status$(NC)  - Show container status"
	@echo "  $(YELLOW)make shell$(NC)   - Access WordPress container"
	@echo "  $(YELLOW)make server$(NC)  - Check nginx connection"
	@echo "  $(YELLOW)make help$(NC)    - Show this message"
