pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/SntchTokenInterface.sol";

contract SntchDao {

	AggregatorV3Interface internal priceFeed;
	SntchTokenInterface public sntch;
	
	using SafeMath for uint256;

	string public name = 'SNTCH DAO';
	uint256 public tokenPriceInWei = 2500000000000000000; //$2.5 in wei int256 (NOT uint256: note the difference because of the chainlink price datatype)
	uint256 public whitelistedNumber = 0;

	mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;

    event Whitelisted(address addr, bool status);
    event Blacklisted(address addr, bool status);
    event TokenAddressChange(address token);

    constructor(address _aggregator, address _sntchTokenAddress) public {
    	require(_sntchTokenAddress != address(0x0), "Token address cannot be null-address");
    	priceFeed = AggregatorV3Interface(_aggregator);
    	sntch = SntchTokenInterface(_sntchTokenAddress);
    }

    function getCurrentTokenPrice() public view returns (uint256) {
    	(,int256 answer, , ,) = priceFeed.latestRoundData();
    	uint256 price = uint256 (answer);
    	uint256 minTokenPurchaseInEth = tokenPriceInWei / price;
    	return minTokenPurchaseInEth;
    }

    function whitelistAddress(address _add) public payable {
    	//whitelist the member once sntch tokens have been purchased
    	require(!whitelist[_add], "Candidate must not be already whitelisted");
    	require(!blacklist[_add], "Candidate must not be already blacklisted");
    	require(msg.value >= getCurrentTokenPrice(), "You must have enough for at least one sntch token which is approx. $2.5 worth of Ether");
    
    	//buyTokens(_add, msg.value);
    	whitelist[_add] = true;
    	whitelistedNumber++;
    	emit Whitelisted(_add, true);
    }

    fallback () external payable {
    	//fallback function if ether is sent to the DAO without any specific function called
    	if (!whitelist[msg.sender]) {
    		whitelistAddress(msg.sender);
    	} else {
    		//buyTokens(msg.sender, msg.value);
    	}
    }
}