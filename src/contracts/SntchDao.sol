pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SntchDao is Ownable {
	
	using SafeMath for uint256;

	string public name = 'SNTCH DAO';
	uint256 public whitelistedNumber = 0;

	mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;

    event Whitelisted(address addr, bool status);
    event Blacklisted(address addr, bool status);
}