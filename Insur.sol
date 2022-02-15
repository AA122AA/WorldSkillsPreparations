// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Insur {
    function getPrice(
        uint256 _carPrice,
        uint256 _catAge,
        uint256 _notPayedFinesAmount,
        uint256 _accidentAmount,
        uint256 _experience
    ) external returns (uint256) {
        uint256 _price = 5; //Тут математика, пока нет времени ее делать
        return _price;
    }
}
