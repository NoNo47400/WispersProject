import paho.mqtt.client as mqtt
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

# Fonction de traitement des messages MQTT
def on_message(client, userdata, msg):
    topic = msg.topic
    payload = msg.payload.decode("utf-8")
    print(f"Received message on topic '{topic}': {payload}")

    # Si le message provient du topic 'data', on sauvegarde les données
    if topic == DATA_TOPIC:
        save_data_to_file(payload)
    
    # Si le message provient du topic 'get_addresses', on renvoie les adresses
    elif topic == GET_ADDRESSES_TOPIC:
        send_addresses(client)

# Fonction pour envoyer les adresses sur le topic 'addresses'
def send_addresses(client):
    addresses = load_addresses()
    addresses_payload = ";".join(addresses)  # Joindre les adresses avec un ';'
    client.publish(ADDRESSES_TOPIC, addresses_payload)
    print(f"Sent addresses: {addresses_payload}")

# Initialisation du client MQTT
client = mqtt.Client()

# Définir les fonctions de rappel
client.on_message = on_message

# Connexion au broker MQTT
client.connect(BROKER, PORT, 60)

# Charger les adresses à surveiller
addresses = load_addresses()

# S'abonner aux topics 'data' et 'get_addresses'
client.subscribe(DATA_TOPIC)
client.subscribe(GET_ADDRESSES_TOPIC)

# Boucle principale pour recevoir des messages MQTT
try:
    print("Starting MQTT client loop...")
    client.loop_start()

    # Attendre que les messages arrivent et les traiter
    while True:
        time.sleep(1)  # Mettre en pause pour éviter d'utiliser trop de CPU

except KeyboardInterrupt:
    print("Exiting...")
    client.loop_stop()  # Arrêter la boucle client MQTT proprement
    client.disconnect()  # Déconnexion propre du broker