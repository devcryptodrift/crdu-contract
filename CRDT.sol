// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Contract {
    function sendPublicSalePhase1(address recipient, uint256 amount) external returns (bool);
    function sendPublicSalePhase2(address recipient, uint256 amount) external returns (bool);
}

contract Test_CRDT_Presale_V1 is AccessControl {

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address public tokenContractAddress; 
    IERC20 public busdContract;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
    }

    uint256 public phase1Supply = 20000000 * 1 ether; 
    uint256 public phase2Supply = 40000000 * 1 ether;

    uint256 public phase1MinimumBUSDPurchase = 30 * 1 ether;
    uint256 public phase1MaximumBUSDPurchase = 2000 * 1 ether; 
    uint256 public phase2MinimumBUSDPurchase = 45 * 1 ether;
    uint256 public phase2MaximumBUSDPurchase = 3000 * 1 ether; 

    uint256 public phase1MinimumBNBPurchase = .105 * 1 ether;
    uint256 public phase1MaximumBNBPurchase = 7 * 1 ether; 
    uint256 public phase2MinimumBNBPurchase = .25 * 1 ether;
    uint256 public phase2MaximumBNBPurchase = 10 * 1 ether; 

    uint256 public phase1TokenValuePerBUSD = 50;
    uint256 public phase2TokenValuePerBUSD = 33;

    uint256 public phase1TokenValuePerBNB = 14286;
    uint256 public phase2TokenValuePerBNB = 10000;

    bool public phase1Status = true;
    bool public phase2Status = true;

    uint256 public phase1TotalBUSDPurchased;
    uint256 public phase2TotalBUSDPurchased;
    uint256 public phase1TotalBNBPurchased;
    uint256 public phase2TotalBNBPurchased;

    mapping(address => uint256) public phase1AddressesBUSDPurchased; 
    mapping(address => uint256) public phase2AddressesBUSDPurchased; 

    mapping(address => uint256) public phase1AddressesBNBPurchased;
    mapping(address => uint256) public phase2AddressesBNBPurchased;

    mapping(address => uint256) public phase1AddressesTotalTokenPurchased;
    mapping(address => uint256) public phase2AddressesTotalTokenPurchased;

    event Purchased(address _wallet, uint256 _value, uint256 isBNB);

    function purchaseBNBPhase1() external payable{
        require(phase1Status, "Presale is not yet open!");
        require(msg.value >= phase1MinimumBNBPurchase,"Minimum purchase required");
        require(msg.value <= phase1MaximumBNBPurchase,"Maximum purchase required");
        
        uint256 tokenValue = (msg.value * phase1TokenValuePerBNB);

        require((phase1Supply - tokenValue)  >= 0, "Insufficient supply");  
           
        phase1TotalBNBPurchased = phase1TotalBNBPurchased + msg.value;
        phase1AddressesBNBPurchased[msg.sender] = phase1AddressesBNBPurchased[msg.sender] + msg.value;
        phase1AddressesTotalTokenPurchased[msg.sender] = phase1AddressesTotalTokenPurchased[msg.sender] + tokenValue;
        phase1Supply = phase1Supply - tokenValue;

        Contract _contract = Contract(tokenContractAddress);
        _contract.sendPublicSalePhase1(msg.sender, tokenValue);

        emit Purchased(msg.sender,tokenValue,1);
    }

    function purchaseBNBPhase2() external payable{
        require(phase2Status, "Presale is not yet open!");
        require(msg.value >= phase2MinimumBNBPurchase,"Minimum purchase required");
        require(msg.value <= phase2MaximumBNBPurchase,"Maximum purchase required");
        
        uint256 tokenValue = (msg.value * phase2TokenValuePerBNB);

        require((phase2Supply - tokenValue)  >= 0, "Insufficient supply");  
           
        phase2TotalBNBPurchased = phase2TotalBNBPurchased + msg.value;
        phase2AddressesBNBPurchased[msg.sender] = phase2AddressesBNBPurchased[msg.sender] + msg.value;
        phase2AddressesTotalTokenPurchased[msg.sender] = phase2AddressesTotalTokenPurchased[msg.sender] + tokenValue;
        phase2Supply = phase2Supply - tokenValue;

        Contract _contract = Contract(tokenContractAddress);
        _contract.sendPublicSalePhase2(msg.sender, tokenValue);

        emit Purchased(msg.sender,tokenValue,1);
    }


    function purchaseBUSDPhase1(uint256 amount) external {
        require(phase1Status, "Presale is not yet open!");
        require(amount >= phase1MinimumBUSDPurchase,"Minimum purchase required!");
        require(amount <= phase1MaximumBUSDPurchase,"Maximum purchase required");
        
        uint256 tokenValue = (amount * phase1TokenValuePerBUSD);
        require(busdContract.balanceOf(msg.sender) >= amount, "Not Enough BUSD Balance");     
        require((phase1Supply - tokenValue)  >= 0, "Insufficient supply");  
           
        phase1TotalBUSDPurchased = phase1TotalBUSDPurchased + amount;
        phase1AddressesBUSDPurchased[msg.sender] = phase1AddressesBUSDPurchased[msg.sender] + amount;
        phase1AddressesTotalTokenPurchased[msg.sender] = phase1AddressesTotalTokenPurchased[msg.sender] + tokenValue;
        phase1Supply = phase1Supply - tokenValue;

        busdContract.transferFrom(msg.sender,address(this), amount);

        Contract _contract = Contract(tokenContractAddress);
        _contract.sendPublicSalePhase1(msg.sender, tokenValue);

        emit Purchased(msg.sender,tokenValue,0);
    }

    function purchaseBUSDPhase2(uint256 amount) external {
        require(phase2Status, "Presale is not yet open!");
        require(amount >= phase2MinimumBUSDPurchase,"Minimum purchase required!");
        require(amount <= phase2MaximumBUSDPurchase,"Maximum purchase required");
        
        uint256 tokenValue = (amount * phase2TokenValuePerBUSD);
        require(busdContract.balanceOf(msg.sender) >= amount, "Not Enough BUSD Balance");     
        require((phase2Supply - tokenValue)  >= 0, "Insufficient supply");  
           
        phase2TotalBUSDPurchased = phase2TotalBUSDPurchased + amount;
        phase2AddressesBUSDPurchased[msg.sender] = phase2AddressesBUSDPurchased[msg.sender] + amount;
        phase2AddressesTotalTokenPurchased[msg.sender] = phase2AddressesTotalTokenPurchased[msg.sender] + tokenValue;
        phase2Supply = phase2Supply - tokenValue;

        busdContract.transferFrom(msg.sender,address(this), amount);
        
        Contract _contract = Contract(tokenContractAddress);
        _contract.sendPublicSalePhase2(msg.sender, tokenValue);

        emit Purchased(msg.sender,tokenValue,0);
    }

    function setTokenContract(address _contract) external onlyRole(DEFAULT_ADMIN_ROLE) {
       tokenContractAddress = _contract;
    }

    function setBUSDContract(address _contract) external onlyRole(DEFAULT_ADMIN_ROLE){
       busdContract = IERC20(_contract);
    }

    function setPhase1MinimumBUSDPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase1MinimumBUSDPurchase = amount;
    }
    function setPhase1MaximumBUSDPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase1MaximumBUSDPurchase = amount;
    }
    function setPhase1MinimumBNBPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase1MinimumBNBPurchase = amount;
    }
    function setPhase1MaximumBNBPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase1MaximumBNBPurchase = amount;
    }
    function setPhase2MinimumBUSDPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase2MinimumBUSDPurchase = amount;
    }
    function setPhase2MaximumBUSDPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase2MaximumBUSDPurchase = amount;
    }
    function setPhase2MinimumBNBPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase2MinimumBNBPurchase = amount;
    }
    function setPhase2MaximumBNBPurchase(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase2MaximumBNBPurchase = amount;
    }

    function setPhase1TokenValuePerBUSD(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase1TokenValuePerBUSD = amount;
    }
    function setPhase2TokenValuePerBUSD(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase2TokenValuePerBUSD = amount;
    }

    function setPhase1TokenValuePerBNB(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase1TokenValuePerBNB = amount;
    }
    function setPhase2TokenValuePerBNB(uint256 amount)  external onlyRole(DEFAULT_ADMIN_ROLE){
        phase2TokenValuePerBNB = amount;
    }

    function setPhase1Status() external onlyRole(DEFAULT_ADMIN_ROLE){
        phase1Status = !phase1Status;
    }
    function setPhase2Status() external onlyRole(DEFAULT_ADMIN_ROLE){
        phase2Status = !phase2Status;
    }

    function withdrawBNB(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE){
        payable(msg.sender).transfer(amount);
    }
    function withdrawBNBAll() external onlyRole(DEFAULT_ADMIN_ROLE){
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawBUSD(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        busdContract.transfer(msg.sender,amount);
    }
    function withdrawBUSDAll() external onlyRole(DEFAULT_ADMIN_ROLE) {
        busdContract.transfer(msg.sender,busdContract.balanceOf(address(this)));
    }
}
