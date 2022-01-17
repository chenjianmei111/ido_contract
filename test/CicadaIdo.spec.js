const chai = require("chai");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);

describe("CicadaIdo test", function () {

    it("deploy", async function () {
	const CicadaIdo = await ethers.getContractFactory("CicadaIdo");
	this.CicadaIdo = await CicadaIdo.deploy();
    });

    it("check init config", async function () {
	this.SellTotal = await this.CicadaIdo.SellTotal();
	this.SingleBuyHighest = await this.CicadaIdo.SingleBuyHighest();
	this.SingleBuyLowest = await this.CicadaIdo.SingleBuyLowest();
	this.IdoStartTs = await this.CicadaIdo.IdoStartTs();
	this.IdoEndTs = await this.CicadaIdo.IdoEndTs();
	this.WhitelistEndTs = await this.CicadaIdo.WhitelistEndTs();
	this.BuySinglePrice = await this.CicadaIdo.BuySinglePrice();
	this.FirstReleaseRatio = await this.CicadaIdo.FirstReleaseRatio();
	var reSellTotal, reSingleBuyHighest,reSingleBuyLowest, reIdoStartTs,
            reIdoEndTs, reWhitelistEndTs,reBuySinglePrice, reFirstReleaseRatio = await this.CicadaIdo.getAllConfig();
	if(this.SellTotal != reSellTotal) return
	if(this.SingleBuyHighest != reSingleBuyHighest) return
	if(this.SingleBuyLowest != reSingleBuyLowest) return
	if(this.IdoStartTs != reIdoStartTs) return
	if(this.IdoEndTs != reIdoEndTs) return
	if(this.BuySinglePrice != reBuySinglePrice) return
	if(this.FirstReleaseRatio != reFirstReleaseRatio) return
    });

    it("test config interface", async function () {
	const accounts = await ethers.getSigners();
	var add = new Array(accounts[0].address, accounts[1].address, accounts[2].address, 
	    accounts[3].address, accounts[4].address);
	await this.CicadaIdo.connect(accounts[0]).addWhitelist(add);
	this.list = await this.CicadaIdo.getWhitelist();
	expect(this.list.length).to.equal(5);

	if(!this.CicadaIdo.isWhitelistUser(accounts[4].address)) return
	var del = new Array(accounts[0].address, accounts[1].address, accounts[2].address);
	await this.CicadaIdo.connect(accounts[0]).delWhitelist(del);
	this.list = await this.CicadaIdo.getWhitelist();
	expect(this.list.length).to.equal(2);
	if(this.CicadaIdo.isWhitelistUser(accounts[4].address)) return
	
	kolt = await this.CicadaIdo.getKoltAmount(666n);
	expect(kolt).to.equal(666n);

	ReleaseKolt = await this.CicadaIdo.getReleaseFirst(666n);
	expect(ReleaseKolt).to.equal(333n);
    });

    it("test Ido", async function () {
	this.SellTotal = await this.CicadaIdo.SellTotal();
        this.SingleBuyHighest = await this.CicadaIdo.SingleBuyHighest();
        this.SingleBuyLowest = await this.CicadaIdo.SingleBuyLowest();

	const accounts = await ethers.getSigners();
	var add = new Array(accounts[6].address, accounts[7].address, accounts[8].address);
	await this.CicadaIdo.connect(accounts[0]).addWhitelist(add);
    	await expect(
	    this.CicadaIdo.connect(accounts[9]).BuyKolt(1000)
	).to.be.revertedWith('not Whitelist User');
	await expect(
	    this.CicadaIdo.connect(accounts[8]).BuyKolt(this.SingleBuyLowest - 10)
	).to.be.revertedWith('Less than min amount');
	await expect(
	    this.CicadaIdo.connect(accounts[8]).BuyKolt(this.SingleBuyHighest + 10)
	).to.be.revertedWith('More than max amount');

	await this.CicadaIdo.connect(accounts[8]).BuyKolt(1000n);
	//await this.CicadaIdo.connect(accounts[0]).koltRelease(1000000n);
    });
});
