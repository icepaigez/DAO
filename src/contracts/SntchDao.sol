pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SntchDao is Ownable {

	AggregatorV3Interface internal priceFeed;
	
	using SafeMath for uint256;

	string public name = 'SNTCH DAO';
	uint256 public tokenPriceInWei = 2500000000000000000; //$2.5 in wei

	mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;

    event Whitelisted(address addr, bool status);
    event Blacklisted(address addr, bool status);

    constructor(address _aggregator) public {
    	priceFeed = AggregatorV3Interface(_aggregator);
    }

    function getLatestEthPrice() public view returns (int256) {
    	(uint80 roundID, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
    	return answer;
    }

    function whitelistAddress(address _member) public payable {
    	//whitelist the member once sntch tokens have been purchased
    }

    function () external payable {
    	//fallback function if ether is sent to the DAO without any specific function called
    }
}