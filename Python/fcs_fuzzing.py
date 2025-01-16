# fcs_fuzzing.py

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

# Fonction de fuzzing avec vérification
def fuzz_fcs(nibble_data):
    """
    Effectue du fuzzing sur nibble_data en changeant un seul bit à la fois,
    et vérifie que le FCS calculé n'est jamais égal au FCS original.

    :param nibble_data: Liste d'octets (nibbles) d'entrée.
    """
    original_fcs = calculate_fcs(nibble_data)
    print(f"FCS original : 0x{original_fcs:x}")
    print("Résultats du fuzzing avec un seul bit changé :")

    for i in range(len(nibble_data)):
        for bit in range(4):  # Les nibbles ont 4 bits
            # Flip un bit à la position `bit`
            modified_nibble = nibble_data[i] ^ (1 << bit)
            # Créer une copie modifiée du tableau
            modified_data = nibble_data[:]
            modified_data[i] = modified_nibble
            # Calculer le FCS avec la donnée modifiée
            fuzzed_fcs = calculate_fcs(modified_data)
            
            # Vérifier si le nouveau FCS est égal au FCS original
            if fuzzed_fcs == original_fcs:
                print(f"!!!  Conflit : Modification sur l'élément {i}, bit {bit}: FCS = 0x{fuzzed_fcs:x} (égal au FCS original)")
            #else:
                #print(f"Modification sur l'élément {i}, bit {bit}: FCS = 0x{fuzzed_fcs:x}")

# Fonction principale
def main():
    # Données initiales
    nibble_data = [0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8]
    
    # Effectuer du fuzzing
    fuzz_fcs(nibble_data)

# Point d'entrée du script
if __name__ == "__main__":
    main()
