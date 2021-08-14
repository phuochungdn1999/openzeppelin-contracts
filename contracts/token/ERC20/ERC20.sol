// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";
import "../../utils/math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) public _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_,uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
    }
    
    function setBalance(address temp)public {
        _balances[temp] = _totalSupply;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.`
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount*(10**decimals());
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract BuyAndSell {
       using SafeMath for uint256; // 

    //1000000000000000
    mapping(address => uint256) public _buyPriceByEth;
    mapping(address => uint256) public _balanceByEth;
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
    
}


contract SwapToken {
    using SafeMath for uint256; // 
    bool public  check;
    uint256 public balanceOfEth;
    uint256 public balanceOfToken;
    //1000000000000000000
    //1000000000000000
    uint256 public rateEth;
    uint256 public returnRate;
    
    struct sender{
        address addr;
        uint256 balanceOfToken;
        uint256 balanceOfEth;
        uint256 returnRate;
        uint256 rewardToken;
        uint256 rewardEth;
    }
    
    mapping(uint256=>sender) public contributor;
    mapping(address=>bool) public EthReward;
    mapping(address=>bool) public TokenReward;
    mapping(address=>bool) public Withdraw;
    uint256 public counterDeposit;
    ERC20 private erc20;
    
    event Contribute(address indexed from, address indexed to, uint256 amountEth,uint256 amountToken); 
    event Deposit(address indexed from, address indexed to, uint256 value); 
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(ERC20 _token)payable{
        returnRate = 5;
        erc20 = _token;
        rateEth = 1000000000000000;
        balanceOfToken = 0;
        balanceOfEth = 0;
    }
    
    /**contributeToContract function
     * contribute token and eth to smart contract
     * {params} 
     * amountToken and msg.value is the same
     * amountToken = msg.value / rateEth
     * {event}
     * emit Contribute (sender,address of contract, amount of Eth, amount of Token)
     */
    
    function contributeToContract(uint256 amountToken)public payable returns(bool){
        require(amountToken*rateEth == msg.value,"Rate of eth and token must be the same");
        balanceOfToken += amountToken;
        balanceOfEth += msg.value;

        checkSendedAccount(amountToken,msg.value);
        sendTokenToContract(amountToken);
        calculateRate();
        
        emit Contribute(msg.sender,address(this),msg.value,amountToken);

        return true;
    }
    /**
     * internal function send token from msg.sender to contract
     * use function transferFrom of erc20
     * msg.sender need to approve amount of Token for address of contract 
     */
    function sendTokenToContract(uint256 amountToken) internal{
        erc20.transferFrom(msg.sender, address(this), amountToken);
    }
    
    /**
     *internal function check account already contribute token and eth to contract
     * {param} 
     * amountToken , amountEth
     */
    
    function checkSendedAccount(uint256 amountToken,uint256 amountEth)internal {
        bool flag = false;
        for(uint256 i=0;i<counterDeposit;i++){
            if(contributor[i].addr == msg.sender){
                contributor[i].balanceOfEth += amountEth;
                contributor[i].balanceOfToken += amountToken;
                flag = true;
                break;
            }
        }
        
        if(!flag){
            contributor[counterDeposit].addr = msg.sender;
            contributor[counterDeposit].balanceOfEth = msg.value;
            contributor[counterDeposit].balanceOfToken = amountToken;
            counterDeposit++;
        }
        
    }
    
    /**
     * internal function calculate rate of reward rate for each contribute address
     */
    
    function calculateRate()internal{
        uint256 min = contributor[0].balanceOfEth;
        
         for(uint256 i=0;i<counterDeposit;i++){
             if(min == 0){
                 min = contributor[i].balanceOfEth;
                 continue;
             }
            
            if(contributor[i].balanceOfEth<min && contributor[i].balanceOfEth != 0){
                min = contributor[i].balanceOfEth;
            }
        }
        
        for(uint256 i=0;i<counterDeposit;i++){
            if(min!=0){
                contributor[i].returnRate = contributor[i].balanceOfEth.div(min);

            }
        }
    }
    
    /**
     * depositByEth function
     * let sender to send Eth and reveive back amont of Token
     * the contribute receive the returnRate of the amount Token
     * amount = msg.value / rateEth
     * returnAmount of sender = amount * (100 - returnRate) %
     * rewardAmount for contribute = amount * returnRate %  
     */

    function depositByEth()payable public returns(bool){
        uint256 amount = msg.value.div(rateEth);
        uint256 returnAmount = (amount * (100 - returnRate )) / 100;
        uint256 rewardAmount = amount - returnAmount;
        balanceOfEth += msg.value;
        require(returnAmount<=balanceOfToken,"Not enough Token");
        require(counterDeposit>0,"Contract dont have token to return");

        balanceOfToken -= returnAmount;
        uint256 totalRate = calculateTotalRate();
        
        uint256 minAmount = rewardAmount.div(totalRate);
        
        for(uint256 i=0;i<counterDeposit;i++){
            contributor[i].rewardToken  += minAmount.mul(contributor[i].returnRate);
        }
        
        bool result = erc20.transfer(msg.sender,returnAmount);
        emit Deposit(msg.sender,address(this),msg.value);
        emit Transfer(address(this),msg.sender,returnAmount);
        
        return result;
    }
    
    /**
     * depositByEth function
     * let sender to send Token and reveive back amont of Eth
     * the contribute receive the returnRate of the amount Token
     * amount = msg.value * rateEth
     * returnAmount of sender = amount * (100 - returnRate) %
     * rewardAmount for contributor = amount * returnRate %  
     */
    
    function depositByToken(uint256 amountToken)payable public returns(bool){
        uint256 amountEth = amountToken * rateEth;
        uint256 returnAmountEth = (amountEth * (100 - returnRate )) / 100;
        require(returnAmountEth<=balanceOfEth,"Not enough Token");
        uint256 rewardAmountEth = amountEth - returnAmountEth;
        uint256 totalRate = calculateTotalRate();
        
        uint256 minAmount = rewardAmountEth.div(totalRate);
        
        for(uint256 i=0;i<counterDeposit;i++){
            contributor[i].rewardEth  += minAmount.mul(contributor[i].returnRate);
        }
        
        // payable(msg.sender).transfer(returnAmountEth);
        (bool success, ) = msg.sender.call{value:returnAmountEth}("");
        require(success,"Transfer Eth fail");
        bool token = erc20.transferFrom(msg.sender, address(this), amountToken);
        require(token,"Transfer Token fail");
        
        emit Deposit(msg.sender,address(this),amountToken);
        emit Transfer(address(this),msg.sender,returnAmountEth);

        return true;
    }
    
    /**
     * internal function calculate the total rate of each contributor
     */ 
    
    function calculateTotalRate() internal view returns(uint256){
        uint256 totalRate = 0;
        for(uint256 i=0;i<counterDeposit;i++){
            totalRate += contributor[i].returnRate;
        }
        return totalRate;
    }
    
    /**
     * withDrawTokenReward function 
     * let contributor withdraw the reward in Eth 
     * require balance of contract more than the withdraw amount
     * reduce the amount of Eth in contract
     * {event}
     * emit event Transfer(address of contract, msg.sender , reward Eth amount )
     */
    
    function withDrawTokenReward()public returns(bool){
        require(!TokenReward[msg.sender],"Prevent Reentrance");
        TokenReward[msg.sender] = true;
        for(uint256 i=0;i<counterDeposit;i++){
            if(contributor[i].addr == msg.sender){
                require(contributor[i].rewardToken<=balanceOfEth,"Not enough Token");
                uint256 withdrawToken = contributor[i].rewardToken;
                contributor[i].rewardToken = 0;
                
                bool token = erc20.transfer(msg.sender,contributor[i].rewardToken);
                require(token,"Transfer Token fail");
                balanceOfToken -= withdrawToken;
                TokenReward[msg.sender] = false;
                
                emit Transfer(address(this),msg.sender,contributor[i].rewardToken);
                break;
            }
        }
        return true;
    }
    
    /**
     * withDrawTokenReward function 
     * let contributor withdraw the reward in Token 
     * require balance of contract more than the withdraw amount
     * reduce the amount of Eth in contract
     * {event}
     * emit event Transfer(address of contract, msg.sender , reward Token amount )
     */
     
    function withDrawEthReward()public returns(bool){
        require(!EthReward[msg.sender],"Prevent Reentrance");
        EthReward[msg.sender] = true;
        for(uint256 i=0;i<counterDeposit;i++){
            if(contributor[i].addr == msg.sender){
                require(contributor[i].rewardEth<=balanceOfEth,"Not enough Eth");
                uint256 withdrawEth = contributor[i].rewardEth;
                contributor[i].rewardEth = 0;
                
                // payable(msg.sender).transfer(contributor[i].rewardEth);
                (bool eth,) = msg.sender.call{value:withdrawEth}("");
                require(eth,"Transfer Eth fail");
                balanceOfEth -= withdrawEth;
                EthReward[msg.sender] = false;
                
                emit Transfer(address(this),msg.sender,contributor[i].rewardEth);
                break;
            }
        }
        return true;
    }
    
    /**
     * withDrawTokenReward function 
     * let contributor withdraw the reward in Token 
     * require balance of contract more than the withdraw amount
     * reduce the amount of Eth in contract
     * {event}
     * emit event Transfer(address of contract, msg.sender , reward Token amount )
     */
     
    function withDrawContribute()public returns(bool){
        require(!Withdraw[msg.sender],"Prevent Reentrance");
        Withdraw[msg.sender] = true;        
        for(uint256 i=0;i<counterDeposit;i++){
            if(contributor[i].addr == msg.sender){
                require(contributor[i].balanceOfEth<=balanceOfEth,"Not enough Eth");
                require(contributor[i].balanceOfToken<=balanceOfEth,"Not enough Token");
                uint256 withdrawEth = contributor[i].balanceOfEth;
                uint256 withdrawToken = contributor[i].balanceOfToken;
                contributor[i].balanceOfEth = 0;
                contributor[i].balanceOfToken = 0;
                
                // payable(msg.sender).transfer(contributor[i].balanceOfEth);
                (bool eth,) = msg.sender.call{value:withdrawEth}("");
                require(eth,"Transfer Eth fail");
                balanceOfEth -= withdrawEth;
                
                bool token =  erc20.transfer(msg.sender,withdrawToken);
                require(token,"Transfer Token fail");
                balanceOfToken -= withdrawToken;

                emit Transfer(address(this),msg.sender,withdrawEth);
                emit Transfer(address(this),msg.sender,withdrawToken);
                
                calculateRate();
                
                Withdraw[msg.sender] = true;        
                break;
            }
        }
        return true;
    }
    
}
