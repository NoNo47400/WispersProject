from flask import Flask, render_template, request, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3
from functools import wraps
import os
from datetime import timedelta
import pandas as pd

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

def get_sensor_data(sensor_id=None):
    df = pd.read_csv('data/sensors.csv')
    if sensor_id:
        df = df[df['sensor_id'] == sensor_id]
    latest_data = df.groupby('sensor_id').last().reset_index()
    
    sensors = []
    for _, row in latest_data.iterrows():
        sensors.append({
            'id': row['sensor_id'],
            'pressure_value': row['pressure_value'],
            'temperature': row['temperature'],
            'blood_flow': row['blood_flow'],
            'oxygen_level': row['oxygen_level'],
            'brain_activity': row['brain_activity']
        })
    return sensors

def get_sensor_history(sensor_id):
    df = pd.read_csv('data/sensors.csv')
    sensor_data = df[df['sensor_id'] == sensor_id].sort_values('timestamp')
    return {
        'timestamps': sensor_data['timestamp'].tolist(),
        'pressure_values': sensor_data['pressure_value'].tolist(),
        'temperature_values': sensor_data['temperature'].tolist(),
        'blood_flow_values': sensor_data['blood_flow'].tolist(),
        'oxygen_values': sensor_data['oxygen_level'].tolist(),
        'brain_activity_values': sensor_data['brain_activity'].tolist()
    }

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
    sensor_id = request.args.get('sensor_id')
    sensors = get_sensor_data(sensor_id)
    df = pd.read_csv('data/sensors.csv')
    available_sensors = sorted(df['sensor_id'].unique())
    return render_template('index.html', sensors=sensors, available_sensors=available_sensors, selected_sensor=sensor_id)

@app.route('/sensor/<sensor_id>')
@login_required
def sensor_detail(sensor_id):
    df = pd.read_csv('data/sensors.csv')
    available_sensors = sorted(df['sensor_id'].unique())
    if sensor_id not in available_sensors:
        return redirect(url_for('index'))
        
    history_data = get_sensor_history(sensor_id)
    return render_template('sensor_detail.html', 
                         sensor_id=sensor_id,
                         available_sensors=available_sensors,
                         selected_sensor=sensor_id,
                         **history_data)

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
