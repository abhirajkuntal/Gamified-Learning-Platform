// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToken {
    string public name = "IQ Points";
    string public symbol = "IQP";
    uint8 public decimals = 18 ;
    uint256 public totalSupply;

    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _mint(owner, initialSupply);
    }

    function _mint(address to, uint256 value) internal {
        require(to != address(0), "Mint to zero address");
        totalSupply += value;
        balanceOf[to] += value;
        emit Mint(to, value);
        emit Transfer(address(0), to, value);
    }

    function mint(address to, uint256 value) external onlyOwner {
        _mint(to, value);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "Approve to zero address");

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

contract AchievementNFT {
    string public name = "EinsteinNFT";
    string public symbol = "ENFT";
    uint256 public totalSupply;

    address public owner;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256[]) public ownedTokens;
    mapping(uint256 => string) public tokenURI;

    uint256 private _nextTokenId;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Mint(address indexed to, uint256 indexed tokenId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function _mint(address to, string memory _tokenURI) internal returns (uint256) {
        require(to != address(0), "Mint to zero address");

        uint256 tokenId = _nextTokenId;
        ownerOf[tokenId] = to;
        ownedTokens[to].push(tokenId);
        tokenURI[tokenId] = _tokenURI;

        emit Mint(to, tokenId);
        emit Transfer(address(0), to, tokenId);

        _nextTokenId++;
        totalSupply++;
        return tokenId;
    }

    function mint(address to, string memory _tokenURI) external onlyOwner returns (uint256) {
        return _mint(to, _tokenURI);
    }

    
}


interface ILearnToken {
    function mint(address to, uint256 value) external;
}


interface IAchievementNFT {
    function mint(address to, string memory tokenURI) external returns (uint256);
}

contract MilestoneVerifier {
    ILearnToken public learnToken;
    IAchievementNFT public achievementNFT;
    address public owner;

    constructor(address _learnTokenAddress, address _achievementNFTAddress) {
        learnToken = ILearnToken(_learnTokenAddress);
        achievementNFT = IAchievementNFT(_achievementNFTAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    function verifyMilestone(address user, uint256 tokenAmount) external onlyOwner {
        learnToken.mint(user, tokenAmount);
    }

    function verifySignificantMilestone(address user, string memory tokenURI) external onlyOwner {
        achievementNFT.mint(user, tokenURI);
    }
}
