# Create database script for Bettys books

# Create the database
CREATE DATABASE IF NOT EXISTS bettys_books;
USE bettys_books;

# Create the tables
CREATE TABLE IF NOT EXISTS books (id INT AUTO_INCREMENT,name VARCHAR(50),price DECIMAL(5, 2) unsigned,PRIMARY KEY(id));

CREATE TABLE IF NOT EXISTS users(
	ID VARCHAR(36) DEFAULT (uuid()),
    UserName varchar(225) NOT NULL,
	LastName varchar(255) NOT NULL,
    FirstName varchar(255) NOT NULL,
    Email varchar(255) NOT NULL,
    Password BINARY(60) NOT NULL,
    PRIMARY KEY (ID)
)

# Create the app user
CREATE USER IF NOT EXISTS 'bettys_books_app'@'localhost' IDENTIFIED BY 'qwertyuiop';

# Grant privileges to the app user
GRANT ALL PRIVILEGES ON bettys_books.* TO 'bettys_books_app'@'localhost';

# Flush privileges to ensure the changes take effect
FLUSH PRIVILEGES;



# adding test data

INSERT INTO books (name, price)VALUES('Brighton Rock', 20.25),('Brave New World', 25.00), ('Animal Farm', 12.99) ;