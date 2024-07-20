// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AdvancedToken is ERC20, Ownable {
    using SafeMath for uint256;

    // Mapeo para cuentas congeladas
    mapping(address => bool) private _frozenAccounts;

    // Eventos personalizados
    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);
    event TokensBurned(address indexed burner, uint256 amount);
    event TokensMinted(address indexed to, uint256 amount);

    // Constructor del contrato
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10**decimals());
    }

    // Función para congelar una cuenta
    function freezeAccount(address account) public onlyOwner {
        require(!_frozenAccounts[account], "Account is already frozen");
        _frozenAccounts[account] = true;
        emit AccountFrozen(account);
    }

    // Función para descongelar una cuenta
    function unfreezeAccount(address account) public onlyOwner {
        require(_frozenAccounts[account], "Account is not frozen");
        _frozenAccounts[account] = false;
        emit AccountUnfrozen(account);
    }

    // Función para quemar tokens
    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    // Función para acuñar nuevos tokens (solo el propietario)
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // Sobrescribir la función de transferencia para verificar cuentas congeladas
    function _update(address from, address to, uint256 amount) internal override {
        require(!_frozenAccounts[from], "Sender account is frozen");
        require(!_frozenAccounts[to], "Recipient account is frozen");
        super._update(from, to, amount);
    }

    // Función para verificar si una cuenta está congelada
    function isFrozen(address account) public view returns (bool) {
        return _frozenAccounts[account];
    }
}