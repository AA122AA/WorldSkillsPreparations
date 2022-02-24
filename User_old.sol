// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;

contract User{

    address payable constant bank = 0xD9eaa853bBCCcf5CB0A49241A7F69d743f3cf049; 
    uint256 FinesCount;
    struct VU{
        uint256 number;
        uint256 validity;
        string category;
    }

    struct Fine{

        //uint256 index;
        uint256 createdAt;
        uint256 amount;
        bool isPaid;
    }

    struct User_str{
        string FIO;
        VU vu;
        uint256 startDrive;
        uint256 dtpAmount;
        uint256 fine;
        uint256 balance_str;
    }

    mapping (address=>User_str) users;
    mapping(uint256 => uint[]) user_fines;
    mapping(uint => Fine) fines_list;
    
    function createUser(
        address _user,
        string memory _name,
        uint256 _number,
        uint256 _validity,
        string memory _category,
        uint256 _startDrive,
        uint256 _dtpAmount,
        uint256 _fine
        ) external {
            // User_str storage u = users[_user]
            users[_user].FIO = _name;
            users[_user].vu.number = _number;
            users[_user].vu.validity = _validity;
            users[_user].vu.category = _category;
            users[_user].startDrive = _startDrive;
            users[_user].dtpAmount = _dtpAmount;
            users[_user].fine = _fine;
            users[_user].balance_str = address(_user).balance;               
    }
    function getUser(address _user) external view returns(
        string memory FIO, uint256 vu_num, 
        string memory category, uint256 startDrive, 
        uint256 dtpAmount, uint256 fines, uint256 balance_str
        ) {
        return (
            users[_user].FIO, users[_user].vu.number, 
            users[_user].vu.category, users[_user].startDrive, 
            users[_user].dtpAmount, users[_user].fine, users[_user].balance_str
            ); 
    }    
    
    function setFIO(address _addr, string memory _name) external{
        users[_addr].FIO = _name;
    }

    function setVu(address _addr, uint256 _number, string memory _category, uint256 _validity) external{
        users[_addr].vu.number = _number;
        users[_addr].vu.validity = _validity;
        users[_addr].vu.category = _category;
    }

    function setDtpAmount(address _addr, uint256 _dtpAmount) external{
        users[_addr].dtpAmount = _dtpAmount;
    }

    function setFine(uint256 _vuNumber, uint256 _time, uint256 _fine) external {
        FinesCount+=1;
        fines_list[FinesCount].createdAt =_time;
        fines_list[FinesCount].amount = _fine;
        fines_list[FinesCount].isPaid = false;
        user_fines[_vuNumber].push(FinesCount);
    }

    function getFines(uint256 id) public view returns(uint256 amount, uint256 createdAt, bool isPaid){
        return (fines_list[id].amount, fines_list[id].createdAt, fines_list[id].isPaid); 
    }    
    
    function getIDs(uint256 _vuNumber) public view returns(uint256[] memory){
        return user_fines[_vuNumber];
    }

    function payFine(uint256 _amount, uint256 _vuNumber, uint256 _index) external {
        bank.transfer(_amount);
        user_fines[_vuNumber]]
    }
}