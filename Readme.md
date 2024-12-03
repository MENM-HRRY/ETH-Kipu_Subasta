# Interacción Práctica con Tokens ERC-20 y ERC-721

## **Objetivo**
Desarrollar un conjunto de contratos inteligentes que permitan interactuar con tokens ERC-20 y ERC-721 para realizar operaciones básicas como transferencias directas, autorizaciones y transferencias indirectas. Finalmente, integrar ambos estándares en un caso de uso práctico que combine el uso de ambas tecnologías.

---

## **Plataforma de Subastas con Tokens**

### **Descripción**
Implementar una plataforma de subastas donde los usuarios puedan pujar por NFTs utilizando tokens ERC-20.

### **Objetivos**
- Crear contratos ERC-20 y ERC-721.
- Implementar un contrato de subasta donde:
  - Los usuarios depositen tokens ERC-20 para realizar sus ofertas.
  - Al finalizar la subasta, el NFT se transfiere al mejor postor y los tokens al propietario original.
- **Extras:** Añadir un cronómetro o lógica de tiempo para las subastas.

---

## **Flujo General**

1. **Deployar los contratos:**
   - Deployar `AuctionToken` con una cantidad inicial de tokens.
   - Deployar `AuctionNFT` para crear y gestionar los NFTs.
   - Deployar `AuctionPlatform` pasando las direcciones de los contratos `AuctionToken` y `AuctionNFT`.

2. **Crear una subasta:**
   - El usuario propietario de un NFT llama a `createAuction` en `AuctionPlatform` especificando el token ID del NFT y la duración de la subasta.

3. **Realizar pujas:**
   - Los usuarios transfieren tokens ERC-20 al contrato llamando a `placeBid` con la cantidad deseada.

4. **Finalizar la subasta:**
   - Una vez que la subasta termina, el creador o cualquier usuario puede llamar a `endAuction` para finalizarla.

---

## **Conceptos Clave**

### **1. Transferencias de Tokens ERC-20**
- **`transfer`:** Envía tokens desde el usuario que llama la función a otro usuario.
- **`approve`:** Autoriza a otro usuario o contrato a gastar una cantidad específica de tokens en tu nombre.
- **`transferFrom`:** Permite a un contrato o usuario transferir tokens desde otra cuenta, pero solo si previamente fue aprobado.

### **2. Transferencias de Tokens ERC-721**
- Similar a los ERC-20, pero trabaja con tokens únicos.
- **`transferFrom`:** Transfiere un NFT de un propietario a otro, siempre que el llamante tenga autorización.

---

## **Explicación Detallada de `transferFrom`**

### **Flujo Interno de `transferFrom`**

1. **Para ERC-20:**
   - Verifica que el saldo del emisor (`owner`) sea suficiente.
   - Verifica que el contrato o usuario esté autorizado con un `allowance` mayor o igual al monto de la transferencia.
   - Disminuye el `allowance` correspondiente.
   - Realiza la transferencia.

2. **Para ERC-721:**
   - Verifica que el `msg.sender` sea el propietario o esté autorizado.
   - Verifica que el `tokenId` exista.
   - Cambia la propiedad del NFT.

---

## **Errores Comunes que los Alumnos Deben Evitar**

### **1. Para ERC-20:**
- No aprobar antes de llamar a `transferFrom`.
- Aprobar un monto insuficiente.
- No tener saldo suficiente en la cuenta del emisor.

### **2. Para ERC-721:**
- Intentar transferir un NFT sin ser propietario o sin autorización.
- No usar `approve` o `setApprovalForAll` para autorizar a otro contrato o usuario.
