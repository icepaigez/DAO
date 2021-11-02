//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SNTCHToken is Ownable {
	using SafeMath for uint256;

	string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowance;
    mapping (address => uint256) private locked;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Locked(address indexed owner, uint256 indexed amount);

	constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
		_name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _decimals = 18;
        _balances[msg.sender] = totalSupply_;
	} 

	function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

	function balanceOf(address _owner) public view returns (uint256) {
		return _balances[_owner];
	}

	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0x0));
		require(_value <= _balances[msg.sender] - locked[msg.sender]);

		_balances[msg.sender] = _balances[msg.sender].sub(_value);
		_balances[_to] = _balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;		
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowance[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    	require(_to != address(0x0));
    	require(_value <= _balances[_from] - locked[_from]);
    	require(_value <= _allowance[_from][msg.sender] - locked[_from]);

    	_balances[_from] = _balances[_from].sub(_value);
    	_balances[_to] = _balances[_to].add(_value);
    	_allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
    	emit Transfer(_from, _to, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
    	_allowance[msg.sender][_spender] = (_allowance[msg.sender][_spender].add(_addedValue));
   		emit Approval(msg.sender, _spender, _allowance[msg.sender][_spender]);
   		return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
    	uint256 oldValue = _allowance[msg.sender][_spender];
    	if (_subtractedValue > oldValue) {
    		_allowance[msg.sender][_spender] = 0;
    	} else {
    		_allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    	}
    	emit Approval(msg.sender, _spender, _allowance[msg.sender][_spender]);
   		return true;
    }

    function increaseLockedAmount(address _owner, uint256 _amount) onlyOwner public returns (uint256) {
    	uint256 lockingAmount = locked[_owner].add(_amount);
    	require(balanceOf(_owner) >= lockingAmount, "Locking amount must not exceed balance");
    	locked[_owner] = lockingAmount;
    	emit Locked(_owner, lockingAmount);
    	return lockingAmount;
    }

    function decreaseLockedAmount(address _owner, uint256 _amount) onlyOwner public returns (uint256) {
    	uint256 amt = _amount;
    	require(locked[_owner] > 0, "Cannot go negative. Already at 0 locked tokens...");
    	if (amt > locked[_owner]) {
    		amt = locked[_owner];
    	}
    	uint256 lockingAmount = locked[_owner].sub(amt);
    	locked[_owner] = lockingAmount;
    	emit Locked(_owner, lockingAmount);
    	return lockingAmount;
    }

    function getLockedAmount(address _owner) public view returns (uint256) {
    	return locked[_owner];
    }

    function getUnlockedAmount(address _owner) public view returns (uint256) {
    	return _balances[_owner].sub(locked[_owner]);
    }
} 