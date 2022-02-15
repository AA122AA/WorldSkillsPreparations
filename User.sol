// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// import "./Insur.sol" as Insur;
contract Bank {
    address insurAddr;
    event sendMoney(address sender, uint256 amount);
    event receiveMoney(address sender, uint256 amount);
    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function giveMoneyInsur(uint256 _value) external {
        require(insurAddr == msg.sender, "You have no permision");
        require(address(this).balance >= _value, "no money in bank");
        payable(insurAddr).transfer(_value);
        emit sendMoney(insurAddr, _value);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract Insur {
    uint256 debt = 0;
    Bank b;
    address payable constant bankAddr =
        payable(0xD9eaa853bBCCcf5CB0A49241A7F69d743f3cf049);

    address userAddr = payable(0xD9eaa853bBCCcf5CB0A49241A7F69d743f3cf049);

    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function getPrice(
        uint256 _carPrice,
        uint256 _catAge,
        uint256 _notPayedFinesAmount,
        uint256 _accidentAmount,
        uint256 _experience
    ) external pure returns (uint256) {
        uint256 _price = 5; //Тут математика, пока нет времени ее делать
        return _price;
    }

    function takeMoney(uint256 _price) external {
        // Может вызываться только с контракта User
        if (debt != 0) {
            if (debt > _price) {
                debt -= _price;
                bankAddr.transfer(msg.value);
            } else if (debt <= msg.value) {
                bankAddr.transfer(debt);
                debt = 0;
            }
        }
    }

    function giveMoney(uint256 _amount) external {
        require(msg.sender == userAddr);
        uint256 _a = _amount * 10;
        uint256 _debt = _a - address(this).balance;
        if (_a > address(this).balance) {
            b.giveMoneyInsur(_debt);
            debt += _debt;
        }
        payable(msg.sender).transfer(_a);
    }
}

contract User {
    struct DrivingLicence {
        string number;
        uint256 validity;
        string category;
    }

    struct User_str {
        address userAddr;
        string FIO;
        DrivingLicence dl;
        uint256 startDrive;
        uint256 accidentAmount;
        uint256[] notPayedFines; //Хранит timestamp когда появился штраф
        uint256 insuranceFee;
        uint256 balance;
        bool isDPS;
    }

    struct Car_str {
        string category;
        uint256 price;
        uint256 age;
    }

    User_str[] usersArr;

    mapping(address => uint256) userIndexMap;
    mapping(address => Car_str) usersCar;
    mapping(string => DrivingLicence) drivingLicencePool;

    Insur ins;
    uint256 usersCount = 0;
    uint256 date;
    address payable constant bank =
        payable(0xD9eaa853bBCCcf5CB0A49241A7F69d743f3cf049);
    address payable constant insurance =
        payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    // ["000",1649538000,"C"],["111",1655586000,"B"],["222",1661979600,"D"],["333",1663794000,"C"],["444",1653166800,"B"],["555",1779397200,"E"],["666",1646859600,"B"] - так передаются таплы
    constructor(
        DrivingLicence memory _dl0,
        DrivingLicence memory _dl1,
        DrivingLicence memory _dl2,
        DrivingLicence memory _dl3,
        DrivingLicence memory _dl4,
        DrivingLicence memory _dl5,
        DrivingLicence memory _dl6,
        // деплоим все 3 контракта, затем получем их адреса и создаем еще один контракт, котоырй хранит их адреса
        address ins,
        address bank
    ) {
        drivingLicencePool[_dl0.number] = _dl0;
        drivingLicencePool[_dl1.number] = _dl1;
        drivingLicencePool[_dl2.number] = _dl2;
        drivingLicencePool[_dl3.number] = _dl3;
        drivingLicencePool[_dl4.number] = _dl4;
        drivingLicencePool[_dl5.number] = _dl5;
        drivingLicencePool[_dl6.number] = _dl6;
        date = block.timestamp;
    }

    modifier dlCheck(
        string memory _number,
        uint256 _validity,
        string memory _category
    ) {
        require(
            drivingLicencePool[_number].validity == _validity,
            "wrong validity"
        );
        require(
            keccak256(bytes(drivingLicencePool[_number].category)) ==
                keccak256(bytes(_category)),
            "wrong category"
        );
        _;
    }
    modifier isDPS() {
        User_str memory _DPS = usersArr[userIndexMap[msg.sender]];
        require(_DPS.isDPS == true, "You are not DPS");
        _;
    }

    function createUser(string memory _FIO, uint256 _startDrive) public {
        uint256[] memory a;
        User_str memory _user = User_str(
            msg.sender,
            _FIO,
            DrivingLicence("0", 0, "0"),
            _startDrive,
            0,
            a,
            0,
            0,
            false
        );
        usersArr.push(_user); //выпилить массив пользователей. Сделать mapping(address => User_str). Возможно сделать массив с адресами
        userIndexMap[msg.sender] = usersCount;
        usersCount += 1;
    }

    function popolnitbalans() external payable {
        // попоняем баланс пользователя msg.sender и msg.value usermap[msg.sender].balance +=msg.value
    }

    function createUser(
        User_str memory _user // ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "00", ["000", 2, "C"], 5, 0, 0, 6, 4, true] - такое надо передавать чтоб создавать юзера.
    ) public dlCheck(_user.dl.number, _user.dl.validity, _user.dl.category) {
        // разрешить использовать эту функцию только адимину.
        usersArr.push(_user);
        userIndexMap[msg.sender] = usersCount;
        usersCount += 1;
    }

    function setDrivingLicence(
        string memory _number,
        uint256 _validity,
        string memory _category
    ) public dlCheck(_number, _validity, _category) {
        DrivingLicence memory _dl = DrivingLicence(
            _number,
            _validity,
            _category
        );
        uint256 index = userIndexMap[msg.sender];
        usersArr[index].dl = _dl;
    }

    function registerCar(
        string memory _carCategory,
        uint256 _price,
        uint256 _age
    ) public {
        require(
            keccak256(bytes(usersArr[userIndexMap[msg.sender]].dl.category)) ==
                keccak256(bytes(_carCategory)),
            "wrong category"
        );
        usersCar[msg.sender] = Car_str(_carCategory, _price, _age);
    }

    function dlProlongation() public {
        User_str memory _user = usersArr[userIndexMap[msg.sender]];
        require(
            _user.dl.validity >= block.timestamp + 30 * 1 days,
            "Your driving licence are expiring in less then month. You can not prolongate them through this portal. Please visit police station"
        );
        require(_user.notPayedFines.length == 0, "Pay your fines dude");
        usersArr[userIndexMap[msg.sender]].dl.validity += 365 * 1 days;
    }

    function checkFinesAmount() public view returns (uint256) {
        return usersArr[userIndexMap[msg.sender]].notPayedFines.length;
    }

    function finePayment(uint256 _finesToPay) public payable {
        uint256[] memory _arr = usersArr[userIndexMap[msg.sender]]
            .notPayedFines;
        uint256 _len = _arr.length;
        require(_len != 0, "All fines are payed");
        require(
            _len >= _finesToPay,
            "You got less fines, use checkFinesAmount to know exact number"
        );
        for (uint256 index = 0; index < _finesToPay; index++) {
            if (_arr[_len - 1 - index] + 25 seconds > block.timestamp) {
                bank.transfer(5 ether);
                usersArr[userIndexMap[msg.sender]].balance -= 5 ether;
            } else {
                bank.transfer(10 ether);
                usersArr[userIndexMap[msg.sender]].balance -= 10 ether;
            }
            usersArr[userIndexMap[msg.sender]].notPayedFines.pop();
        }
    }

    function formInsPrice() public view returns (uint256) {
        // проверку на то, что у пользователя есть машины
        User_str memory _user = usersArr[userIndexMap[msg.sender]];
        Car_str memory _usersCar = usersCar[msg.sender];
        uint256 _exp = (block.timestamp - _user.startDrive) / (365 * 1 days);
        uint256 _price = ins.getPrice(
            _usersCar.price,
            _usersCar.age,
            _user.notPayedFines.length,
            _user.accidentAmount,
            _exp
        );
        //добавить стоимость в пользователя
        return _price;
    }

    function payForIns() public {
        uint256 _price = getInsPrice();
        require(usersmap[msg.sender].balance >= _price);
        payable(ins).transfer(_price); // переделать на call https://docs.soliditylang.org/en/latest/contracts.html?highlight=call#fallback-function
        ins.takeMoney(_price);
        usersArr[userIndexMap[msg.sender]].balance -= _price;
    }

    function createFine(address _toBeFined) public isDPS {
        // Сказано, что штраф выписывается по номеру ВУ, что для меня достаточно странно. Пока оставлю так. Но возомжно будет нобходимо менять структуры.
        usersArr[userIndexMap[_toBeFined]].notPayedFines.push(block.timestamp);
    }

    function createAccident(address _toPay) public isDPS {
        require(
            usersArr[userIndexMap[_toPay]].insuranceFee != 0,
            "You did not pay for incurance"
        );
        ins.giveMoney(usersArr[userIndexMap[_toPay]].insuranceFee);
        usersArr[userIndexMap[_toPay]].balance +=
            usersArr[userIndexMap[_toPay]].insuranceFee *
            10;
    }

    function moneyBack(uint256 _amount) external {
        require(
            _amount <= msg.sender.balance,
            "not enough money on your balanace"
        );
        msg.sender.transfer(_amount);
        usermap[msg.sender].balance -= _amount;
    }
}
