import paho.mqtt.client as mqtt
import threading
import queue
import time
from datetime import datetime
import os
import sqlite3 

# Paramètres de configuration
BROKER = "172.20.10.2"
PORT = 1234
DATA_TOPIC = "data"  # Topic où les données sont publiées
GET_ADDRESSES_TOPIC = "get_addresses"  # Topic pour les demandes d'adresses
ADDRESSES_TOPIC = "addresses"  # Topic pour envoyer les adresses
ADDRESS_FILE = "../addresses.txt"  # Fichier contenant les adresses
DATA_DIR = "../Data"  # Dossier où les fichiers seront sauvegardés
DATABASE_PATH = "../database.db"  # Chemin de la base de données

# Files d'attente pour la communication entre threads
data_queue = queue.Queue()
addresses_queue = queue.Queue()

# Créer le dossier s'il n'existe pas
os.makedirs(DATA_DIR, exist_ok=True)

# Nom du fichier de session pour enregistrer les données
SESSION_FILENAME = f"{DATA_DIR}/data_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.txt"

# Fonction pour initialiser la base de données
def init_db():
    conn = sqlite3.connect(DATABASE_PATH)
    c = conn.cursor()
    c.execute('DROP TABLE IF EXISTS hubs')
    c.execute('DROP TABLE IF EXISTS patches')
    c.execute('DROP TABLE IF EXISTS sensor_data')
    c.execute('''
        CREATE TABLE hubs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hub_id INTEGER UNIQUE NOT NULL
        )
    ''')
    c.execute('''
        CREATE TABLE patches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hub_id INTEGER,
            patch_id INTEGER UNIQUE NOT NULL,
            FOREIGN KEY (hub_id) REFERENCES hubs (hub_id)
        )
    ''')
    c.execute('''
        CREATE TABLE sensor_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            hub_id INTEGER,
            patch_id INTEGER,
            data INTEGER,
            FOREIGN KEY (patch_id) REFERENCES patches (patch_id)
              FOREIGN KEY (hub_id) REFERENCES hubs (hub_id)
        )
    ''')
    conn.commit()
    conn.close()

# Fonction pour vérifier et insérer un hub
def check_and_insert_hub(hub_id):
    conn = sqlite3.connect(DATABASE_PATH)
    c = conn.cursor()
    c.execute('SELECT id FROM hubs WHERE hub_id = ?', (hub_id,))
    hub = c.fetchone()
    if hub is None:
        c.execute('INSERT INTO hubs (hub_id) VALUES (?)', (hub_id,))
        conn.commit()
        hub_id = c.lastrowid
    else:
        hub_id = hub[0]
    conn.close()
    return hub_id

# Fonction pour vérifier et insérer un patch
def check_and_insert_patch(patch_id, hub_id):
    conn = sqlite3.connect(DATABASE_PATH)
    c = conn.cursor()
    c.execute('SELECT id FROM patches WHERE patch_id = ?', (patch_id,))
    patch = c.fetchone()
    if patch is None:
        c.execute('INSERT INTO patches (hub_id, patch_id) VALUES (?, ?)', (hub_id, patch_id))
        conn.commit()
        patch_id = c.lastrowid
    else:
        patch_id = patch[0]
    conn.close()
    return patch_id

# Fonction pour charger les adresses depuis le fichier
# A AJOUTER DANS LA BASE SQL AUSSI
def load_addresses():
    with open(ADDRESS_FILE, "r") as file:
        addresses = [line.strip() for line in file.readlines()]
    return addresses

# Fonction pour enregistrer les données dans un fichier texte
def save_data_to_file(data):
    with open(SESSION_FILENAME, "a") as file:  # Utilise le fichier unique
        file.write(data + "\n")
    print(f"Data appended to {SESSION_FILENAME}")

# Fonction pour enregistrer les données dans la base de données
def save_data_to_db(hub_id, patch_id, data):
    hub_id = check_and_insert_hub(hub_id)
    patch_id = check_and_insert_patch(patch_id, hub_id)
    conn = sqlite3.connect(DATABASE_PATH)
    c = conn.cursor()
    c.execute('INSERT INTO sensor_data (hub_id, patch_id, data) VALUES (?, ?, ?)', (hub_id, patch_id, data))
    conn.commit()
    conn.close()

# Thread pour gérer les messages de type 'get_addresses'
def handle_get_addresses(client):
    while True:
        try:
            # Attendre un message dans la file d'attente
            msg = addresses_queue.get(timeout=1)
            if msg == "process_addresses":
                send_addresses(client)
        except queue.Empty:
            continue

# Thread pour gérer les messages de type 'data'
def handle_data():
    while True:
        try:
            # Attendre un message dans la file d'attente
            msg = data_queue.get(timeout=1)
            hub_id, patch_id, data = map(int, msg.split(';'))
            save_data_to_file(msg)
            save_data_to_db(hub_id, patch_id, data)
        except queue.Empty:
            continue

# Fonction pour envoyer les adresses ligne par ligne sur le topic 'addresses'
def send_addresses(client):
    addresses = load_addresses()
    for address in addresses:
        client.publish(ADDRESSES_TOPIC, address)
        print(f"Sent address: {address}")
        time.sleep(1)  # Pause d'une seconde entre chaque envoi pour éviter de surcharger le broker

# Fonction de traitement des messages MQTT
def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode("utf-8")
    print(f"Received message on topic '{topic}': {payload}")

    # Ajouter les messages dans les files d'attente appropriées
    if topic == DATA_TOPIC:
        data_queue.put(payload)  # Ajouter les données reçues à la file data_queue
    elif topic == GET_ADDRESSES_TOPIC:
        addresses_queue.put("process_addresses")  # Signaler au thread addresses de traiter

# Initialisation du client MQTT
client = mqtt.Client()

# Définir les fonctions de rappel
client.on_message = on_message

# Connexion au broker MQTT
client.connect(BROKER, PORT, 60)

# S'abonner aux topics 'data' et 'get_addresses'
client.subscribe(DATA_TOPIC)
client.subscribe(GET_ADDRESSES_TOPIC)

# Lancer les threads pour les différentes tâches
addresses_thread = threading.Thread(target=handle_get_addresses, args=(client,))
data_thread = threading.Thread(target=handle_data)

addresses_thread.start()
data_thread.start()

# Initialiser la base de données
init_db()

try:
    # Démarrer la boucle MQTT dans le thread principal
    print("Starting MQTT client loop...")
    client.loop_forever()
except KeyboardInterrupt:
    print("Exiting...")
    client.loop_stop()  # Arrêter la boucle client MQTT proprement
    client.disconnect()  # Déconnexion propre du broker
    addresses_thread.join()
    data_thread.join()
