from sage.crypto.mq.rijndael_gf import RijndaelGF
import random
import secrets
import warnings

warnings.filterwarnings("ignore")


# dzieli wiadomość (ciąg szesnastkowy) na bloki o zadanej długości (domyślnie 128 bitów = 32 znaki hex)
def message_to_blocks(message, sizeBits=128):
    sizeHex = sizeBits // 4

    # dodaj wypełnienie (padding), jeśli długość wiadomości nie jest wielokrotnością rozmiaru bloku
    temp = len(message) % sizeHex
    if temp != 0:
        padding = sizeHex - temp
        message += '0' * padding

    blocks = [message[i:i + sizeHex] for i in range(0, len(message), sizeHex)]
    return blocks


# tryb ECB – szyfrowanie każdego bloku niezależnie
def ECB_encryption(message, key):
    blocks = message_to_blocks(message)
    aes = RijndaelGF(4, 4)
    cipher_text = []
    for block in blocks:
        cipher_text.append(aes.encrypt(block, key))

    return ''.join(cipher_text)


def ECB_decryption(cipher, key):
    blocks = message_to_blocks(cipher)
    aes = RijndaelGF(4, 4)
    plain_text = []
    for block in blocks:
        plain_text.append(aes.decrypt(block, key))

    return ''.join(plain_text)


# XOR dwóch ciągów szesnastkowych
def hex_xor(hex1, hex2):
    a = int(hex1, 16)
    b = int(hex2, 16)
    c = a ^ b
    return format(c, '0' + str(len(hex1)) + 'x')


# tryb CBC – każdy blok szyfrowany z XOR-em poprzedniego szyfrogramu
def CBC_encryption(message, key, start_vector):
    blocks = message_to_blocks(message)
    aes = RijndaelGF(4, 4)
    cipher_text = []
    prev = start_vector

    for block in blocks:
        temp = hex_xor(block, prev)
        cipher = aes.encrypt(temp, key)
        cipher_text.append(cipher)
        prev = cipher

    return ''.join(cipher_text)


def CBC_decryption(message, key, start_vector):
    blocks = message_to_blocks(message)
    aes = RijndaelGF(4, 4)
    plain_text = []
    prev = start_vector

    for block in blocks:
        temp = aes.decrypt(block, key)
        plain = hex_xor(prev, temp)
        plain_text.append(plain)
        prev = block

    return ''.join(plain_text)


# tryb CFB – szyfruje poprzedni szyfrogram, a wynik XORuje z aktualnym blokiem
def CFB_encryption(message, key, start_vector):
    blocks = message_to_blocks(message)
    aes = RijndaelGF(4, 4)
    cipher_text = []
    prev = start_vector

    for block in blocks:
        temp = aes.encrypt(prev, key)
        cipher = hex_xor(temp, block)
        cipher_text.append(cipher)
        prev = cipher

    return ''.join(cipher_text)


def CFB_decryption(message, key, start_vector):
    blocks = message_to_blocks(message)
    aes = RijndaelGF(4, 4)
    plain_text = []
    prev = start_vector

    for block in blocks:
        temp = aes.encrypt(prev, key)
        plain = hex_xor(block, temp)
        plain_text.append(plain)
        prev = block

    return ''.join(plain_text)


# tryb OFB – generuje pseudolosowy strumień, który XORuje się z wiadomością
def OFB_encryption(message, key, start_vector):
    blocks = message_to_blocks(message)
    aes = RijndaelGF(4, 4)
    cipher_text = []
    prev = start_vector

    for block in blocks:
        temp = aes.encrypt(prev, key)
        cipher = hex_xor(temp, block)
        cipher_text.append(cipher)
        prev = temp

    return ''.join(cipher_text)


def OFB_decryption(message, key, start_vector):
    blocks = message_to_blocks(message)
    aes = RijndaelGF(4, 4)
    plain_text = []
    prev = start_vector

    for block in blocks:
        temp = aes.encrypt(prev, key)
        plain = hex_xor(block, temp)
        plain_text.append(plain)
        prev = temp

    return ''.join(plain_text)


# symulacja błędów transmisji
def bsc(message, error=0.95):
    noise = [1 if random.random() < (1 - error) else 0 for _ in range(len(message))]
    noisy_message = ""
    for i in range(0, len(message)):
        if noise[i] == 1:
            noisy_message = noisy_message + format(random.randint(0, 15), '01x')  # losowa zmiana
        else:
            noisy_message = noisy_message + message[i]
    return noisy_message


# sprawdzenie zgodności dwóch wiadomości (ile znaków się zgadza)
def check(message, noisy_message):
    ctr = 0
    for i in range(0, len(message)):
        if message[i] == noisy_message[i]:
            ctr += 1
    return float(ctr) / len(message)


# wczytanie obrazu i konwersja kanałów R, G, B do ciągów szesnastkowych
def load(path):
    image = np.copy(imread(path))

    if not image.flags['WRITEABLE']:
        raise NameError('Image is not writeable')

    red, green, blue = [], [], []
    height, width, _ = image.shape

    for i in range(height):
        for j in range(width):
            red.append(image[i, j, 0])
            green.append(image[i, j, 1])
            blue.append(image[i, j, 2])

    red_string, green_string, blue_string = "", "", ""

    for i in range(len(red)):
        red_string += format(red[i], "02x")
        green_string += format(green[i], "02x")
        blue_string += format(blue[i], "02x")

    return height, width, red_string, green_string, blue_string


# odtworzenie obrazu z ciągów szesnastkowych RGB i zapisanie/wizualizacja
def store(path, red_string, green_string, blue_string, show=True):
    image = np.copy(imread(path))
    height, width, _ = image.shape

    if not image.flags['WRITEABLE']:
        raise NameError('Image is not writeable')

    red, green, blue = [], [], []

    for i in range(0, len(red_string), 2):
        red.append(int(red_string[i:i + 2], 16))
        green.append(int(green_string[i:i + 2], 16))
        blue.append(int(blue_string[i:i + 2], 16))

    for i in range(height):
        for j in range(width):
            image[i, j, 0] = red[i * width + j]
            image[i, j, 1] = green[i * width + j]
            image[i, j, 2] = blue[i * width + j]

    if show:
        plt.imshow(image)
        plt.axis('off')
        plt.show()
    else:
        imsave("encrypted_" + path, image)


def text_encryption():
    message = "111111111222222223333444566677788889990aaaaabbbbbbccccdddddfffffffeee213456789012345567891233456"
    key = secrets.token_hex(16)
    inicialization = secrets.token_hex(16)
    print(f"Wiadomosc: {message}")
    print(f"Key: {key}")

    print("\n-----------ECB-----------")
    ECB_cipher = ECB_encryption(message, key)
    ECB_plain = ECB_decryption(ECB_cipher, key)
    print(f"Zaszyfrowana wiadomosc ECB: {ECB_cipher}")
    print(f"Zdeszyfrowana wiadomosc ECB: {ECB_plain}")

    print("\n-----------CBC-----------")
    CBC_cipher = CBC_encryption(message, key, inicialization)
    CBC_plain = CBC_decryption(CBC_cipher, key, inicialization)
    print(f"Zaszyfrowana wiadomosc CBC: {CBC_cipher}")
    print(f"Zdeszyfrowana wiadomosc CBC: {CBC_plain}")

    print("\n-----------CFB-----------")
    CFB_cipher = CFB_encryption(message, key, inicialization)
    CFB_plain = CFB_decryption(CFB_cipher, key, inicialization)
    print(f"Zaszyfrowana wiadomosc CFB: {CFB_cipher}")
    print(f"Zdeszyfrowana wiadomosc CFB: {CFB_plain}")

    print("\n-----------OFB-----------")
    OFB_cipher = OFB_encryption(message, key, inicialization)
    OFB_plain = OFB_decryption(OFB_cipher, key, inicialization)
    print(f"Zaszyfrowana wiadomosc OFB: {OFB_cipher}")
    print(f"Zdeszyfrowana wiadomosc OFB: {OFB_plain}")

    print("\n-----------Odpornosc na bledy transmisji-----------")
    ecb_broken = bsc(ECB_cipher)
    cbc_broken = bsc(CBC_cipher)
    cfb_broken = bsc(CFB_cipher)
    ofb_broken = bsc(OFB_cipher)

    ecb_plain = ECB_decryption(ecb_broken, key)
    cbc_plain = CBC_decryption(cbc_broken, key, inicialization)
    cfb_plain = CFB_decryption(cfb_broken, key, inicialization)
    ofb_plain = OFB_decryption(ofb_broken, key, inicialization)

    print("ECB zgodność:", check(message, ecb_plain))
    print("CBC zgodność:", check(message, cbc_plain))
    print("CFB zgodność:", check(message, cfb_plain))
    print("OFB zgodność:", check(message, ofb_plain))


def zad2_ecb(path):
    key = secrets.token_hex(16)
    h, w, red, green, blue = load(path)
    print("load finished")
    red_encrypt = ECB_encryption(red, key)
    print("red finished")
    green_encrypt = ECB_encryption(green, key)
    print("green finished")
    blue_encrypt = ECB_encryption(blue, key)
    print("blue finished")
    store(path, red_encrypt, green_encrypt, blue_encrypt)


def zad2_cbc(path):
    inicialization = secrets.token_hex(16)
    key = secrets.token_hex(16)
    h, w, red, green, blue = load(path)
    print("load finished")
    red_encrypt = CBC_encryption(red, key, inicialization)
    print("red finished")
    green_encrypt = CBC_encryption(green, key, inicialization)
    print("green finished")
    blue_encrypt = CBC_encryption(blue, key, inicialization)
    print("blue finished")
    store(path, red_encrypt, green_encrypt, blue_encrypt)


def zad2_cfb(path):
    inicialization = secrets.token_hex(16)
    key = secrets.token_hex(16)
    h, w, red, green, blue = load(path)
    print("load finished")
    red_encrypt = CFB_encryption(red, key, inicialization)
    print("red finished")
    green_encrypt = CFB_encryption(green, key, inicialization)
    print("green finished")
    blue_encrypt = CFB_encryption(blue, key, inicialization)
    print("blue finished")
    store(path, red_encrypt, green_encrypt, blue_encrypt)


def zad2_ofb(path):
    inicialization = secrets.token_hex(16)
    key = secrets.token_hex(16)
    h, w, red, green, blue = load(path)
    print("load finished")
    red_encrypt = OFB_encryption(red, key, inicialization)
    print("red finished")
    green_encrypt = OFB_encryption(green, key, inicialization)
    print("green finished")
    blue_encrypt = OFB_encryption(blue, key, inicialization)
    print("blue finished")
    store(path, red_encrypt, green_encrypt, blue_encrypt)


text_encryption()
# zad2_ecb("./ananas.png")
# zad2_cbc("./ananas.png")
# zad2_cfb("./ananas.png")
# zad2_ofb("./ananas.png")
