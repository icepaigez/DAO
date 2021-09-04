pragma solidity ^0.8.0;

contract SNTCHTokenInterface {
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Locked(address indexed owner, uint256 indexed amount);

    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function balanceOf(address _owner) public view returns (uint256);
    function totalSupply() public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool);
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool);
    function increaseLockedAmount(address _owner, uint256 _amount) public returns (uint256);
    function decreaseLockedAmount(address _owner, uint256 _amount) public returns (uint256);
    function getLockedAmount(address _owner) public view returns (uint256);
    function getUnlockedAmount(address _owner) public view returns (uint256);
}