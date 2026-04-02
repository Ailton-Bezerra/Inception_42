.PHONY: up down build clean dirs help

RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
NC = \033[0m # No Color

DIRS = srcs secrets

dirs:
	@echo "$(YELLOW)Criando pastas necessárias...$(NC)"
	@mkdir -p $(DIRS)
	@echo "$(GREEN)✓ Pastas criadas com sucesso$(NC)"

up: dirs
	@echo "$(YELLOW)Criando diretórios de volumes...$(NC)"
	@mkdir -p /home/ailton/data/mariadb /home/ailton/data/wordpress
	@echo "$(YELLOW)Iniciando docker compose...$(NC)"
	@cd srcs && docker compose up -d
	@echo "$(GREEN)✓ Docker compose iniciado com sucesso$(NC)"

down:
	@echo "$(YELLOW)Parando docker compose...$(NC)"
	@cd srcs && docker compose down
	@echo "$(GREEN)✓ Docker compose parado$(NC)"

build: dirs
	@echo "$(YELLOW)Reconstruindo imagens e iniciando...$(NC)"
	@cd srcs && docker compose up -d --build
	@echo "$(GREEN)✓ Build e inicialização completos$(NC)"

clean:
	@echo "$(RED)Limpando containers, volumes e imagens...$(NC)"
	@cd srcs && docker compose down -v --rmi all
	@echo "$(GREEN)✓ Limpeza completa$(NC)"

logs:
	@cd srcs && docker compose logs -f

status:
	@cd srcs && docker compose ps -a

shell:
	@cd srcs && docker compose exec -it wordpress /bin/sh

help:
	@echo "$(GREEN)Disponível targets:$(NC)"
	@echo "  $(YELLOW)make up$(NC)      - Cria pastas e inicia o docker compose"
	@echo "  $(YELLOW)make down$(NC)    - Para os containers"
	@echo "  $(YELLOW)make build$(NC)   - Reconstrói imagens e inicia"
	@echo "  $(YELLOW)make clean$(NC)   - Remove containers, volumes e imagens"
	@echo "  $(YELLOW)make dirs$(NC)    - Cria apenas as pastas necessárias"
	@echo "  $(YELLOW)make logs$(NC)    - Mostra logs dos containers"
	@echo "  $(YELLOW)make status$(NC)  - Mostra status dos containers"
	@echo "  $(YELLOW)make shell$(NC)   - Abre shell no container wordpress"
	@echo "  $(YELLOW)make help$(NC)    - Mostra esta mensagem"
