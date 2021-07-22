// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../../utils/math/SafeMath.sol";
import "./ERC20.sol";

contract BuyAndSell1 {
       using SafeMath for uint256; // 

    //1000000000000000000
    mapping(address => uint256) public _buyPriceByEth;
    mapping(address => uint256) public _balanceByEth;
    mapping(address => mapping(address=>uint256)) public _buyPriceByToken;
    // mapping(address => uint256) public _balanceByEth;
    
    address private owner;
    
    modifier isOwner{
        require(msg.sender == owner,"Only owner can do this");
        _;
    }
    
    constructor(){
        owner = msg.sender;
    }
    

    function setBuyPriceEth(address _tokenAddress, uint256 buyPrice) public isOwner {
        _buyPriceByEth[_tokenAddress] = buyPrice;
        ERC20 token = ERC20(_tokenAddress);
        _balanceByEth[_tokenAddress] = token.balanceOf(address(this));
    }
    function setBuyPriceToken(address _tokenAddress,address _usdtAdress, uint256 buyPrice) public isOwner {
        _buyPriceByToken[_tokenAddress][_usdtAdress] = buyPrice;
    }
    
    function buyByEth(address _tokenAddress) public payable returns (bool){
        ERC20 token = ERC20(_tokenAddress);
        require(_buyPriceByEth[_tokenAddress]!=0,"Don't support to buy this token");
        uint256 value = msg.value;
        uint256 _amount = value.div(_buyPriceByEth[_tokenAddress],"Buy price cant be Zero");
        require(_amount > 0,"Too little ether to buy token");
        require(_balanceByEth[_tokenAddress] >= _amount, "Not enough Token to buy");
        bool result = token.transfer(msg.sender,_amount);
        return result;
    }
    function buyByToken(address _tokenAddress,address _usdtAdress,uint256 _amount,address _spender) public payable returns (bool){
        require(_tokenAddress!= address(0),"Token address != 0x0");
        require(_usdtAdress!= address(0),"USDT address != 0x0");
        require(_spender!= address(0),"Spender address != 0x0");
        ERC20 usdt = ERC20(_usdtAdress);

        // Token to send for USDT
        ERC20 token = ERC20(_tokenAddress);
        usdt.transferFrom(_spender, address(this), _amount);
        _amount= _amount.mul(2);
        // Send amount tokens to msg.sender
        token.transfer(msg.sender, _amount);
        return true;
    }
    
    function withDrawToken(address _tokenAddress) isOwner public returns(bool){
        ERC20 token = ERC20(_tokenAddress);
        uint256 _amount = token.balanceOf(address(this));
        bool result = token.transfer(owner,_amount);
        return result;

    }
    function withDrawEth(uint256 _amount) isOwner  public{
        uint256 amountOfContract = address(this).balance;
        require(_amount<=amountOfContract,"Dont have enough Eth to transfer");
        payable(msg.sender).transfer(_amount);
       

    }
    
}