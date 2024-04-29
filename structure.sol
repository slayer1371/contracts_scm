// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Structure {
    enum State {
        Manufactured,
        PurchasedByDistributor,
        ShippedByManufacturer,
        ReceivedByDistributor,
        PurchasedByCustomer,
        ShippedByDistributor,
        ReceivedByRetailer,
        ShippedByRetailer,
        ReceivedByCustomer
    }
    struct ManufacturerDetails {
        address manufacturer;
        string name;
       //ProductDetails[] products;
        
        // string manufacturerDetails;
        // string manufacturerLongitude;
        // string manufacturerLatitude;
        // uint256 manufacturedDate;
    }
    struct CustomerDetails{
        address customer;
        string name;
        // product history
    }
    struct ProductDetails {
        string productName;
        uint256 productCode;
        uint256 productPrice;
        State productState;
        string location;
        address customer;
        address retailer;
        address distributor;
        // address manufacturer;
        // string productCategory;
    }
    struct DistributorDetails {
        address distributor;
        string name;
        // string thirdPartyLongitude;
        // string thirdPartyLatitude;
    }
    struct RetailerDetails {
        address retailer;
        string name;
        // string deliveryHubLongitude;
        // string deliveryHubLatitude;
    }
    // struct Product {
    //     uint256 uid;
    //     uint256 sku;
    //     address owner;
    //     State productState;
    //     ManufacturerDetails manufacturer;
    //     ThirdPartyDetails thirdparty;
    //     ProductDetails productdet;
    //     DeliveryHubDetails deliveryhub;
    //     address customer;
    //     string transaction;
    // }

    struct ProductHistory {
        ProductDetails[] history;
    }

    struct Roles {
        bool Manufacturer;
        bool ThirdParty;
        bool DeliveryHub;
        bool Customer;
    }
    struct verify{
        address party_shipped;
        address party_received;
        bool party_S;
        bool party_R;
    }
}