from flask import Flask, render_template, request, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3
from functools import wraps
import os
from datetime import timedelta

app = Flask(__name__)
app.secret_key = os.urandom(24)
app.config['SESSION_TYPE'] = 'filesystem'
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30)

# Database initialization
def init_db():
    conn = sqlite3.connect('database.db')
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

def get_db():
    db = sqlite3.connect('database.db')
    db.row_factory = sqlite3.Row
    return db

# Initialize the database
init_db()

# Remplacer les fonctions de récupération de données
def get_sensor_data(hub_id=None):
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    
    if hub_id:
        cursor.execute('SELECT patch_id, data FROM sensor_data WHERE hub_id = ?', (hub_id,))
    else:
        cursor.execute('SELECT patch_id, data FROM sensor_data')
    
    sensor_data = cursor.fetchall()
    sensors = []
    for patch_id, pressure in sensor_data:
        sensors.append({
            'id': patch_id,
            'pressure': pressure
        })
    conn.close()
    return sensors

def get_sensor_history(sensor_id):
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT data, timestamp 
        FROM sensor_data 
        WHERE patch_id = ? 
        ORDER BY timestamp DESC 
        LIMIT 50''', (sensor_id,))
    data = cursor.fetchall()
    conn.close()

    return {
        'timestamps': [row[1] for row in data],
        'pressure_values': [row[0] for row in data]
    }

def get_hubs():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('SELECT DISTINCT hub_id FROM sensor_data')
    hubs = [row[0] for row in cursor.fetchall()]
    conn.close()
    return hubs

# Login decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'logged_in' not in session:
            flash('Please log in first.')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
@login_required
def index():
    selected_hub = request.args.get('hub_id', type=int)
    available_hubs = get_hubs()
    sensors = get_sensor_data(selected_hub)
    return render_template('index.html', 
                         sensors=sensors, 
                         selected_hub=selected_hub,
                         available_hubs=available_hubs)

@app.route('/sensor/<int:sensor_id>')
@login_required
def sensor_detail(sensor_id):
    history = get_sensor_history(sensor_id)
    return render_template('sensor_detail.html', 
                         sensor_id=sensor_id,
                         timestamps=history['timestamps'],
                         pressure_values=history['pressure_values'])

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        if not username or not password:
            flash('Username and password are required')
            return redirect(url_for('register'))
        
        db = get_db()
        try:
            # Check if user exists
            cursor = db.execute('SELECT username FROM users WHERE username = ?', (username,))
            if cursor.fetchone() is not None:
                flash('Username already exists')
                return redirect(url_for('register'))
            
            # Create new user
            hashed_password = generate_password_hash(password)
            db.execute('INSERT INTO users (username, password) VALUES (?, ?)',
                      (username, hashed_password))
            db.commit()
            flash('Registration successful! Please log in.')
            return redirect(url_for('login'))
        except sqlite3.Error as e:
            flash(f'Error: {str(e)}')
        finally:
            db.close()
            
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        if not username or not password:
            flash('Username and password are required')
            return redirect(url_for('login'))
        
        db = get_db()
        try:
            user = db.execute('SELECT * FROM users WHERE username = ?', (username,)).fetchone()
            
            if user and check_password_hash(user['password'], password):
                session['logged_in'] = True
                session['username'] = username
                flash('Logged in successfully!')
                return redirect(url_for('index'))
            else:
                flash('Invalid username or password')
        except sqlite3.Error as e:
            flash(f'Error: {str(e)}')
        finally:
            db.close()
            
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.')
    return redirect(url_for('login'))

if __name__ == '__main__':
    print("=== Starting Flask Application ===")
    print("Debug mode is ON")
    print("Visit http://localhost:5000 in your browser")
    app.run(debug=True, host='0.0.0.0', port=5000)
