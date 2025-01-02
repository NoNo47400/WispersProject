from flask import Flask, render_template, request, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3
from functools import wraps
import os
from datetime import timedelta

DATABASE_PATH = "../database.db"  # Chemin de la base de données

app = Flask(__name__)
app.secret_key = os.urandom(24)
app.config['SESSION_TYPE'] = 'filesystem'
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30)

# Database initialization
def init_db():
    conn = sqlite3.connect(DATABASE_PATH)
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
    db = sqlite3.connect(DATABASE_PATH)
    db.row_factory = sqlite3.Row
    return db

# Initialize the database
init_db()

# Remplacer les fonctions de récupération de données
def get_sensor_data(hub_id=None):
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    if hub_id:
        # Récupère les dernières données pour chaque patch d'un hub spécifique
        cursor.execute('''
            SELECT p.patch_id, p.hub_id, sd.data 
            FROM patches p 
            LEFT JOIN (
                SELECT patch_id, hub_id, data 
                FROM sensor_data sd1 
                WHERE timestamp = (
                    SELECT MAX(timestamp) 
                    FROM sensor_data sd2 
                    WHERE sd1.patch_id = sd2.patch_id 
                    AND sd1.hub_id = sd2.hub_id
                )
            ) sd ON p.patch_id = sd.patch_id AND p.hub_id = sd.hub_id
            WHERE p.hub_id = ?
        ''', (hub_id,))
    else:
        # Récupère les dernières données pour tous les patches
        cursor.execute('''
            SELECT p.patch_id, p.hub_id, sd.data 
            FROM patches p 
            LEFT JOIN (
                SELECT patch_id, hub_id, data 
                FROM sensor_data sd1 
                WHERE timestamp = (
                    SELECT MAX(timestamp) 
                    FROM sensor_data sd2 
                    WHERE sd1.patch_id = sd2.patch_id 
                    AND sd1.hub_id = sd2.hub_id
                )
            ) sd ON p.patch_id = sd.patch_id AND p.hub_id = sd.hub_id
        ''')
    
    sensor_data = cursor.fetchall()
    sensors = []
    for patch_id, hub_id, pressure in sensor_data:
        if pressure is not None:  # Ne pas inclure les patches sans données
            sensors.append({
                'id': patch_id,
                'hub_id': hub_id,
                'pressure': pressure
            })
    conn.close()
    return sensors

def get_sensor_history(sensor_id, hub_id):
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        SELECT data, strftime('%Y-%m-%d %H:%M:%S', timestamp) as formatted_time
        FROM sensor_data 
        WHERE patch_id = ? AND hub_id = ?
        ORDER BY timestamp DESC 
        LIMIT 50
    ''', (sensor_id, hub_id))
    data = cursor.fetchall()
    conn.close()

    # Inverser l'ordre pour l'affichage chronologique
    pressure_values = [row[0] for row in data][::-1]
    timestamps = [row[1] for row in data][::-1]

    return {
        'timestamps': timestamps,
        'pressure_values': pressure_values
    }

def get_hubs():
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    cursor.execute('SELECT DISTINCT hub_id FROM hubs ORDER BY hub_id')
    hubs = [row[0] for row in cursor.fetchall()]
    conn.close()
    return hubs

def get_available_sensors():
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    cursor.execute('SELECT DISTINCT patch_id FROM patches ORDER BY patch_id')
    sensors = [row[0] for row in cursor.fetchall()]
    conn.close()
    return sensors

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
    selected_sensor = request.args.get('sensor_id', type=int)
    available_hubs = get_hubs()
    available_sensors = get_available_sensors()
    sensors = get_sensor_data(selected_hub)
    
    return render_template('index.html', 
                         sensors=sensors, 
                         selected_hub=selected_hub,
                         selected_sensor=selected_sensor,
                         available_hubs=available_hubs,
                         available_sensors=available_sensors)

@app.route('/sensor/<int:sensor_id>')
@login_required
def sensor_detail(sensor_id):
    hub_id = request.args.get('hub_id', type=int)
    if hub_id is None:
        flash('Hub ID is required')
        return redirect(url_for('index'))
        
    history = get_sensor_history(sensor_id, hub_id)
    
    # Si la requête est AJAX, renvoyer JSON
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        return {
            'timestamps': history['timestamps'],
            'pressure_values': history['pressure_values']
        }
    
    # Sinon renvoyer la page HTML complète
    return render_template('sensor_detail.html', 
                         sensor_id=sensor_id,
                         hub_id=hub_id,
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
