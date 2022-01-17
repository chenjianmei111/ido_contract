// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract CicadaIdoConfig is Ownable {

    uint256 public constant RATIO_PRECISION = 10**6;
    uint256 public constant TOKEN_PRECISION = 10**18;
    address public constant KoltAddr = 0xf443ebD06Efc583Ace5140e1452518aCb9fda358; 
    address public constant UsdtAddr = 0xc3aF9B30D0610c50864Ee278674322A03031bf91; 

    //Whitelist list collection
     EnumerableSet.AddressSet private Whitelist;
    
    //ido total
    uint256 public idoTotal;    
    //Total sale,KOLT
    uint256 public SellTotal;
    //Maximum of single user(USDT);
    uint256 public SingleBuyHighest;
    //Minimum of single buy(USDT);
    uint256 public SingleBuyLowest;
    //Ido start time
    uint256 public IdoStartTs;
    //Ido end time
    uint256 public IdoEndTs;
    //Whitelist end time
    uint256 public WhitelistEndTs;
    //Purchase price:1000000(1USDT:1KOLT);100000(0.1USDT:1KOLT);10000(0.01USDT:1KOLT)
    uint256 public BuySinglePrice;

    //The first release ratio 
    //50% is expressed as: 50 * RATIO_PRECISION / 100
    uint256 public FirstReleaseRatio;

    constructor() {
	idoTotal = 10**6 * TOKEN_PRECISION;
	SellTotal = 10**6 * TOKEN_PRECISION;
	SingleBuyHighest = 10**4 * TOKEN_PRECISION;
	SingleBuyLowest = 10**3 * TOKEN_PRECISION;
	IdoStartTs = block.timestamp;
	IdoEndTs = block.timestamp + 60*120;
	WhitelistEndTs = block.timestamp + 60*60;
	BuySinglePrice = 1 * RATIO_PRECISION;  //1:1
	FirstReleaseRatio = 50 * RATIO_PRECISION / 100; //50%
    }
    
    function addWhitelist(address[] memory _Addrs) external onlyOwner {
	uint256 length = _Addrs.length;
	bool _contain;
	for(uint256 i = 0; i < length; ++i) {
	    _contain = EnumerableSet.contains(Whitelist,_Addrs[i]);
	    if(!_contain) {
		EnumerableSet.add(Whitelist,_Addrs[i]);
	    }
	}
    }

    function delWhitelist(address[] memory _Addrs) external onlyOwner {
	uint256 length = _Addrs.length;
	bool _contain;
	for(uint256 i = 0; i < length; ++i) {
	    _contain = EnumerableSet.contains(Whitelist,_Addrs[i]);
	    if(_contain) {
		EnumerableSet.remove(Whitelist,_Addrs[i]);
	    }
	}
    }

    function getWhitelist() external view returns(address[] memory) {
        uint256 length = EnumerableSet.length(Whitelist);
        address[] memory addrs =  new address[](length);
        addrs = EnumerableSet.values(Whitelist);
	return addrs;
    }

    function isWhitelistUser(address _addr) public view returns(bool){
	return EnumerableSet.contains(Whitelist, _addr);
    }

    function getAllConfig() external view returns(uint256 _selltotal,
        uint256 _buyhighest,
        uint256 _buylowest,
        uint256 _starttime,
        uint256 _endtime,
        uint256 _whiteEndTime,
        uint256 _price,
        uint256 _Ratio,
	uint256 _idoTotal) {	
	return (SellTotal, SingleBuyHighest,
		SingleBuyLowest, IdoStartTs,
		IdoEndTs, WhitelistEndTs,
		BuySinglePrice, FirstReleaseRatio, idoTotal);	
    }

    function setAllConfig(uint256 _selltotal,
        uint256 _buyhighest,
        uint256 _buylowest,
        uint256 _starttime,
        uint256 _endtime,
        uint256 _whiteEndTime,
        uint256 _price,
        uint256 _Ratio,
        uint256 _idoTotal) external onlyOwner {	
	SellTotal = _selltotal; 
	SingleBuyHighest = _buyhighest;
	SingleBuyLowest = _buylowest; 
	IdoStartTs = _starttime;
	IdoEndTs = _endtime; 
	WhitelistEndTs = _whiteEndTime;
	BuySinglePrice = _price;
	FirstReleaseRatio = _Ratio;
	idoTotal = _idoTotal;
    }

    function getKoltAmount(uint256 _usdt) internal
	view returns(uint256) {
	uint256 _kolt = (_usdt * RATIO_PRECISION) / BuySinglePrice;
	return _kolt;	
    }

    function getReleaseFirst(uint256 _kolt) internal 
	view returns(uint256 _ReleaseKolt) {
	_ReleaseKolt =  _kolt * FirstReleaseRatio / RATIO_PRECISION;
    }
}
