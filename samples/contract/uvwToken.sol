// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract uvwToken is
    ERC20,
    ERC20Burnable,
    ERC20Snapshot,
    Pausable,
    AccessControl,
    ERC20Permit,
    ERC20Votes,
    Ownable
{
    using SafeMath for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 public maxSupply;

    uint8 internal _decimals = 10;
    string internal _name = "uvwToken";
    string internal _symbol = "UVWT";

    uint256 private _totalSupply = 0;

    mapping (address => uint256) private _balances;
    mapping(string => bytes32) internal Roles;

    constructor()
        ERC20("uvwToken", "UVWT")
        ERC20Permit("uvwToken")
    {
        maxSupply = 1000000000 * 10**_decimals; // 1 Billion Tokens ^ 10 decimals

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) returns (bool)  {
        _pause();
        return true;
    }

    function unpause() public onlyRole(PAUSER_ROLE) returns (bool) {
        _unpause();
        return true;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burnToken(address account, uint256 amount) public onlyRole(BURNER_ROLE) {
        //super.burn(account, amount);
        _burn(account, amount);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    /// @dev removes votes from account (accountability)
    /// @param _account account whose votes will removed 
    function _slashVotes(address _account, uint256 _amount) private whenNotPaused {
        _burn(_account, _amount);
    } 

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        require(
            totalSupply() + amount <= maxSupply,
            "Error: Max supply reached, 1 Billion tokens minted."
        );
        super._mint(to, amount);
        // _totalSupply = _totalSupply.add(amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

    function stringToBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        bytes memory _S = bytes(source);
        // assembly {
        //     result := mload(add(source, 32))
        // }
        return keccak256(_S);
    }

    function setRole(string memory role, address _add) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 _role = stringToBytes32(role);
        Roles[role] = _role;
        _setupRole(_role, _add);
    }

    function revokeRole(string memory role, address _revoke) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 _role = stringToBytes32(role);
        Roles[role] = _role;
        _revokeRole(_role, _revoke);
    }
}
