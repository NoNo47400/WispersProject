# fcs_fuzzing2.py

# Table des valeurs pour le calcul
table = [
    0x00, 0x07, 0x0e, 0x09, 0x1c, 0x1b, 0x12, 0x15,
    0x38, 0x3f, 0x36, 0x31, 0x24, 0x23, 0x2a, 0x2d
]

# Fonction pour calculer le FCS
def calculate_fcs(nibble_data):
    """
    Calcule le FCS (Frame Check Sequence) pour un tableau donné.
    
    :param nibble_data: Liste d'octets (nibbles) utilisés pour le calcul.
    :return: Valeur FCS calculée.
    """
    crc = 0
    for nibble in nibble_data:
        index = (crc >> 4) ^ (nibble & 0xf)
        crc = table[index & 0x0f] ^ ((crc << 4) & 0xff)
    return crc & 0xff

# Fonction pour détecter les collisions
def find_collision():
    """
    Teste différentes combinaisons de nibble_data pour trouver une collision FCS.
    L'objectif est de déterminer à partir de combien de nibbles le FCS devient peu fiable.
    """
    print("Recherche d'une collision de FCS avec même taille de données d'entrée...")
    seen_fcs = {}  # Dictionnaire pour stocker les FCS rencontrés
    max_nibbles = 16  # Limite du nombre de nibbles à tester

    for length in range(1, max_nibbles + 1):  # Tester des longueurs croissantes
        print(f"Testing avec {length} nibbles...")
        for i in range(16**length):  # Toutes les combinaisons possibles pour une longueur donnée
            # Générer les données de test
            nibble_data = [(i >> (4 * k)) & 0xf for k in range(length)][::-1]  # Extraire chaque nibble
            
            # Exclure les cas où tous les nibbles valent 0
            #if all(nibble == 0 for nibble in nibble_data):
            #    continue

            fcs = calculate_fcs(nibble_data)

            # Vérifier les collisions uniquement pour la même taille de données d'entrée
            if fcs in seen_fcs:
                first_occurrence = seen_fcs[fcs]
                if len(first_occurrence) == length:
                    print(f"Collision trouvée ! FCS = 0x{fcs:x}")
                    print(f"Première occurrence : {first_occurrence}")
                    print(f"Nouvelle occurrence : {nibble_data}")
                    print(f"Nombre de nibbles nécessaires pour collision : {length}")
                    return
            
            # Ajouter le FCS et sa configuration dans le dictionnaire
            seen_fcs[fcs] = nibble_data

    print("Aucune collision trouvée dans la limite des nibbles testés.")

# Fonction principale
def main():
    # Déterminer la première collision
    find_collision()

# Point d'entrée du script
if __name__ == "__main__":
    main()
