// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CicadaIdoConfig.sol";
import "./libraries/TransferHelper.sol";

contract CicadaIdo is CicadaIdoConfig{
    
    //userAddr => amount(KOLT)
    mapping(address => uint256) private BuyTotalAmount;
    //userAddr => amount(KOLT)
    mapping(address => uint256) private UserBalance;
    //collection of all participating IDO users
    EnumerableSet.AddressSet private AllIdoUser;
    //balance of SellTotal;
    
    function BuyKolt(uint256 _usdt) external {

	require(isWithinIdoTs() == true,"Ido not start or end");
	require(isMoreSingleBuyLowest(_usdt) == true, "Less than min amount");
	require(isWithinSingleBuyHighest(msg.sender, _usdt) 
	    == true, "More than max amount");
	require(SellTotal > 0, "Kolt Sold out");
	require(SellTotal >= getKoltAmount(_usdt),"Insufficient stock");
	
	uint256 _koltAmount;	
	uint256 _ReleaseKolt;
    
	if(isWhiteTs()){
	    require(isWhitelistUser(msg.sender) == true, "not Whitelist User");
	    TransferHelper.safeTransferFrom(
		UsdtAddr, msg.sender, address(this), _usdt);
	    _koltAmount = getKoltAmount(_usdt); 
	    _ReleaseKolt = getReleaseFirst(_koltAmount);
	    TransferHelper.safeTransfer(KoltAddr,msg.sender,_ReleaseKolt);
	} else {
	    TransferHelper.safeTransferFrom(
                UsdtAddr, msg.sender, address(this), _usdt); 
            _koltAmount = getKoltAmount(_usdt);
            _ReleaseKolt = getReleaseFirst(_koltAmount);
            TransferHelper.safeTransfer(KoltAddr,msg.sender,_ReleaseKolt); 
	}
	
	if(!EnumerableSet.contains(AllIdoUser,msg.sender)) {
	    EnumerableSet.add(AllIdoUser,msg.sender);
	}
	SellTotal -= _koltAmount;
	UserBalance[msg.sender] += (_koltAmount - _ReleaseKolt);
	BuyTotalAmount[msg.sender] += _koltAmount;
    }

    function isWhiteTs() public view returns (bool) {
	uint256 nowtime = block.timestamp;
	return (WhitelistEndTs > nowtime ? true:false);
    }    

    function isWithinIdoTs() public view returns (bool) {
	uint256 nowtime = block.timestamp;
	bool _Within;
	if ((nowtime < IdoEndTs ) &&
	    (nowtime > IdoStartTs )) {
		_Within = true;
	    } else {
		_Within = false;
	    }
	return _Within;
    }
    
    function isMoreSingleBuyLowest(uint256 _amount) public view returns (bool) {
	return (_amount >= SingleBuyLowest ? true:false);
    }
    
    function isWithinSingleBuyHighest(address _addr, uint256 _amount) public 
	view returns (bool) {
	uint256 total = BuyTotalAmount[_addr] + _amount;
	return (SingleBuyHighest >= total ? true:false);
    }

    function getUserBuy(address _addr) external view returns(uint256) {
	uint256 balance = BuyTotalAmount[_addr];
	return balance;
    }

    function getAllIdoUser() external view returns(address[] memory) {
        uint256 length = EnumerableSet.length(AllIdoUser);
        address[] memory addrs =  new address[](length);
        addrs = EnumerableSet.values(AllIdoUser);
        return addrs;
    }

    function getUserBalance(address[] memory addrs) external
        view returns(uint256[] memory){

        uint256 length = addrs.length;
        uint256[] memory amounts = new uint256[](length);
        for(uint256 i = 0; i < length; ++i) {
	   amounts[i] = UserBalance[addrs[i]];
        }
	return amounts;
    }
    
    //Proportion accuracy: 10**6; 1000000 means release 100%;
    //100000 means release 10%, 10000 means release 1%
    //this method Maybe over gas
    function koltRelease(uint256 _ReleaseRatio) external onlyOwner {
	require( _ReleaseRatio <= 10**6,"ReleaseRatio err");
	uint256 length = EnumerableSet.length(AllIdoUser);
	uint256 releseAmount;
	address userAddr;
	for(uint256 i = 0; i < length; ++i) {
	   userAddr = EnumerableSet.at(AllIdoUser,i);
	   if(UserBalance[userAddr] != 0) {
		releseAmount = UserBalance[userAddr] * 
		    _ReleaseRatio / RATIO_PRECISION;
		TransferHelper.safeTransfer(KoltAddr, userAddr, releseAmount);
		UserBalance[userAddr] -= releseAmount;
	    }
	}
    }
    
    function koltRelease(address[] memory _addrs, uint256 _ReleaseRatio) 
	external onlyOwner {

	require( _ReleaseRatio <= 10**6,"ReleaseRatio err");
	uint256 length = _addrs.length;
	uint256 releseAmount;
	address userAddr;
	for(uint256 i = 0; i < length; ++i) {
	    if(EnumerableSet.contains(AllIdoUser, _addrs[i])) {
		userAddr = _addrs[i];
		if(UserBalance[userAddr] != 0) {
                releseAmount = UserBalance[userAddr] *
                    _ReleaseRatio / RATIO_PRECISION;
                TransferHelper.safeTransfer(KoltAddr, userAddr, releseAmount);
                UserBalance[userAddr] -= releseAmount;
                }
	    }
	}	
    }

    function usdtWithdraw(address _to, uint256 _amount) external onlyOwner {
	TransferHelper.safeTransfer(UsdtAddr, _to, _amount);
    }
    
    //In case there is kolt that cannot be taken away
    function koltResidueWithdraw(address _to, uint256 _amount) external onlyOwner {
        TransferHelper.safeTransfer(KoltAddr, _to, _amount);	
    }
}
