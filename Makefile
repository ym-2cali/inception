
all :
	@mkdir -p /home/yael-maa/data/mariadb
	@mkdir -p /home/yael-maa/data/wordpress
	@docker compose -f ./srcs/docker-compose.yml up --build

clean:
	@docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	@docker system prune -af --volumes
	@rm -rf /home/yael-maa/data/mariadb/* /home/yael-maa/data/wordpress/*

re: fclean all
