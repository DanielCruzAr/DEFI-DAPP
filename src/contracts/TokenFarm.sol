// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./JamToken.sol";
import "./StellartToken.sol";

contract TokenFarm {
    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    string public name = "Stellart Token Farm";
    address public owner;
    JamToken public jamToken;
    StellartToken public stellartToken;

    /**
     * @dev Sets the values for {jamToken}, {stellartToken} and {owner}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(StellartToken _stellartToken, JamToken _jamToken) {
        stellartToken = _stellartToken;
        jamToken = _jamToken;
        owner = msg.sender;
    }

    /**
     * @dev Tokens stake.
     * Transfers JAM tokens from msg.sender to the main Smart Contract.
     * Updates staking balance.
     * Saves staker if it hasn't staked before.
     * Updates staker's state.
     *
     * Requirements:
     *  - _amount must be > 0
     */
    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "La cantidad no puede ser menor a 0");
        jamToken.transferFrom(msg.sender, address(this), _amount);
        stakingBalance[msg.sender] += _amount;
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    /**
     * @dev Remove token Staking.
     * Staked JAM tokens are transfered back to the user.
     * User's staking balance is reset.
     * Updates staker's state.
     *
     * Requirements:
     *  - msg.sender balance must be greather than 0
     */
    function unstakeTokens() public {
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, "El balance del staking es 0");
        jamToken.transfer(msg.sender, balance);
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    /**
     * @dev Token emission (reward). Gives tokens to all stakers.
     *
     * Requirements:
     *  - msg.sender must be the owner
     */
    function issueTokens() public {
        require(msg.sender == owner, "No eres el owner");
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];
            if (balance > 0) {
                stellartToken.transfer(recipient, balance);
            }
        }
    }
}
