pragma solidity ^0.5.0;

contract Game {
    //State variables
    address public safeHolder;
    uint public nSecretsSet;
    mapping (address=>uint256) private secretNumber;
    mapping (address=>uint) private playerId;
    string[] public players;
    
    //constructor
    constructor() public {
        //sets the safeHolder as the address creating the contract.
        safeHolder = msg.sender;
        //add address zero player to players[] as a precaution.
        addAPlayer(address(0), "Zero Address");
    }
    
    //Events
    event SecretSet(address player, uint n);
    event PlayerAdded(address player, uint n);
    event ClaimValidated(address from, address about, bool success);
    
    //Modifiers
    modifier safeHolderAction() {
        require(msg.sender == safeHolder, "safeHolderAction");
        _;
    }
    
    modifier allSecretsSet() {
        //Number of players include the zero address also.
        require(players.length == nSecretsSet+1, "Secret collection pending.");
        _;
    }
    
    //Functions
    function addAPlayer(address _player, string memory _name) public safeHolderAction returns (uint) {
        uint id = playerId[_player];
        if(id == 0) {
            playerId[_player] = players.length;
            id = players.length++;
        }
        players[id] = _name;
        emit PlayerAdded(_player, players.length);
        return players.length;
    }
    
    function checkClaim(address player, uint claimedSecret) public allSecretsSet returns (bool) {
        require(playerId[player] != 0, "Invalid player");
        bool success = false;
        
        if (secretNumber[player] == claimedSecret)
            success = true;
            
        emit ClaimValidated(msg.sender, player, success);
        return (success);
    }
    
    function setMySecretNumber(uint _secret) public {
        require(playerId[msg.sender] != 0, "Player not existing");
        secretNumber[msg.sender] = _secret;
        
        emit SecretSet(msg.sender, nSecretsSet);
        
        nSecretsSet++;
    }
}