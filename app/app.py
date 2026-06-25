from flask import Flask
import = Flask(__name__)import pymysql

DB_HOST = os.getenv("DB_HOST")

@app.route("/")
def home():
    try:
        conn = pymysql.connect(
            host=DB_HOST,
            user="admin",
            password="Pavan@12345",
            database="mydb"
        )

        cursor = conn.cursor()
        cursor.execute("CREATE TABLE IF NOT EXISTS users (name VARCHAR(50));")
        cursor.execute("INSERT INTO users (name) VALUES ('Pavan');")
        conn.commit()

        cursor.execute("SELECT * FROM users;")
        data = cursor.fetchall()

        users = [row[0] for row in data]

        return f"""
        <h2>✅ ECS App Running</h2>
        <h3>✅ Connected to Aurora DB</h3>
        Users:<br>{'<br>'.join(users)}
        """

    except Exception as e:
        return str(e)

app.run(host="0.0.0.0", port=80)
import os

