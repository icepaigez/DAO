//SPDX-License-Identifier: UNLICENSED
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
	uint256 public whitelistedNumber = 0;
	uint256 public reserveTokens = 60000000;
	uint256 public sellableTokens = 40000000; //40m sntch tokens

 	struct Proposal {
 		string description;
 		bool executed;
 		int256 currentResult;
 		uint256 creationDate;
 		uint256 deadline;
 		mapping (address => bool) voters;
 		Vote[] votes;
 		address initiator;
 	}

 	struct Vote {
 		bool inSupport;
 		address voter;
 		string justification;
 		uint256 power;
 	}

 	Proposal[] public proposals;
 	uint256 proposalCount = 0;

	mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;
    mapping (address => uint256) stray;

    event Whitelisted(address addr, bool status);
    event Blacklisted(address addr, bool status);
    event TokenAddressChange(address token);
    event ProposalCreated(uint256 id, string description, address initiator);
    event ProposalExecuted(uint256 id);
    event Voted(address voter, bool vote, uint256 power, string justification);

    constructor(address _aggregator, address _sntchTokenAddress) {
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

    function getCurrentEthPrice() public view returns (int256) {
    	(,int256 answer, , ,) = priceFeed.latestRoundData();
    	return answer;
    }

    function buyTokens(address _buyer, uint256 tokenPrice) public payable {
    	// require(!whitelist[_buyer], "Candidate must not be already whitelisted");
    	require(!blacklist[_buyer], "Candidate must not be already blacklisted");
    	require(sellableTokens > 0, "Please buy tokens from an exchange");

    	require(msg.value >= tokenPrice, "You must send enough Ether for at least one sntch token which is approx. $2.5 worth of Ether");
    	uint256 tokensToPurchase = msg.value / tokenPrice;
    	if (sellableTokens < tokensToPurchase) {
    		address payable sender = payable(msg.sender);
    		sender.transfer(msg.value);
    	} else {
    		sntch.transfer(_buyer, tokensToPurchase*10**sntch.decimals());
    		if (!whitelist[_buyer]) {
    			whitelist[_buyer] = true;
	    		whitelistedNumber++;
	    		sellableTokens = sellableTokens.sub(tokensToPurchase);
    		}
	    	emit Whitelisted(_buyer, true);
    	}
    }

    //fallback function if ether is sent to the DAO without any specific function called
    fallback() external payable {
    	stray[msg.sender] = msg.value;
    } 

    receive() external payable {}

    function daoTokenBalance() public view returns (uint256) {
    	return sntch.balanceOf(address(this));
    }

    //needed incase the token needs to be changed
    function changeTokenAddress(address _newToken) onlyOwner public {
    	require(_newToken != address(0x0), "Token address cannot be a null-address");
    	sntch = SntchTokenInterface(_newToken);
    	emit TokenAddressChange(_newToken);
    }

    function vote(uint256 _proposalId, bool _vote, string memory _description, uint256 _votePower) onlyMembers public returns (int256) {
    	require(_votePower > 0, "At least some power must be given to the vote.");
    	require(sntch.balanceOf(msg.sender) >= _votePower, "Voter must have enough tokens to cover the power cost.");
    
    	Proposal storage p = proposals[_proposalId];

    	require(p.executed == false, "Proposal must not have been executed already.");
    	require(p.deadline > block.timestamp, "Proposal must not have expired.");
    	require(p.voters[msg.sender] == false, "User must not have already voted.");

    	uint256 voteId = p.votes.length;
    	Vote storage pvote = p.votes[voteId];
    	pvote.inSupport = _vote;
    	pvote.justification = _description;
    	pvote.voter = msg.sender;
    	pvote.power = _votePower;

    	p.voters[msg.sender] = true;

    	p.currentResult = _vote ? p.currentResult + int256(_votePower) : p.currentResult - int256(_votePower); //refers to the number of tokens voted for this proposal
   		sntch.increaseLockedAmount(msg.sender, _votePower);

   		emit Voted(msg.sender, _vote, _votePower, _description);
   		return p.currentResult;
    }

    function createProposal(string memory _description, uint256 _endTime) public onlyMembers {
    	uint256 proposalId = proposals.length;
    	Proposal storage p = proposals[proposalId];
    	p.description = _description;
    	p.executed = false;
    	p.creationDate = block.timestamp;
    	p.deadline = p.creationDate + _endTime; //endtime can be in minutes, days, hours, years, etc
    	p.initiator = msg.sender;

    	emit ProposalCreated(proposalId, _description, msg.sender);
    	proposalCount = proposalId + 1;
    }

    function executeProposal(uint256 _proposalId) public {
    	Proposal storage p = proposals[_proposalId];
    	require(!p.executed && block.timestamp >= p.deadline);
    	uint256 quorum = (51 * whitelistedNumber) / 100;
    	require(p.votes.length >= quorum && p.currentResult >= 100); //at least 100 tokens needed to execute a proposal
    
    	uint256 voteCount = p.votes.length;
    	for (uint i = 0; i < voteCount; i++) {
    		sntch.decreaseLockedAmount(p.votes[i].voter, p.votes[i].power);
    	}

    	p.executed = true;
    	emit ProposalExecuted(_proposalId);
    }

    function blacklistAddress(address _offender) internal {
	    require(blacklist[_offender] == false, "Can't blacklist a blacklisted user :/");
	    blacklist[_offender] == true;
	    sntch.increaseLockedAmount(_offender, sntch.getUnlockedAmount(_offender));
	    emit Blacklisted(_offender, true);
	}

	function unblacklistMe() payable public {
	    unblacklistAddress(msg.sender);
	}

	function unblacklistAddress(address _offender) payable public {
	    require(msg.value >= 0.01 ether, "Unblacklisting fee");
	    require(blacklist[_offender] == true, "Can't unblacklist a non-blacklisted user :/");
	    require(notVoting(_offender), "Offender must not be involved in a vote.");
	    blacklist[_offender] = false;
	    sntch.decreaseLockedAmount(_offender, sntch.balanceOf(_offender));
	    emit Blacklisted(_offender, false);
	}
   
   function notVoting(address _voter) internal view returns (bool) {
	    for (uint256 i = 0; i < proposalCount; i++) {
	        if (proposals[i].executed == false && proposals[i].voters[_voter] == true) {
	            return false;
	        }
	    }
	    return true;
	}
}


 
 