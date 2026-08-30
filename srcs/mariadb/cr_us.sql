CREATE USER IF NOT EXISTS 'yael'@'%' IDENTIFIED BY 'pown';
CREATE DATABASE IF NOT EXISTS mariadb_db; 
GRANT ALL PRIVILEGES ON mariadb_db.* TO 'yael'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'sokoloko';