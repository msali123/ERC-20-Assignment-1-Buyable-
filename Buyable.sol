pragma solidity ^0.6.1;
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract MSToken is IERC20 {
    using SafeMath for uint256;

    string public name = "Sameer's Test Tokens"; //A public variable of our Token Name
    string public symbol = "MST"; //A public variable of our Token Symbol
    uint8 public decimals = 18; //A public varable of our Token Decimals(How much can our token can be divisible into)
    uint public price;

    
    //An event declared as per ERC20 Requirments (To view the variables in logs)
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //An event declared as per ERC20 Requirments (To view the variables in logs)
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    //We will be defining the total supply of our token in variable supply
    uint256 private supply;

    //Owner of the contract
    address public owner;

    //This mapping will be responsible to hold  the balances of our accounts.
    mapping(address => uint256) private balances;

    //Mapping having a nested mapping e.g Key:Our Address will call another mapping(Key: from and Value: amount)
    mapping(address => mapping(address => uint256)) public override allowance;

    //Added a constructor that will take the amount of total supply and add that into our global variable
    //3. Owner on creation of token will decide the Value based on ether.
    constructor(uint _price) public {
        owner = msg.sender; //Who ever initiates this contract is the owner
        supply = 10000000 * (10 ** uint256(decimals)); //Assigning supply to a state variable
        balances[owner] = supply; //Adding the Tokens to the address of msg.sender.
        price = _price;
        emit Transfer(address(this),msg.sender,supply);

    }
    
    
  
    //This totalSupply() will be returning the total supply of our token
    function totalSupply() public view override returns (uint256) {
        return supply;
    }

        modifier onlyOwner() {
        require(msg.sender == owner, "Not an Owner");
        _;
        }

    //balanceOf function will take an address that address will be used as key in mapping to return the balance
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    //Transfer function that will take an address _to and value to transfer as _value
    function transfer(address _to, uint256 _value) public override onlyOwner returns (bool success)
    {
        require(balances[msg.sender] >= _value, "Not enough Balance"); //Checking for enough balance
        balances[msg.sender] -= _value; //deducting the _value from msg.sender
        balances[_to] += _value; //adding the given _value to the address to transfer
        emit Transfer(msg.sender, _to, _value); //calling the event Transfer
        return true; //Returning true if things go well
    }

    //This function approve is going to approve the Account B to spend Some Account of Tokens on our behalf
    //E.g. If we list our tokens on an exchange we approve exchange to send/transfer our tokens
    function approve(address _spender, uint256 _value) public override returns (bool success)
    {
        allowance[msg.sender][_spender] = _value; //mapping that will be recording the allowances from our address
        emit Approval(msg.sender, _spender, _value); //Approval event to be subscribed
        return true; //Returning true if things go well
    }

    //Function transferFrom() will allow the B address that recieved TOkens from us to spend the allowance tokens
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success)
    {
        require(balances[_from] >= _value, "Not enough Balance"); //Checking from mapping that the balance of given address is greater than or = to value given.
        require(allowance[_from][msg.sender] >= _value, "Not Approved Amount"); //Checking if the allowance that we gave. _from to function executor is greater or equals to _value

        balances[_from] -= _value; //deducting the given balance/token from the _from address
        balances[_to] += _value; //increasing the given balance/token to the _to address
        allowance[_from][msg.sender] -= _value; //deducting the _value token given to spend from total spending.
        emit Transfer(_from, _to, _value); //calling the event Transfer
        return true; //Returning true if things go well
    }

    //Adding mint functionality to our Token
    function mint(uint256 amount) public onlyOwner returns (uint256) {
        require(amount > 0, "Amount Invalid : Should be greater than 0"); //Checking minting amount > 0
        balances[owner] = balances[owner].add(amount); //Adding the new tokens
        supply = supply.add(amount);
    }
    
 
    //1.Any one can get the token by paying against ether
    function sendToken(address beneficiary) public payable{
        // require(msg.value > 1 ether);
        require(tx.origin == beneficiary); // 5. Limit the buyer that it should be the EOA.
        require(beneficiary != owner);
        uint256 unitsPerWei = (1*10**18)/price; 
        uint256 tokenscalc = msg.value * unitsPerWei; //6, The buyer can buy token even against 1 wei.
        balances[owner] = balances[owner].sub(tokenscalc);
        balances[msg.sender] = balances[msg.sender].add(tokenscalc);
        payable(owner).transfer(msg.value);
        emit Transfer(owner,msg.sender,tokenscalc);
    }
    
    //2. Add fallback payable method to Issue token based on Ether received.
    fallback() external payable{
         sendToken(msg.sender);
    }
    
    //4. There should be an additional method to adjustPrice that allow owner to adjust price.
    function adjustPrice(uint _newPrice) public onlyOwner returns(bool){
        price = _newPrice;
        return true;
    }
}
