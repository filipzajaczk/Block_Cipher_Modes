# Block Cipher Modes: Image Encryption Analysis

## Project Overview
This project explores how different block cipher modes work by applying them to image files. It uses AES encryption (via SageMath's `RijndaelGF` module) to encrypt raw image pixels block by block. 

By visualizing the encrypted output, we can easily compare the mechanisms of ECB, CBC, CFB, and OFB modes, and see the practical security implications of each approach.

---

## Visualizing Encryption Modes

### 1. Original Image
Before encryption, the script reads the original image file. It extracts the Red, Green, and Blue (RGB) color channels, converts the pixel values into hexadecimal strings, and splits them into 128-bit blocks.

<img width="257" height="255" alt="ananas" src="https://github.com/user-attachments/assets/bf5b648a-6c31-4637-818c-9bc1dc7a9abc" />

### 2. ECB Mode (Electronic Codebook)
ECB is the most basic encryption mode. It divides the data into blocks and encrypts each block independently using the same key. 

* **Observation:** Because identical plaintext blocks are encrypted into identical ciphertext blocks, repeating patterns in the data are preserved. In the image below, you can still clearly see the original shapes and contours. This visual proof demonstrates why ECB is considered highly insecure for structured data.

<img width="375" height="374" alt="ecb" src="https://github.com/user-attachments/assets/079b52a4-2df5-400d-9ece-1fb2e8de64bf" />

### 3. CBC Mode (Cipher Block Chaining)
CBC mode solves the pattern preservation problem by chaining the blocks together. Before a plaintext block is encrypted, it is XORed with the ciphertext of the previous block. The first block uses an Initialization Vector (IV).

* **Observation:** Identical plaintext blocks now produce completely different ciphertext blocks. The visual structure is destroyed, resulting in pseudorandom noise.

<img width="376" height="373" alt="cbc" src="https://github.com/user-attachments/assets/efe1d2c5-bb5c-4b10-a931-5d4dc8a84898" />

### 4. CFB Mode (Cipher Feedback)
Instead of encrypting the plaintext directly, CFB mode encrypts the previous ciphertext block, and then XORs that result with the current plaintext block. 

* **Observation:** Like CBC, this method successfully hides all visual patterns from the original image.

<img width="372" height="370" alt="cfb" src="https://github.com/user-attachments/assets/ecf31883-c47b-40e5-9c4c-fb1a0318dec7" />

### 5. OFB Mode (Output Feedback)
OFB mode essentially turns the block cipher into a stream cipher. It repeatedly encrypts the Initialization Vector (IV) to create a pseudorandom keystream, which is then XORed with the plaintext blocks.

* **Observation:** Interestingly, the encrypted image below still reveals the outlines and color correlations of the original object. This is a direct result of reusing the exact same Key and IV for the Red, Green, and Blue channels independently in the code.

<img width="368" height="370" alt="ofb" src="https://github.com/user-attachments/assets/43c93538-a733-460e-977f-ad764085c0a4" />


---

## Tools & Capabilities

This project avoids high-level Python wrappers (like PyCryptodome) to demonstrate a lower-level understanding of cryptography and data processing.

* **Core Cryptography:** Built on **SageMath**, utilizing the `RijndaelGF` module to handle AES block encryption at a mathematical level.
* **Image Processing:** Uses `numpy` and `matplotlib` to extract raw RGB channels from `.png` files, modify them, and rebuild the matrices into encrypted images.
* **Custom Operations:** All padding, 128-bit block splitting, and XOR operations (`hex_xor`) are implemented manually.

## How to Run

This script requires the SageMath environment.
