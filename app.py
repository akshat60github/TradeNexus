from flask import Flask, render_template, jsonify, send_from_directory
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

# Connect to MySQL
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="1234",
    database="project"
)
cursor = db.cursor(dictionary=True)


@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory('static', filename)


@app.route('/')
def home():
    user_id = 2  # Hardcoded for now — change as needed

    # Easy Query 1. Retrieve a User's Watchlist Stocks 
    cursor.execute("""
        SELECT 
            s.company_name,
            s.ticker_symbol,
            w.current_price
        FROM 
            Watchlist w
        JOIN 
            Stock s ON w.stock_id = s.stock_id
        WHERE 
            w.user_id = %s
    """, (user_id,))
    stocks = cursor.fetchall()

    # Easy Query 2. Fetch Pending Orders for a User
    cursor.execute("""
        SELECT 
            o.order_id,
            o.stock_id,
            s.company_name,
            s.ticker_symbol,
            o.price,
            o.quantity,
            o.timestamp,
            o.status
        FROM 
            OrderTable o
        JOIN 
            Stock s ON o.stock_id = s.stock_id
        WHERE 
            o.user_id = %s AND o.status = 'Pending'
    """, (user_id,))
    pending_orders = cursor.fetchall()

    # Adv Query 3: Top 5 Stocks by Volume
    cursor.execute("""
        SELECT 
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
    """)
    top_stocks = cursor.fetchall()

    return render_template('home.html', stocks=stocks, orders=pending_orders, top_stocks=top_stocks)

@app.route('/dashboard')
def dashboard():
    user_id = 2  # Hardcoded for now — change as needed

    # Easy Query 3: Get a User's Portfolio Summary
    cursor.execute("""
        SELECT 
            user_id,
            current_value,
            total_invested
        FROM 
            Portfolio
        WHERE 
            user_id = %s
    """, (user_id,))
    portfolio_summary = cursor.fetchone()

    # Intmd Query 2: Summary of Executed Orders for a User
    cursor.execute("""
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
            o.user_id = %s AND o.status = 'Executed'
        GROUP BY 
            s.ticker_symbol
    """, (user_id,))
    executed_orders = cursor.fetchall()

    # Adv Query 1: User Summary
    cursor.execute("""
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
            Portfolio P ON U.user_id = P.user_id
        WHERE 
            U.user_id = %s
    """, (user_id,))
    user_summary = cursor.fetchone()
    
    # Intmd Query 3: Retrieve User's Trading Activity Summary
    cursor.execute("""
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
            u.user_id = %s
        GROUP BY 
            u.user_id, u.name
    """, (user_id,))
    trading_activity = cursor.fetchone()

    return render_template('dashboard.html', 
                           portfolio=portfolio_summary, 
                           executed_orders=executed_orders, 
                           user_summary=user_summary,
                           trading_activity=trading_activity)
    
# New API endpoint for News Alerts
@app.route('/news')
def get_news():
    # Removed local cursor re-creation; using global `cursor` instead.
    cursor.execute("""
        SELECT N.headline, N.date_posted, S.company_name, S.ticker_symbol
        FROM NewsAlerts N
        JOIN Stock S ON N.stock_id = S.stock_id
        ORDER BY N.date_posted DESC
    """)
    news_db = cursor.fetchall()

    return render_template('news.html', news=news_db)

# New route for Tome page
@app.route('/tome')
def tome():
    return render_template('tome.html')

@app.route('/index')
def index():
    # Adv Query 2: Watchlist data with average executed price
    cursor.execute("""
        SELECT 
            W.watchlist_id,
            S.company_name,
            S.ticker_symbol,
            W.current_price,
            ROUND(
                (SELECT AVG(O.price) 
                 FROM OrderTable O 
                 WHERE O.stock_id = W.stock_id AND O.status = 'Executed'), 2
            ) AS avg_executed_price
        FROM 
            Watchlist W
        JOIN 
            Stock S ON W.stock_id = S.stock_id
        WHERE 
            W.user_id = 2
    """)
    watchlist_with_avg_price = cursor.fetchall()

    # Easy Query 1: Watchlist data without average executed price
    cursor.execute("""
        SELECT 
            s.company_name,
            s.ticker_symbol,
            w.current_price
        FROM 
            Watchlist w
        JOIN 
            Stock s ON w.stock_id = s.stock_id
        WHERE 
            w.user_id = 2
    """)
    basic_watchlist = cursor.fetchall()

    # Easy Query 2: Pending orders
    cursor.execute("""
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
    """)
    pending_orders = cursor.fetchall()

    # Adv Query 4: Users with more than 2 failed transactions in the last month
    cursor.execute("""
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
    """)
    failed_users = cursor.fetchall()

    return render_template('index.html', 
                           watchlist_with_avg_price=watchlist_with_avg_price, 
                           basic_watchlist=basic_watchlist,
                           pending_orders=pending_orders,
                           failed_users=failed_users)

@app.route('/news/watchlist')
def news_watchlist():
    user_id = 1  # Hardcoded for now — change as needed

    # Int Query 1: Retrieve News Alerts for Stocks in a User's Watchlist
    cursor.execute("""
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
            w.user_id = %s
        ORDER BY 
            n.date_posted DESC;
    """, (user_id,))
    news = cursor.fetchall()

    return render_template('news.html', news=news)
    

if __name__ == '__main__':
    app.run(debug=True)