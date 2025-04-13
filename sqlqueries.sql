-------------- SQL QUERIES WRITTEN FOR PROJECT ------------
-------- Easy Queries --------
-- 1. Retrieve a User's Watchlist Stocks
SELECT 
    s.company_name,
    s.ticker_symbol,
    w.current_price
FROM 
    Watchlist w
JOIN 
    Stock s ON w.stock_id = s.stock_id
WHERE 
    w.user_id = 1;

-- 2. Fetch Pending Orders for a User
SELECT 
    order_id,
    stock_id,
    price,
    quantity,
    timestamp,
    status
FROM 
    OrderTable
WHERE 
    user_id = 1
  AND 
    status = 'Pending';

-- 3. Get a User's Portfolio Summary
SELECT 
    user_id,
    current_value,
    total_invested
FROM 
    Portfolio
WHERE 
    user_id = 1;SELECT 
    user_id,
    current_value,
    total_invested
FROM 
    Portfolio
WHERE 
    user_id = 1;

-------- Intermediate Queries --------
-- 1. Retrieve News Alerts for Stocks in a User's Watchlist
SELECT 
    s.company_name,
    n.headline,
    n.date_posted
FROM 
    NewsAlerts n
JOIN 
    Stock s ON n.stock_id = s.stock_id
JOIN 
    Watchlist w ON s.stock_id = w.stock_id
WHERE 
    w.user_id = 1
ORDER BY 
    n.date_posted DESC;

-- 2. Summary of Executed Orders for a User
SELECT 
    s.ticker_symbol,
    SUM(o.quantity) AS total_quantity,
    AVG(o.price) AS average_price,
    COUNT(o.order_id) AS number_of_orders
FROM 
    OrderTable o
JOIN 
    Stock s ON o.stock_id = s.stock_id
WHERE 
    o.user_id = 2
  AND 
    o.status = 'Executed'
GROUP BY 
    s.ticker_symbol;

-- 3. Retrieve User's Trading Activity Summary
SELECT
    u.user_id,
    u.name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Executed' THEN 1 ELSE 0 END) AS executed_orders,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(CASE WHEN t.status = 'Success' THEN 1 ELSE 0 END) AS successful_transactions
FROM 
    User u
LEFT JOIN 
    OrderTable o ON u.user_id = o.user_id
LEFT JOIN 
    Transaction t ON u.user_id = t.user_id
WHERE 
    u.user_id = 1
GROUP BY 
    u.user_id, u.name;

-------- Advanced Queries --------
-- Query 1:
SELECT 
    U.user_id,
    U.name,
    U.email,
    U.balance,
    P.current_value,
    P.total_invested,
    ROUND(((P.current_value - P.total_invested) / P.total_invested) * 100, 2) AS gain_loss_percentage
FROM 
    User U
JOIN 
    Portfolio P ON U.user_id = P.user_id;

-- 2. Query 2:
SELECT 
    W.watchlist_id,
    U.name AS user_name,
    S.ticker_symbol,
    ROUND(
        (SELECT AVG(O.price) 
         FROM OrderTable O 
         WHERE O.stock_id = W.stock_id AND O.status = 'Executed'), 2
    ) AS avg_executed_price
FROM 
    Watchlist W
JOIN 
    User U ON W.user_id = U.user_id
JOIN 
    Stock S ON W.stock_id = S.stock_id;

-- 3. Query 3:
SELECT 
    S.stock_id,
    S.company_name,
    S.ticker_symbol,
    S.volume,
    N.headline,
    N.date_posted
FROM 
    Stock S
LEFT JOIN 
    (
        SELECT 
            N1.stock_id, 
            N1.headline, 
            N1.date_posted
        FROM 
            NewsAlerts N1
        INNER JOIN 
            (
                SELECT 
                    stock_id, 
                    MAX(date_posted) AS latest_date
                FROM 
                    NewsAlerts
                GROUP BY 
                    stock_id
            ) N2 ON N1.stock_id = N2.stock_id 
                AND N1.date_posted = N2.latest_date
    ) N ON S.stock_id = N.stock_id
ORDER BY 
    S.volume DESC
LIMIT 5;

-- 4. Query 4:
SELECT 
    U.user_id,
    U.name,
    U.email,
    COUNT(T.transaction_id) AS failed_count
FROM 
    User U
JOIN 
    Transaction T ON U.user_id = T.user_id
WHERE 
    T.status = 'Failed'
    AND T.date >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 MONTH)
GROUP BY 
    U.user_id, U.name, U.email
HAVING 
    COUNT(T.transaction_id) > 2;