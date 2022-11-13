// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// make an interface to store which user has granted permissions to other users to use their amounts and how much
interface tokenRecipient {
    function receiveApproval(
        address from,
        uint256 amount,
        address token,
        bytes calldata extradata
    ) external;
}

contract ManualToken {
    // Public versions of token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // balance to store amount possesed by individual
    mapping(address => uint256) public balance;

    // allowance data structure maps the user-A(from which accounts amount has to send) to user-B(which he gives permission to) with amount(the user specifies how much amount user-B can spend on its behalf)
    mapping(address => mapping(address => uint256)) public allowance;

    // Events  -> indexed params are basically filters that we can use to search events by in blockchain

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address spender, uint256 amount);
    event Burn(address indexed from, uint256 value);

    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10**uint256(decimals);
        // owner of the content has all the tokens
        balance[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    /**
     * Main transfer function(Internal) that updates the accounts/or data structure
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        // the transfer shoould be only to valid addresses
        require(to != address(0x0));
        // sender should have enough balance
        require(balance[from] >= amount);
        // check for overflow condition or we can say the amount should be in positive value
        require(balance[to] + amount >= balance[to]);
        // saving prev balances for assertion check
        uint256 prevBalances = balance[from] + balance[to];
        // update the data structures/ do transfer
        balance[from] = balance[from] - amount;
        balance[to] += amount;
        //emit an event after the amount gets transferred successfully
        emit Transfer(from, to, amount);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balance[from] + balance[to] == prevBalances);
    }

    /**
     * function acting upon the UI transfer operation
     * transfers the funds of the user interacting with UI
     */
    function transfer(address to, uint256 amount)
        public
        returns (bool success)
    {
        // call internal/main transfer function with from as user
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * function to send amount on behalf of someone else
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool success) {
        // check whether user-B(msg.sender) has enough balance to spend in behalf of user-A(from)
        require(amount <= allowance[from][msg.sender]);
        // update allowance data structure
        allowance[from][msg.sender] -= amount;
        // call transfer function(for main accounts)
        _transfer(from, to, amount);
        return true;
    }

    /**
     * function to set allowance (who the user wants to set as spender and by what amount)
     */

    function approve(address spender, uint256 amount)
        public
        returns (bool success)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * function to set interface about which user is granting access to other user and how much
     */
    function approveAndCall(
        address spender,
        uint256 amount,
        bytes memory extradata
    ) public returns (bool success) {
        // make spender to be of tokenrecipient data type
        tokenRecipient _spender = tokenRecipient(spender);
        // if everything goes well(note -> approve function should be given address type spender)
        if (approve(spender, amount)) {
            // now through spender we can call tokenrecipient interface
            _spender.receiveApproval(
                msg.sender,
                amount,
                address(this),
                extradata
            );
            return true;
        }
    }

    /**
     * function to burn token (by user)
     */

    function burn(uint256 amount) public returns (bool success) {
        //the burn anmount should be less than or equal to current amount
        require(balance[msg.sender] >= amount);
        // update the data structure/account
        balance[msg.sender] -= amount;
        // deduct the total supply of tokens in the contract as they have been burned
        totalSupply -= amount;
        emit Burn(msg.sender, amount);
        return true;
    }

    /**
     * function to burn tokens in behalf of other user
     */
    function burnFrom(address from, uint256 amount)
        public
        returns (bool success)
    {
        // the from(user-B) should have enough amount to burn
        require(balance[from] >= amount);
        // user-A should have access/permission to burn the given anount of token in behalf of user-A(from)
        require(allowance[from][msg.sender] >= amount);
        // update the respective data structures
        balance[from] -= amount;
        allowance[from][msg.sender] -= amount;
        // deduct the total supply of tokens in the contract as they have been burned
        totalSupply -= amount;
        emit Burn(from, amount);
        return true;
    }
}
