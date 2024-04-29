//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Structure} from "./structure.sol";

contract Supplychain{
    //events .............
    event AddProduct();
    event ProductUpdatedByManufacturer();
    event ProductUpdatedByCustomer();
    event ProductUpdatedByDistributor();
    event ProductUpdatedByRetailer();
    event AddManufacturer();
    event AddRetailer();
    event AddCustomer();
    event AddDistributor();
    event BothPartiesVerified(address sender, address receiver);

    // custom error..............

    // constructor ..............
    constructor(){
            Verification.push(Structure.verify({
            party_shipped: address(0x0),
            party_received: address(0x0),
            party_S : false,
            party_R :false
        }));
    }

    // state variables................
    uint internal pId; //unique productId
    uint internal mId; //unique manufacturerId
    uint internal cId; //uique customerId
    uint internal rId; //unique retailerId
    uint internal dId; //unique distributorId
    uint internal verificationId;
    mapping (address => uint) manufacturerId;
    mapping(address => bool) isManufacturer;
    mapping(address => bool) isCustomer;
    mapping(address => bool) isDistributor;
    mapping(address => bool) isRetailer;
    mapping(uint => bool) isVerified; // verification related to particular Id completed or not
    Structure.ManufacturerDetails[] internal  Manufacturers;
    Structure.CustomerDetails[] internal Customers;
    Structure.RetailerDetails[] internal Retailers;
    Structure.DistributorDetails[] internal Distributors;
    Structure.ProductDetails[] internal Products;
    Structure.verify[] internal Verification;
    
    // modifiers..........
    modifier onlyManufacturer(){
        require(isManufacturer[msg.sender]==true,"is not a manufacturer");
        _;
    }

    modifier onlyCustomer(){
        require(isCustomer[msg.sender]==true,"is not a Customer");
        _;
    }

    modifier onlyDistributor(){
        require(isDistributor[msg.sender]==true,"is not a Distributor");
        _;
    }

    modifier onlyRetailer(){
        require(isRetailer[msg.sender]==true,"is not a Retailer");
        _;
    }

    // functions.....................
    function addProduct(string memory _name, uint _price, string memory _location ) public onlyManufacturer(){
        Products.push(Structure.ProductDetails({
            productName: _name,
            productCode: pId,
            productPrice: _price,
            productState: Structure.State.Manufactured,
            location: _location,
            customer:msg.sender,
            retailer:msg.sender,
            distributor:msg.sender
        }));
        pId+=1;
    }

    // function updateProduct(uint _id) public{
        
    // }

    function viewProductDetailsById(uint _id) view public returns(string memory,uint,Structure.State,string memory,address){
        return (Products[_id].productName, Products[_id].productPrice , Products[_id].productState , Products[_id].location , Products[_id].customer);
    }

    function viewProducts() public view returns(Structure.ProductDetails[] memory) {
        uint length = Products.length;
        Structure.ProductDetails[] memory result = new Structure.ProductDetails[](length);

        for (uint256 i = 0; i < length; i++) {
            result[i] = Products[i];
        }
        
        return result;
    }

    function addManufacturer(string memory _name) public returns(bool){
        if(!isManufacturer[msg.sender]){
            Manufacturers.push(Structure.ManufacturerDetails({
                manufacturer:msg.sender,
                name:_name
            }));
            isManufacturer[msg.sender]=true;
            manufacturerId[msg.sender] = mId;
            mId+=1;
            return true;
        }
        return false;
    }

    function viewManufacturers() public view returns (Structure.ManufacturerDetails[] memory) {
        uint256 length = Manufacturers.length;
        Structure.ManufacturerDetails[] memory result = new Structure.ManufacturerDetails[](length);
        
        for (uint256 i = 0; i < length; i++) {
            result[i] = Manufacturers[i];
        }
        
        return result;
    }

    function addCustomer(string memory _name) public returns(bool){
        if(!isCustomer[msg.sender]){
            Customers.push(Structure.CustomerDetails({
                customer:msg.sender,
                name:_name
            }));
            isCustomer[msg.sender] = true;
            cId+=1;
            return true;
        }
        return false;
    }

    function viewCustomers() public view returns(Structure.CustomerDetails[] memory) {
        uint length = Customers.length;
        Structure.CustomerDetails[] memory result = new Structure.CustomerDetails[](length);

        for (uint256 i = 0; i < length; i++) {
            result[i] = Customers[i];
        }
        
        return result;
    }

    function addRetailer(string memory _name) public returns(bool) {
        if(!isRetailer[msg.sender]){
            Retailers.push(Structure.RetailerDetails({
                retailer:msg.sender,
                name:_name
            }));
            isRetailer[msg.sender] = true;
            rId+=1;
            return true;
        }
        return false;
    }

    function viewRetailers() public view returns(Structure.RetailerDetails[] memory) {
        uint length = Retailers.length;
        Structure.RetailerDetails[] memory result = new Structure.RetailerDetails[](length);

        for (uint256 i = 0; i < length; i++) {
            result[i] = Retailers[i];
        }
        
        return result;
    }

    function addDistributor(string memory _name) public returns(bool){
        if(!isDistributor[msg.sender]){
            Distributors.push(Structure.DistributorDetails({
                distributor:msg.sender,
                name:_name
            }));
            isDistributor[msg.sender] = true;
            dId+=1;
            return true;
        }
        return false;
    }

    function viewDistributors() public view returns(Structure.DistributorDetails[] memory) {
        uint length = Distributors.length;
        Structure.DistributorDetails[] memory result = new Structure.DistributorDetails[](length);

        for (uint256 i = 0; i < length; i++) {
            result[i] = Distributors[i];
        }
        
        return result;
    }


    function viewCurrentState(uint _pId) public view returns(Structure.State) {
        return Products[_pId].productState;
    }


    // pass vId 0 if not exist
    function updateStateByManufacturer(uint _pId, address _distributor) public onlyManufacturer returns(bool,uint) {
        uint x=0;
        if(Products[_pId].productState == Structure.State.Manufactured){
            x = createVerifictaionProcess(msg.sender,_distributor);
            Products[_pId].productState = Structure.State.PurchasedByDistributor;
        }
        else if(Products[_pId].productState == Structure.State.PurchasedByDistributor){
            Products[_pId].productState = Structure.State.ShippedByManufacturer;
        }
        else{
            return (false,x);
        }
        return (true,x);
    }

    function updateStateByDistributor(uint _pId, uint _vId, address _retailer) public onlyDistributor returns(bool,uint) {
        //Validation added............
        uint x;
        if(Products[_pId].productState == Structure.State.ShippedByManufacturer){
            // isverified check
            require(isVerified[_vId],"not verified, Approve that u have received first by going to Approve function");
            Products[_pId].productState = Structure.State.ReceivedByDistributor;
        }
        else if(Products[_pId].productState == Structure.State.ReceivedByDistributor){
            // verification Id for verifying product status received by Retailer from distributor
            x = createVerifictaionProcess(msg.sender,_retailer);
            Products[_pId].productState = Structure.State.PurchasedByCustomer;
        }
        else if(Products[_pId].productState == Structure.State.PurchasedByCustomer){
            Products[_pId].productState = Structure.State.ShippedByDistributor;
        }else {
            return (false,x);
        }
        return (true,x);
    }

    function updateStateByRetailer(uint _pId,uint _vId, address _customer) public onlyRetailer returns(bool,uint){
        //Validation added............
        uint x;
        if(Products[_pId].productState == Structure.State.ShippedByDistributor){
            require(isVerified[_vId],"not approved, Approve that u have received");
            Products[_pId].productState = Structure.State.ReceivedByRetailer;
        }
        else if(Products[_pId].productState == Structure.State.ReceivedByRetailer){
            // verifiaction ID for verifying product status received by customer from Retailer
            x = createVerifictaionProcess(msg.sender,_customer);
            Products[_pId].productState == Structure.State.ShippedByRetailer;
        }else {
            return (false,x);
        }
        return (true,x);
    }

    function updateStateByCustomer(uint _pId,uint _vId) public onlyCustomer  returns(bool){
        //Validation added............
        if(Products[_pId].productState == Structure.State.ShippedByRetailer){
            require(isVerified[_vId],"not approved, Approve that u have received");
            Products[_pId].productState = Structure.State.ReceivedByCustomer;
        }else {
            return false;
        }
        return true;
    }

    // to transfer your rights to other address
    function updateAddress() public{

    }

    function createVerifictaionProcess(address _sender, address _receiver) public returns(uint) {
        verificationId+=1;
        Verification.push(Structure.verify({
            party_shipped: _sender,
            party_received: _receiver,
            party_S : false,
            party_R :false
        }));
        return verificationId;
    }

    function Approve(uint _vId) public{
        require(_vId != 0,"invalid VID");
        require(Verification[_vId].party_shipped == msg.sender || Verification[_vId].party_received == msg.sender,"not a member");
        if(Verification[_vId].party_shipped == msg.sender){
            Verification[_vId].party_S = true;
            if(Verification[_vId].party_R == true){
                isVerified[_vId]=true;
            }
        }
        if(Verification[_vId].party_received == msg.sender){
            Verification[_vId].party_R = true;
            if(Verification[_vId].party_S == true){
                isVerified[_vId]=true;
            }
        }
    }
}