// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AuctionToken is ERC20, ERC20Permit, Ownable {
    event TokensMinted(address indexed to, uint256 amount);

    constructor(address initialOwner, uint256 initialSupply)
        ERC20("AuctionToken", "ATKN")
        ERC20Permit("AuctionToken")
        Ownable(initialOwner)
    {
        _mint(initialOwner, initialSupply * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "No se puede mintear a la direccion cero");
        require(amount > 0, "La cantidad debe ser mayor a cero");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
}