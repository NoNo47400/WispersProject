# ssh orangepi@172.20.10.2
import os
import datetime
import paho.mqtt.client as mqtt

# Chemin du répertoire où enregistrer les fichiers
data_dir = "../Data/"

# Vérifie si le répertoire existe, sinon le crée
os.makedirs(data_dir, exist_ok=True)

# Génère le nom du fichier basé sur la date actuelle
file_name = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S") + ".txt"
file_path = os.path.join(data_dir, file_name)

# Callback pour gérer les messages reçus
def on_message(client, userdata, msg):
    message = msg.payload.decode('utf-8')  # Décodage du message
    print(f"Message reçu sur le topic {msg.topic}: {message}")
    # Écriture du message dans le fichier
    with open(file_path, "a") as file:
        file.write(message + "\n")

# Initialisation du client MQTT
client = mqtt.Client()

# Configuration du callback pour les messages
client.on_message = on_message

# Connexion au broker MQTT
broker_ip = "172.20.10.2"
broker_port = 1234
client.connect(broker_ip, broker_ip)

# Souscription au topic "test"
client.subscribe("test")

print(f"Écoute des messages sur le topic 'test'... Les données seront enregistrées dans {file_path}")

# Boucle principale pour écouter les messages
try:
    client.loop_forever()
except KeyboardInterrupt:
    print("\nArrêt du client MQTT.")
    client.disconnect()