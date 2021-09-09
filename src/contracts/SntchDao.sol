pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/SntchTokenInterface.sol";

contract SntchDao is Ownable {

	AggregatorV3Interface internal priceFeed;
	SntchTokenInterface public sntch;
	
	using SafeMath for uint256;

	string public name = 'SNTCH DAO';
	uint256 public sntchTokenPrice = 250000000000000000000000000; //$2.5/token * 10**8(from chainlink eth/usd price) *10**18(toWei)  
	uint256 public whitelistedNumber = 0;

	mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;

    event Whitelisted(address addr, bool status);
    event Blacklisted(address addr, bool status);
    event TokenAddressChange(address token);

    constructor(address _aggregator, address _sntchTokenAddress) public {
    	require(_sntchTokenAddress != address(0x0), "Token address cannot be a null-address");
    	priceFeed = AggregatorV3Interface(_aggregator);
    	sntch = SntchTokenInterface(_sntchTokenAddress);
    }

    function getCurrentTokenPrice() public view returns (uint256) {
    	(,int256 answer, , ,) = priceFeed.latestRoundData();
    	uint256 price = uint256(answer);
    	uint256 minTokenPurchaseInEth = sntchTokenPrice / price;
    	return minTokenPurchaseInEth;
    }

    function whitelistAddress(address _add) public payable {
    	//whitelist the member once sntch tokens have been purchased
    	require(!whitelist[_add], "Candidate must not be already whitelisted");
    	require(!blacklist[_add], "Candidate must not be already blacklisted");
    	require(msg.value >= getCurrentTokenPrice(), "You must send enough Ether for at least one sntch token which is approx. $2.5 worth of Ether");
    
    	//buyTokens(_add, msg.value);
    	whitelist[_add] = true;
    	whitelistedNumber++;
    	emit Whitelisted(_add, true);
    }

    function buyTokensThrow(address _buyer) external payable {
    	require(!whitelist[_buyer], "Candidate must not be already whitelisted");
    	require(!blacklist[_buyer], "Candidate must not be already blacklisted");

    	uint256 minTokenPurchaseInEth = getCurrentTokenPrice();
    	require(msg.value >= minTokenPurchaseInEth, "You must send enough Ether for at least one sntch token which is approx. $2.5 worth of Ether");
    	uint256 tokensToPurchase = msg.value / minTokenPurchaseInEth;
    	require(daoTokenBalance() >= tokensToPurchase);
    	sntch.transfer(_buyer, tokensToPurchase);
    }

    //this is called if there are no tokens left for sale in the DAO; the payment is refunded
    function buyTokensInternal(address _buyer, uint256 _amount) internal {
    	require(!blacklist[_buyer], "Candidate must not be already blacklisted");
    	uint256 minTokenPurchaseInEth = getCurrentTokenPrice();
    	require(_amount >= minTokenPurchaseInEth, "You must send enough Ether for at least one sntch token which is approx. $2.5 worth of Ether");
    	uint256 tokensToPurchase = _amount / minTokenPurchaseInEth;
    	if (daoTokenBalance() < tokensToPurchase) { //refund the ether that was sent
    		address payable sender = payable(msg.sender);
    		sender.transfer(_amount);
    	} else {
    		sntch.transfer(_buyer, tokensToPurchase);
    	}
    }

    fallback() external payable {
    	//fallback function if ether is sent to the DAO without any specific function called
    	if (!whitelist[msg.sender]) {
    		whitelistAddress(msg.sender);
    	} else {
    		//buyTokens(msg.sender, msg.value);
    	}
    }

    function daoTokenBalance() public view returns (uint256) {
    	return sntch.balanceOf(address(this));
    }

    //needed incase the token needs to be changed
    function changeTokenAddress(address _newToken) onlyOwner public {
    	require(_newToken != address(0x0), "Token address cannot be a null-address");
    	sntch = SntchTokenInterface(_newToken);
    	emit TokenAddressChange(_newToken);
    }
}