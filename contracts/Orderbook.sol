// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Orderbook{
    using SafeMath for uint256;
    event BuyAdded(
 uint indexed Order_No,
 uint Amt,
 uint Price,
 address trader
 );

event SellAdded(
 uint indexed Order_No,
 uint Amt,
 uint Price,
 address trader
 );

event TradeAdd(
 uint indexed Order_No,
 uint Amt,
 uint Price,
 address maker,
 address taker
 );

    struct Order{
        uint amount;
        uint price;
        uint timeStamp;
        address trader;
        bytes2 status;
    }

    Order[] buys;
    Order[] sells;

    ERC20 public erc20Base;
    ERC20 public erc20Counter;

    address owner;

    modifier onlyOwner(){
        require(msg.sender != owner , "you are not the owner of contract");
        _;
    }

    constructor(address base, address counter){
        erc20Base = ERC20(base);
        erc20Counter = ERC20(counter);
    }


    function addBuy(uint amt, uint buyPrice) public returns(uint) {
        erc20Base.transferFrom(msg.sender,address(this), amt.mul(buyPrice));
        buys.push(Order(amt,buyPrice,block.timestamp,msg.sender,'A'));
        emit BuyAdded(buys.length, amt, buyPrice, msg.sender);
        return buys.length;
    }

    function addSell(uint amt, uint sellPrice) public returns(uint){
        erc20Counter.transferFrom(msg.sender, address(this), amt);
        sells.push(Order(amt,sellPrice,block.timestamp,msg.sender,'A'));
        emit SellAdded(sells.length, amt, sellPrice, msg.sender);
        return sells.length;
    }

    function viewLengthBuy() public view returns (uint) 
        {
        return buys.length;
        }

    function viewLengthSell() public view returns (uint) 
        {
        return sells.length;
        }

        

    function viewBuy(uint OrderNo) public view returns (uint,uint,uint, address) {
        uint index = OrderNo.sub(1);
        return ( buys[index].price, buys[index].timeStamp,buys[index].amount,buys[index].trader);
    }

    function viewSell(uint OrderNo) public view returns (uint,uint,uint, address) {
        uint index = OrderNo.sub(1);
        return (sells[index].price, sells[index].timeStamp,sells[index].amount,sells[index].trader);
    }

    function trade(uint OrderNo, uint Amt, uint TradePrice, uint trade_type) public returns ( uint, uint , address) {
        if (trade_type == 1 && sells[OrderNo-1].amount == Amt)
            {
            require(TradePrice >= sells[OrderNo-1].price, "Invalid Price");
            erc20Base.transferFrom(msg.sender, sells[OrderNo-1].trader,Amt.mul(sells[OrderNo-1].price));
            sells[OrderNo-1].amount = 0;
            sells[OrderNo-1].status = 'T';
            erc20Counter.transfer(msg.sender, Amt);
            emit TradeAdd(OrderNo, Amt,sells[OrderNo-1].price,sells[OrderNo-1].trader,msg.sender);
            return ( 
            OrderNo,
            Amt,
            msg.sender
            );
         }else if (trade_type == 1 && sells[OrderNo-1].amount > Amt)
            {
            erc20Base.transferFrom(msg.sender, sells[OrderNo-1].trader,Amt.mul(sells[OrderNo-1].price));
            require(TradePrice >= sells[OrderNo-1].price, "Invalid Price");
            sells[OrderNo-1].amount = sells[OrderNo-1].amount - Amt;
            sells[OrderNo-1].status = 'A';
            erc20Counter.transfer(msg.sender, Amt);
            emit TradeAdd(OrderNo, Amt,sells[OrderNo-1].price,sells[OrderNo-1].trader,msg.sender);
            return ( 
            OrderNo,
            Amt,
            msg.sender
            ); 
            }
    }
            function decommission() public onlyOwner
            {
            uint i = 0;
            while ( i <= buys.length || i <= sells.length)
            {
            if( i <= buys.length)
            {
            uint Amt = buys[i].amount;
            Amt = Amt.mul(buys[i].price);
            erc20Base.transfer(buys[i].trader,Amt);
            delete buys[i];
            }
            
            if( i <= sells.length)
            {
            erc20Counter.transfer(sells[i].trader,sells[i].amount);
            delete sells[i];
            }
            i++;
            }
            }

}