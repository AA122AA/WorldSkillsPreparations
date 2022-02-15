// SPDX-License-Identifier:MIT
pragma solidity 0.8.11;

contract Bank {
    address insurAddr;
    event sendMoney(address sender, uint256 amount);
    event receiveMoney(address sender, uint256 amount);

    function giveMoneyInsur(uint256 _value) external {
        payable(insurAddr).transfer(_value);
        emit sendMoney(insurAddr, _value);
    }

    function bb() external payable {
        emit receiveMoney(msg.sender, msg.value);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
