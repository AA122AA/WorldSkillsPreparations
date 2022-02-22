// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// import "./Insur.sol" as Insur;
contract Bank {
    event sendMoney(address sender, uint256 amount);
    event receiveMoney(address sender, uint256 amount);
    event Received(address, uint256);
    address insurContrAddr;
    Addresses addr;

    constructor(address _addrContr) {
        addr = Addresses(_addrContr);
        addr.setAddr(address(this), "bank");
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function giveMoneyInsur(uint256 _value) external payable {
        insurContrAddr = addr.getInsur();
        require(insurContrAddr == msg.sender, "You have no permision");
        require(address(this).balance >= _value, "no money in bank");
        payable(insurContrAddr).transfer(_value);
        emit sendMoney(insurContrAddr, _value);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function popolnitbalans() external payable {}
}

contract Insur {
    uint256 public debt = 0; //не работает
    Addresses addr;
    Bank bankContract;

    constructor(address _addrContr) {
        addr = Addresses(_addrContr);
        addr.setAddr(address(this), "insur");
    }

    address payable bankContractAddr;

    address userContractAddr;

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

    function takeMoney(uint256 _price) external payable {
        userContractAddr = addr.getUser();
        require(msg.sender == userContractAddr);
        // Может вызываться только с контракта User
        if (debt != 0) {
            if (debt > _price) {
                debt -= _price;
                bankContractAddr.transfer(msg.value);
            } else if (debt <= msg.value) {
                bankContractAddr.transfer(debt);
                debt = 0;
            }
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function giveMoney(address _toPay, uint256 _amount) external payable {
        userContractAddr = addr.getUser();
        bankContractAddr = payable(addr.getBank());
        bankContract = Bank(bankContractAddr);
        require(msg.sender == userContractAddr);
        uint256 _a = _amount * 10;
        uint256 _debt = _a - address(this).balance;
        if (_a > address(this).balance) {
            bankContract.giveMoneyInsur(_debt);
            debt += _debt;
        }
        payable(_toPay).transfer(_a);
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

    address[] usersAddrArr;

    mapping(address => User_str) public usersMap;
    mapping(address => Car_str) public usersCar;
    mapping(string => DrivingLicence) public drivingLicencePool;

    Insur ins;
    uint256 usersCount = 0;
    uint256 date;
    address admin;
    address payable bankContrAddr;
    address payable insurContrAddr;
    Addresses addr;

    // ["000",1649538000,"C"],["111",1655586000,"B"],["222",1661979600,"D"],["333",1663794000,"C"],["444",1653166800,"B"],["555",1779397200,"E"],["666",1646859600,"B"], "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xd9145CCE52D386f254917e481eB44e9943F39138" - так передаются таплы
    constructor(
        DrivingLicence memory _dl0,
        DrivingLicence memory _dl1,
        DrivingLicence memory _dl2,
        DrivingLicence memory _dl3,
        DrivingLicence memory _dl4,
        DrivingLicence memory _dl5,
        DrivingLicence memory _dl6,
        address _admin,
        address _addrContr
    )
    // деплоим все 3 контракта, затем получем их адреса и создаем еще один контракт, котоырй хранит их адреса
    {
        drivingLicencePool[_dl0.number] = _dl0;
        drivingLicencePool[_dl1.number] = _dl1;
        drivingLicencePool[_dl2.number] = _dl2;
        drivingLicencePool[_dl3.number] = _dl3;
        drivingLicencePool[_dl4.number] = _dl4;
        drivingLicencePool[_dl5.number] = _dl5;
        drivingLicencePool[_dl6.number] = _dl6;
        date = block.timestamp;
        admin = _admin;
        addr = Addresses(_addrContr);
        addr.setAddr(address(this), "user");
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
    modifier isDPS(address _address) {
        User_str memory _DPS = usersMap[_address];
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
        usersAddrArr.push(_user.userAddr);
        usersMap[_user.userAddr] = _user;
    }

    function popolnitbalans() external payable {
        usersMap[msg.sender].balance += msg.value;
    }

    function createUser(
        User_str memory _user // ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "admin", ["000",1649538000,"C"], 5, 0, [], 0, 0, true] - такое надо передавать чтоб создавать юзера.
    ) public dlCheck(_user.dl.number, _user.dl.validity, _user.dl.category) {
        require(msg.sender == admin);
        usersAddrArr.push(_user.userAddr);
        usersMap[_user.userAddr] = _user;
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
        usersMap[msg.sender].dl = _dl;
    }

    function registerCar(
        string memory _carCategory,
        uint256 _price,
        uint256 _age
    ) public {
        require(
            keccak256(bytes(usersMap[msg.sender].dl.category)) ==
                keccak256(bytes(_carCategory)),
            "wrong category"
        );
        usersCar[msg.sender] = Car_str(_carCategory, _price, _age);
    }

    function dlProlongation() public {
        User_str memory _user = usersMap[msg.sender];
        require(
            _user.dl.validity >= block.timestamp + 30 * 1 days,
            "Your driving licence are expiring in less then month. You can not prolongate them through this portal. Please visit police station"
        );
        require(_user.notPayedFines.length == 0, "Pay your fines dude");
        usersMap[msg.sender].dl.validity += 365 * 1 days;
    }

    function checkFinesAmount() public view returns (uint256) {
        return usersMap[msg.sender].notPayedFines.length;
    }

    function finePayment(uint256 _finesToPay) public payable {
        bankContrAddr = payable(addr.getBank());
        uint256[] memory _arr = usersMap[msg.sender].notPayedFines;
        uint256 _len = _arr.length;
        require(_len != 0, "All fines are payed");
        require(
            _len >= _finesToPay,
            "You got less fines, use checkFinesAmount to know exact number"
        );
        for (uint256 index = 0; index < _finesToPay; index++) {
            if (_arr[_len - 1 - index] + 25 seconds > block.timestamp) {
                bankContrAddr.transfer(5 ether);
                usersMap[msg.sender].balance -= 5 ether;
            } else {
                bankContrAddr.transfer(10 ether);
                usersMap[msg.sender].balance -= 10 ether;
            }
            usersMap[msg.sender].notPayedFines.pop();
        }
    }

    function formInsPrice() public returns (uint256) {
        insurContrAddr = payable(addr.getInsur());
        ins = Insur(insurContrAddr);
        require(usersCar[msg.sender].price != 0, "add car");
        User_str memory _user = usersMap[msg.sender];
        Car_str memory _usersCar = usersCar[msg.sender];
        uint256 _exp = (block.timestamp - _user.startDrive) / (365 * 1 days);
        uint256 _price = ins.getPrice(
            _usersCar.price,
            _usersCar.age,
            _user.notPayedFines.length,
            _user.accidentAmount,
            _exp
        );
        usersMap[msg.sender].insuranceFee = _price;
        return _price;
    }

    function payForIns() public {
        uint256 _price = formInsPrice();
        insurContrAddr = payable(addr.getInsur());
        ins = Insur(insurContrAddr);
        require(usersMap[msg.sender].balance >= _price);
        payable(ins).transfer(_price); // переделать на call https://docs.soliditylang.org/en/latest/contracts.html?highlight=call#fallback-function
        ins.takeMoney(_price);
        usersMap[msg.sender].balance -= _price;
    }

    function createFine(address _toBeFined) public isDPS(msg.sender) {
        // Сказано, что штраф выписывается по номеру ВУ, что для меня достаточно странно. Пока оставлю так. Но возомжно будет нобходимо менять структуры.
        usersMap[_toBeFined].notPayedFines.push(block.timestamp);
    }

    function createAccident(address _toPay) public payable isDPS(msg.sender) {
        // проверять покупал ли пользователь страховку, то что ниже фигня
        insurContrAddr = payable(addr.getInsur());
        ins = Insur(insurContrAddr);
        require(
            usersMap[_toPay].insuranceFee != 0,
            "You did not pay for incurance"
        );
        ins.giveMoney(_toPay, usersMap[_toPay].insuranceFee);
        usersMap[_toPay].balance += usersMap[_toPay].insuranceFee * 10;
        usersMap[_toPay].accidentAmount += 1;
    }

    function moneyBack(uint256 _amount) external payable {
        require(
            _amount <= msg.sender.balance,
            "not enough money on your balanace"
        );
        payable(msg.sender).transfer(_amount);
        usersMap[msg.sender].balance -= _amount;
    }
}

contract Addresses {
    event wrongCall(address sender, string _name);

    address bankContractAddr;
    address insurContractAddr;
    address userContractAddr;

    function setAddr(address _address, string memory _contrName) external {
        if (keccak256(bytes(_contrName)) == keccak256(bytes("bank"))) {
            bankContractAddr = _address;
        } else if (keccak256(bytes(_contrName)) == keccak256(bytes("user"))) {
            userContractAddr = _address;
        } else if (keccak256(bytes(_contrName)) == keccak256(bytes("insur"))) {
            insurContractAddr = _address;
        } else {
            emit wrongCall(_address, _contrName);
        }
    }

    function getBank() external view returns (address) {
        return bankContractAddr;
    }

    function getInsur() external view returns (address) {
        return insurContractAddr;
    }

    function getUser() external view returns (address) {
        return userContractAddr;
    }

    function getAddr() public view returns (address) {
        return address(this);
    }
}
