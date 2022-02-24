// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;

contract Insur {
    address insurAddr;
    event receiveMoney(address sender, uint amount);

    receive() external payable{
        emit receiveMoney(msg.sender, msg.value);
    }
    
}
