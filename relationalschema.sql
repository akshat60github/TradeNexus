create database if not exists project; 
show databases;
use project;

CREATE TABLE User (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    balance DECIMAL(10,2) CHECK (balance >= 0)
);

CREATE TABLE Stock (
    stock_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    ticker_symbol VARCHAR(10) UNIQUE NOT NULL,
    market_cap DECIMAL(15,2),
    price DECIMAL(10,2) CHECK (price >= 0),
    volume INT CHECK (volume >= 0)
);

CREATE TABLE Portfolio (
    portfolio_id INT PRIMARY KEY,
    user_id INT,
    current_value DECIMAL(15,2),
    total_invested DECIMAL(15,2),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE Watchlist (
    watchlist_id INT PRIMARY KEY,
    user_id INT,
    stock_id INT,
    current_price DECIMAL(10,2),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES Stock(stock_id) ON DELETE CASCADE
);

CREATE TABLE OrderTable (
    order_id INT PRIMARY KEY,
    user_id INT,
    stock_id INT,
    price DECIMAL(10,2) CHECK (price >= 0),
    quantity INT CHECK (quantity > 0),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Executed', 'Cancelled'),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES Stock(stock_id) ON DELETE CASCADE
);

CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(15,2),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Success', 'Failed', 'Pending'),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE Exchange (
    exchange_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    market_hours VARCHAR(50),
    currency VARCHAR(10),
    country VARCHAR(50)
);

CREATE TABLE NewsAlerts (
    news_id INT PRIMARY KEY,
    stock_id INT,
    headline TEXT NOT NULL,
    date_posted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stock_id) REFERENCES Stock(stock_id) ON DELETE CASCADE
);

show tables;

INSERT INTO User (user_id, name, email, balance) VALUES
(1, 'John Doe', 'john@example.com', 10000.00),
(2, 'Jane Smith', 'jane@example.com', 15000.50),
(3, 'Alice Johnson', 'alice@example.com', 20000.75),
(4, 'Bob Brown', 'bob@example.com', 18000.00),
(5, 'Charlie White', 'charlie@example.com', 22000.25),
(6, 'David Black', 'david@example.com', 25000.50),
(7, 'Emma Wilson', 'emma@example.com', 13000.75),
(8, 'Frank Harris', 'frank@example.com', 27000.00),
(9, 'Grace Miller', 'grace@example.com', 19000.25),
(10, 'Henry Clark', 'henry@example.com', 21000.75);

select * from stock; 

INSERT INTO Stock (stock_id, company_name, ticker_symbol, market_cap, price, volume) VALUES
(1, 'Tesla Inc', 'TSLA', 800000000, 900.50, 5000),
(2, 'Apple Inc', 'AAPL', 2500000000, 145.75, 10000),
(3, 'Amazon', 'AMZN', 1500000000, 3200.30, 7000),
(4, 'Google', 'GOOGL', 1800000000, 2800.60, 6500),
(5, 'Microsoft', 'MSFT', 2300000000, 305.20, 8000),
(6, 'Facebook', 'META', 900000000, 250.75, 4000),
(7, 'Netflix', 'NFLX', 500000000, 550.40, 3000),
(8, 'NVIDIA', 'NVDA', 1200000000, 725.30, 6000),
(9, 'AMD', 'AMD', 800000000, 130.20, 4500),
(10, 'Intel', 'INTC', 700000000, 40.75, 7000);

INSERT INTO Portfolio (portfolio_id, user_id, current_value, total_invested) VALUES
(1, 1, 5000, 6000),
(2, 2, 12000, 10000),
(3, 3, 8000, 7000),
(4, 4, 10000, 9500),
(5, 5, 15000, 14000),
(6, 6, 18000, 17500),
(7, 7, 9000, 8800),
(8, 8, 20000, 19000),
(9, 9, 11000, 10500),
(10, 10, 13000, 12500);

INSERT INTO Watchlist (watchlist_id, user_id, stock_id, current_price) VALUES
(1, 1, 1, 900.50),
(2, 2, 2, 145.75),
(3, 3, 3, 3200.30),
(4, 4, 4, 2800.60),
(5, 5, 5, 305.20),
(6, 6, 6, 250.75),
(7, 7, 7, 550.40),
(8, 8, 8, 725.30),
(9, 9, 9, 130.20),
(10, 10, 10, 40.75);

INSERT INTO OrderTable (order_id, user_id, stock_id, price, quantity, status) VALUES
(1, 1, 1, 900.50, 10, 'Pending'),
(2, 2, 2, 145.75, 5, 'Executed'),
(3, 3, 3, 3200.30, 2, 'Cancelled'),
(4, 4, 4, 2800.60, 4, 'Pending'),
(5, 5, 5, 305.20, 8, 'Executed'),
(6, 6, 6, 250.75, 6, 'Pending'),
(7, 7, 7, 550.40, 3, 'Executed'),
(8, 8, 8, 725.30, 7, 'Cancelled'),
(9, 9, 9, 130.20, 5, 'Pending'),
(10, 10, 10, 40.75, 9, 'Executed');

INSERT INTO Transaction (transaction_id, user_id, amount, date, status) VALUES 
(1, 1, 100.00, '2025-03-05 10:00:00', 'Failed'),
(2, 1, 200.00, '2025-03-10 11:00:00', 'Failed'),
(3, 1, 150.00, '2025-03-15 09:00:00', 'Failed'),
(4, 1, 500.00, '2025-03-12 10:00:00', 'Success');

INSERT INTO Transaction (transaction_id, user_id, amount, date, status) VALUES 
(5, 2, 100.00, '2025-03-08 12:00:00', 'Failed'),
(6, 2, 250.00, '2025-03-18 13:00:00', 'Success');

INSERT INTO Transaction (transaction_id, user_id, amount, date, status) VALUES 
(7, 3, 300.00, '2025-03-03 08:00:00', 'Failed'),
(8, 3, 400.00, '2025-03-07 08:30:00', 'Failed'),
(9, 3, 350.00, '2025-03-12 09:30:00', 'Failed'),
(10, 3, 450.00, '2025-03-20 10:30:00', 'Failed'),
(11, 3, 500.00, '2025-03-22 10:30:00', 'Success');

INSERT INTO Transaction (transaction_id, user_id, amount, date, status) VALUES 
(15, 2, 100.00, '2025-04-11 12:00:00', 'Failed'),
(12, 2, 100.00, '2025-01-08 12:00:00', 'Failed'),
(13, 2, 100.00, '2025-04-08 12:00:00', 'Failed');

drop table transaction;

INSERT INTO Exchange (exchange_id, name, market_hours, currency, country) VALUES
(1, 'NASDAQ', '9AM-4PM', 'USD', 'USA'),
(2, 'NYSE', '9:30AM-4PM', 'USD', 'USA'),
(3, 'LSE', '8AM-4:30PM', 'GBP', 'UK'),
(4, 'JPX', '9AM-3PM', 'JPY', 'Japan'),
(5, 'HKEX', '9:30AM-4PM', 'HKD', 'Hong Kong'),
(6, 'SSE', '9:30AM-3PM', 'CNY', 'China'),
(7, 'Euronext', '9AM-5:30PM', 'EUR', 'Europe'),
(8, 'BSE', '9AM-3:30PM', 'INR', 'India'),
(9, 'TSX', '9:30AM-4PM', 'CAD', 'Canada'),
(10, 'ASX', '10AM-4PM', 'AUD', 'Australia');

INSERT INTO NewsAlerts (news_id, stock_id, headline) VALUES
(1, 1, 'Tesla stock rises 10% after strong earnings'),
(2, 2, 'Apple launches new iPhone model'),
(3, 3, 'Amazon announces expansion into cloud services'),
(4, 4, 'Google unveils AI-powered search improvements'),
(5, 5, 'Microsoft partners with OpenAI for new projects'),
(6, 6, 'Meta announces major rebranding effort'),
(7, 7, 'Netflix secures exclusive streaming rights to blockbuster movie'),
(8, 8, 'NVIDIAâ€™s new GPU outperforms previous generation'),
(9, 9, 'AMD announces major chip breakthrough'),
(10, 10, 'Intel to invest $20B in new semiconductor plant');