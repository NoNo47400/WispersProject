# fcs.py

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
        print(f"Index : 0x{index:x} CRC : 0x{crc:x}")
    return crc & 0xff

# Fonction principale
def main():
    # Exemple de données
    nibble_data = [0x0, 0x0, 0x5, 0xa, 0xa, 0xc, 0xc, 0xc, 0xc, 0xc, 0xc, 0xc, 0xc, 0x1, 0x2, 0x3, 0x4]
    
    # Appel de la fonction calculate_fcs
    fcs = calculate_fcs(nibble_data)
    
    # Affichage du résultat
    print(f"Le FCS calculé est : 0x{fcs:x}")

# Point d'entrée du script
if __name__ == "__main__":
    main()
