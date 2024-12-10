// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// Importación de la interfaz IERC20 para interactuar con tokens ERC-20.
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// Importación de la interfaz IERC721 para interactuar con tokens ERC-721 (NFTs).
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Contrato principal para gestionar subastas.
contract AuctionPlatform {
    // Estructura que representa una subasta.
    struct Auction {
        address seller;          // Dirección del vendedor que creó la subasta.
        address highestBidder;   // Dirección del ofertante con la puja más alta.
        uint256 highestBid;      // Cantidad más alta ofertada en la subasta.
        uint256 tokenId;         // ID del token NFT que está siendo subastado.
        uint256 endTime;         // Tiempo de finalización de la subasta (en timestamp).
        bool active;             // Indica si la subasta está activa o ya ha finalizado.
    }

    // Referencia al contrato ERC-20 que se utilizará para las pujas.
    IERC20 public immutable auctionToken;
    // Referencia al contrato ERC-721 que contiene los NFTs subastados.
    IERC721 public immutable auctionNFT;
    // Contador para asignar IDs únicos a cada subasta.
    uint256 public auctionIdCounter;
    // Mapeo para almacenar todas las subastas por su ID.
    mapping(uint256 => Auction) public auctions;

    // Evento que se emite cuando se crea una nueva subasta.
    event AuctionCreated(uint256 indexed auctionId, uint256 tokenId, uint256 endTime);
    // Evento que se emite cuando se realiza una nueva puja.
    event NewBid(uint256 indexed auctionId, address bidder, uint256 bidAmount);
    // Evento que se emite cuando una subasta finaliza.
    event AuctionEnded(uint256 indexed auctionId, address winner, uint256 bidAmount);

    // Constructor que inicializa las referencias de los contratos ERC-20 y ERC-721.
    constructor(address _auctionToken, address _auctionNFT) {
        auctionToken = IERC20(_auctionToken); // Asigna la dirección del contrato ERC-20.
        auctionNFT = IERC721(_auctionNFT);   // Asigna la dirección del contrato ERC-721.
    }

    // Función para crear una nueva subasta.
    function createAuction(uint256 tokenId, uint256 duration) external {
        require(duration > 0, "La duracion debe ser mayor a cero");
        require(auctionNFT.ownerOf(tokenId) == msg.sender, "No eres el propietario del NFT");
        require(
            auctionNFT.getApproved(tokenId) == address(this) || 
            auctionNFT.isApprovedForAll(msg.sender, address(this)),
            "El contrato no esta autorizado para transferir el NFT"
        );

        // TODO: Transferir el NFT del vendedor al contrato de subastas.
        auctionNFT.transferFrom(msg.sender, address(this), tokenId);

        // TODO: Asignar un nuevo ID único a la subasta e inicializarla.
        uint256 auctionId = auctionIdCounter++;
        auctions[auctionId] = Auction({
            seller: msg.sender,          // Dirección del vendedor que creó la subasta.
            highestBidder: address(0),   // Inicialmente no hay ofertas.
            highestBid: 0,               // No hay ofertas, por lo que el monto es 0.
            tokenId: tokenId,            // ID del NFT que se subasta.
            endTime: block.timestamp + duration, // Calcula el tiempo de finalización.
            active: true                 // Marca la subasta como activa.
        });

        // TODO: Emitir un evento para informar que la subasta fue creada.
        emit AuctionCreated(auctionId, tokenId, block.timestamp + duration);
    }

    // Función para realizar una oferta en una subasta.
    function placeBid(uint256 auctionId, uint256 bidAmount) external {
        Auction storage auction = auctions[auctionId]; // Obtiene los detalles de la subasta.
        require(block.timestamp < auction.endTime, "La subasta ha finalizado"); // Verifica que la subasta no haya finalizado.
        require(auction.active, "La subasta no esta activa"); // Verifica que la subasta esté activa.
        require(bidAmount > auction.highestBid, "La oferta debe ser mayor a la actual"); // Verifica que la oferta sea mayor a la actual.
        require(
            auctionToken.balanceOf(msg.sender) >= bidAmount,
            "Saldo insuficiente de tokens"
        );
        require(
            auctionToken.allowance(msg.sender, address(this)) >= bidAmount,
            "Aprobacion insuficiente de tokens"
        );

        // TODO: Transferir tokens del ofertante al contrato de subastas.
        auctionToken.transferFrom(msg.sender, address(this), bidAmount);

        // TODO: Reembolsar al ofertante anterior si hubo una oferta previa.
        if (auction.highestBidder != address(0)) {
            auctionToken.transfer(auction.highestBidder, auction.highestBid);
        }

        // TODO: Actualizar los datos de la subasta con la nueva oferta.
        auction.highestBid = bidAmount;
        auction.highestBidder = msg.sender;

        // TODO: Emitir un evento para registrar la nueva oferta.
        emit NewBid(auctionId, msg.sender, bidAmount);
    }

    // Función para finalizar una subasta.
    function endAuction(uint256 auctionId) external {
        Auction storage auction = auctions[auctionId]; // Obtiene los detalles de la subasta.
        require(block.timestamp >= auction.endTime, "La subasta aun no ha finalizado"); // Verifica que la subasta haya finalizado.
        require(auction.active, "La subasta no esta activa"); // Verifica que la subasta esté activa.

        auction.active = false; // Marca la subasta como inactiva.

        if (auction.highestBidder != address(0)) {
            // TODO: Transferir el NFT al ganador.
            auctionNFT.transferFrom(address(this), auction.highestBidder, auction.tokenId);

            // TODO: Transferir el monto ofertado al vendedor.
            auctionToken.transfer(auction.seller, auction.highestBid);
        } else {
            // TODO: Devolver el NFT al vendedor si no hubo ofertas.
            auctionNFT.transferFrom(address(this), auction.seller, auction.tokenId);
        }

        // TODO: Emitir un evento para registrar que la subasta ha finalizado.
        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
    }

    // Función para obtener los detalles de una subasta
    function getAuction(uint256 auctionId) external view returns (
        address seller,
        address highestBidder,
        uint256 highestBid,
        uint256 tokenId,
        uint256 endTime,
        bool active
    ) {
        Auction storage auction = auctions[auctionId];
        return (
            auction.seller,
            auction.highestBidder,
            auction.highestBid,
            auction.tokenId,
            auction.endTime,
            auction.active
        );
    }
}