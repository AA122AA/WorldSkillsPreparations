pragma solidity ^0.8.4;

contract info{
    
    mapping(address=>transport) transp;
    struct transport{
        string category;
        uint256 price;
        uint256 srok;
    }

 function getSrok(address person)public view returns(uint){
     return(transp[person].srok);
 }
}
///контракт штрафов///
contract shtrafi{
    address m;
    address bank;  
     constructor(address b,address contMain){
        bank=b;
        m=contMain;
    }
    
    mapping(uint=>uint[])shtr;
    
    modifier ifDPS(address user){
    main m = main(m);
        require(m.DPSRole(user)==true);
       _;
    }
    
event newShtraf(uint indexed number, uint timestamp,uint id);
event PogashenShtraf(uint indexed number,uint id);
    
    function addShtrafi(uint number) ifDPS(msg.sender) public{          //добавление штрафа
      shtr[number].push(block.timestamp);
      emit newShtraf(number, block.timestamp,shtr[number].length-1);
}


function oplShtrafa(uint id,uint numb) payable public{       //оплата штрафа
    require(msg.value==5||msg.value==10);
   if( shtr[numb][id]+5 days<=block.timestamp){
       require(msg.value==5);
       shtr[numb][id]=0;
       emit PogashenShtraf (numb,id);
   }
   else{
       require(msg.value==10,"You should pay ten coins.");
         shtr[numb][id]=0;
        emit PogashenShtraf (numb,id);
   } 
 payable(bank).transfer(msg.value);
}
}
///главный контракт:функции связанные со страховкой,добавлением,оформлением дтп
contract main is info{
    address payable bank;
    address payable strahCompany;
    uint debt;
    constructor(address b,address st){
        bank=payable(b);
        strahCompany=payable(st);
    }

    mapping(uint=>person) per;
    struct person{
        string FIO;
        address user;                              //номер для дпс
        uint kolDTP;               //количество дтп
        uint kolNeOplShtr;
        uint256 srok; 
                      
    }
    mapping(address=>person2) per2;
    struct person2{
        uint8 role;                     //0-нет в системе,1-дпс,2-водитель, 3-и дпс и водитель
        string categor;
        uint vodStaj;             //год начала
        int strahVznos;
    }


    modifier onlyDPS(address user){
        require(per2[msg.sender].role==1||per2[msg.sender].role==3);
        _;
    }
     modifier onlyBank(address user){
        require(user==bank);
        _;
    }
    
    modifier onlyStrah(){
        require(msg.sender==bank);
        _;
    }
    
event formStrahovanie(uint numberDriver,int amount);
event viplataStrahovanie(uint number,uint amount);

function addToByDPS(string memory FIO,address user, uint256 srok,string memory categor, uint256 number,uint32 vodStaj,uint8 role) public{ //добавление водителя 
 if (per2[msg.sender].role==0){
   per[number]=person(FIO,user,0,0,srok);
    per2[msg.sender]=person2(role,categor,vodStaj,0);
 }
}

function formStrah(uint number) public{                 //формирование страховки  
per2[msg.sender].strahVznos=int(abs(int(abs(1-int(getSrok(msg.sender)/10))*int(1)/10))+int(per[number].kolNeOplShtr)*int(2)/10+int(per[number].kolDTP)-int(per2[msg.sender].vodStaj)*int(5)/100);
emit formStrahovanie(number,per2[msg.sender].strahVznos);
}

function payToStrahCompany() external payable {   
    require(msg.value==uint(per2[msg.sender].strahVznos),"Not enough money for paying the fine or an uppropriate value");           
    if(debt>0&&debt>msg.value){
         debt-=msg.value;
         bank.transfer(msg.value); 
    }
    else if(debt>0){
        debt=0;
        bank.transfer(debt);
        strahCompany.transfer(msg.value-debt); 
    }
    else{
        strahCompany.transfer(msg.value); 
    }
}

function payToBank() external onlyStrah() payable {     //страховая компания перенаправляет в банк
 debt-=msg.value;          
    bank.transfer(msg.value);  
}

function oformDTP(uint number) public onlyDPS(msg.sender){                           //оформл страховки
 per[number].kolDTP+=1;
 if(strahCompany.balance<uint(per2[msg.sender].strahVznos)*10){
     revert("Not enough money to form DTP");
 }
 else{
      payable(msg.sender).transfer(uint(per2[msg.sender].strahVznos)*10);
    emit viplataStrahovanie(number,uint(per2[msg.sender].strahVznos)*10);
 }
   
}

function addTranspDPS(address user, string memory category, uint256 price, uint256 srok) onlyDPS(msg.sender) public{          //добавление транспорта
    transp[msg.sender]=transport(category,price,srok);
}

function registerTransp(string memory cat, uint256 price,uint256 strok) public{          //регистрация водителем
 require(((keccak256(abi.encodePacked(per2[msg.sender].categor))) == keccak256(abi.encodePacked(cat))));
     transp[msg.sender]=transport(cat,price,strok);
}


function prodlevSrokVodYdost(uint number,uint howMuch) public onlyDPS(msg.sender){                //продление срока удостоверения
    if(per[number].kolNeOplShtr==0&&(block.timestamp+31 days<per[number].srok)){
       per[number].srok=howMuch*1 days;  
    }
}

function toStrahFromBank() onlyBank(msg.sender)external payable{      //банк одалживает страх компании
    debt+=msg.value;
    payable(strahCompany).transfer(msg.value);
}

function DPSRole(address user) public returns(bool){          
if(per2[user].role==1||per2[user].role==3){
    return true;
}

else{
    return false;
}
}

//////////////////getters///////////////////////////
 function getBANK()public view returns(uint){                                 //для gui
    return bank.balance;
 }
 
  function getStSum()public view returns(uint){
    return (uint(per2[msg.sender].strahVznos));
 }
 
  function getSTRAH()public view returns(uint){
     return strahCompany.balance;
}
//////////////////////////////////////////////////////////


function abs(int x) private returns(int){
if(x>=0){
    return x;
}
else{
    return(-x);
}
}
}
