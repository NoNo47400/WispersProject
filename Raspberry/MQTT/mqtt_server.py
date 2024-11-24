import paho.mqtt.client as mqtt
import threading
import queue
import time
from datetime import datetime

# Paramètres de configuration
BROKER = "172.20.10.2"
PORT = 1234
DATA_TOPIC = "data"  # Topic où les données sont publiées
GET_ADDRESSES_TOPIC = "get_addresses"  # Topic pour les demandes d'adresses
ADDRESSES_TOPIC = "addresses"  # Topic pour envoyer les adresses
ADDRESS_FILE = "../addresses.txt"  # Fichier contenant les adresses
DATA_DIR = "../Data"  # Dossier où les fichiers seront sauvegardés

# Files d'attente pour la communication entre threads
data_queue = queue.Queue()
addresses_queue = queue.Queue()

# Fonction pour charger les adresses depuis le fichier
def load_addresses():
    with open(ADDRESS_FILE, "r") as file:
        addresses = [line.strip() for line in file.readlines()]
    return addresses

# Fonction pour enregistrer les données dans un fichier texte
def save_data_to_file(data):
    # Créer un nom de fichier basé sur la date et l'heure actuelles
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    filename = f"{DATA_DIR}/{timestamp}.txt"

    with open(filename, "a") as file:
        file.write(data + "\n")
    print(f"Data saved to {filename}")

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
            save_data_to_file(msg)
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
