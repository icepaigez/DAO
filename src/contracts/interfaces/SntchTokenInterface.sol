pragma solidity ^0.8.0;
 
interface SntchTokenInterface {
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Locked(address indexed owner, uint256 indexed amount);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool);
    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool);
    function increaseLockedAmount(address _owner, uint256 _amount) external returns (uint256);
    function decreaseLockedAmount(address _owner, uint256 _amount) external returns (uint256);
    function getLockedAmount(address _owner) external view returns (uint256);
    function getUnlockedAmount(address _owner) external view returns (uint256);
}