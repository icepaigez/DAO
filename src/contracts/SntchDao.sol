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
	uint public today; //time when voting on a proposal must have ended
	bytes32[] public proposalIndex;

	struct Proposal {
		uint256 index;
	    string name;
	    address payable initiator;
	    uint256 votes;
	    uint256 end;
	    string proposalURI;
	    bool exists;
  	}

	mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;
    mapping (bytes32 => Proposal) public proposals;
    mapping (address => uint256) public deletions;

    event Whitelisted(address addr, bool status);
    event Blacklisted(address addr, bool status);
    event TokenAddressChange(address token);
    event ProposalCreated(uint256 index, string name, address initiator);
    event ProposalDeleted(uint256 index, string name, address initiator);

    constructor(address _aggregator, address _sntchTokenAddress) public {
    	require(_sntchTokenAddress != address(0x0), "Token address cannot be a null-address");
    	priceFeed = AggregatorV3Interface(_aggregator);
    	sntch = SntchTokenInterface(_sntchTokenAddress);
    }

    modifier onlyMembers() {
    	require(whitelist[msg.sender], "Only members can: you should buy some sntch tokens.");
    	require(!blacklist[msg.sender], "Must not be already blacklisted");
    	require(sntch.balanceOf(msg.sender) >= 10**sntch.decimals(), "Must have at least 1 sntch token");
    	_;
    }

    function getCurrentTokenPrice() public view returns (uint256) {
    	(,int256 answer, , ,) = priceFeed.latestRoundData();
    	uint256 price = uint256(answer);
    	uint256 minTokenPurchaseInEth = sntchTokenPrice / price;
    	return minTokenPurchaseInEth;
    }

    function buyTokens(address _buyer) public payable {
    	// require(!whitelist[_buyer], "Candidate must not be already whitelisted");
    	require(!blacklist[_buyer], "Candidate must not be already blacklisted");

    	uint256 minTokenPurchaseInEth = getCurrentTokenPrice();
    	require(msg.value >= minTokenPurchaseInEth, "You must send enough Ether for at least one sntch token which is approx. $2.5 worth of Ether");
    	uint256 tokensToPurchase = msg.value / minTokenPurchaseInEth;
    	if (daoTokenBalance() >= tokensToPurchase) {
    		address payable sender = payable(msg.sender);
    		sender.transfer(msg.value);
    	} else {
    		sntch.transfer(_buyer, tokensToPurchase);
    		if (!whitelist[_buyer]) {
    			whitelist[_buyer] = true;
	    		whitelistedNumber++;
    		}
	    	emit Whitelisted(_buyer, true);
    	}
    }


    fallback() external payable {
    	//fallback function if ether is sent to the DAO without any specific function called
    	buyTokens(msg.sender);
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

    function createProposal(string memory _name, address payable _initiator, string memory _proposalURI, uint256 _endTime) public onlyMembers {
    	today = block.timestamp;
    	bytes32 hash = keccak256(abi.encodePacked(_name, _proposalURI, block.number));
    	proposalIndex.push(hash);
    	require(!proposals[hash].exists, "Proposal must not already exist in same block!");
    	uint256 proposalEndTime = today + _endTime; //endtime can be in days or minutes or years
    	uint256 id = proposalIndex.length - 1;
    	proposals[hash] = Proposal(id, _name, _initiator, 0, proposalEndTime, _proposalURI, true);
    	emit ProposalCreated(proposals[hash].index, proposals[hash].name, proposals[hash].initiator);
    }

    function proposalExists(bytes32 hash) public view returns (bool) {
    	return proposals[hash].exists;
    }

    function getProposal(bytes32 hash) public view returns (string memory proposalName, address payable initiator, string memory proposalURI) {
    	return (proposals[hash].name, proposals[hash].initiator, proposals[hash].proposalURI);
    }

    function getAllProposalHashes() public view returns (bytes32[] memory) {
    	return proposalIndex;
    }

    function getProposalCount() public view returns (uint256) {
    	return proposalIndex.length;
    }

    function deleteProposal(bytes32 hash) internal {
    	require(proposalExists(hash), "Proposal must exist to be deletable.");
    	Proposal storage propose = proposals[hash];

    	propose.exists = false;
    	deletions[proposals[hash].initiator] += 1;
    	emit ProposalDeleted(propose.index, propose.name, propose.initiator);
    }
}

