pragma solidity ^0.5.8;

import "./Ownable.sol";
import "./ERC165.sol";
import "./Interfaces.sol";

contract MembershipVerificationToken is Ownable, ERC165 {

    uint256 public fee;
    string public name = "Blockchain Australia";

    struct MemberData {
        bool hasToken;
        bytes[] data;
    }

    struct PendingRequest {
        bool isPending;
        //bytes32[] attributes;
        uint[] attributeIndexes;
    }

    mapping(uint => bytes32[]) public attributeValueCollection;
    bytes32[] public attributeNames;

    mapping(address => MemberData) public currentHolders;
    mapping(address => PendingRequest) public pendingRequests;

    address[] public allHolders;

    uint public currentMemberCount;

    event ApprovedMembership(address indexed _to, uint[] attributeIndexes);
    event RequestedMembership(address indexed _to);
    event Assigned(address indexed _to, uint[] attributeIndexes);
    event Revoked(address indexed _to);
    event Forfeited(address indexed _to);
    
    event ModifiedAttributes(
        address indexed _to,
        uint attributeIndex,
        uint prevValueIndex,
        bytes32 prevValue,
        uint modifiedValueIndex,
        bytes32 modifiedValue
    );

    constructor() public {
        _registerInterface(0x912f7bb2); //IERC1261
        _registerInterface(0x83adfb2d); //Ownable
    }

    modifier isCurrentHolder {
        require(isCurrentMember(msg.sender), "Not a current member");
        _;
    }

    function requestMembership(uint[] calldata _attributeIndexes) external payable {
        require(!isCurrentMember(msg.sender), "Already a member");
        require(_attributeIndexes.length == attributeNames.length, "Need to input all attributes");

        //Do some checks before assigning membership
        PendingRequest storage request = pendingRequests[msg.sender];
        request.isPending = true;
        //request.attributes = _attributeIndexes;
        emit RequestedMembership(msg.sender);
    }

    function forfeitMembership() external payable isCurrentHolder {
        _revoke(msg.sender);
        emit Forfeited(msg.sender);
    }

    // function approveRequest(address _user) external onlyOwner {
    //     PendingRequest storage request = pendingRequests[_user];
    //     require(request.isPending, "Hasn't sent ether yet");
    //     _assign(_user, request.attributes);
    //     emit ApprovedMembership(_user, request.attributes);
    // }

    function discardRequest(address _user) external onlyOwner {
        PendingRequest storage request = pendingRequests[_user];
        require(request.isPending, "Hasn't sent ether yet");
        request.isPending = false;
        delete request.attributeIndexes;
    }

    function assignTo(address _to, uint[] calldata _attributeIndexes) external onlyOwner {
        //_assign(_to, _attributeIndexes);
        emit Assigned(_to, _attributeIndexes);
    }

    function revokeFrom(address _from) external onlyOwner {
        _revoke(_from);
        emit Revoked(_from);
    }

    function addAttributeSet(bytes32 _name, bytes32[] calldata values) external {
        attributeNames.push(_name);
        bytes32[] storage storedValues = attributeValueCollection[attributeNames.length - 1];
        storedValues.push(0x756e646566696e65640000000000000000000000000000000000000000000000);

        for (uint index = 0; index < values.length; index++) {
            storedValues.push(values[index]);
        }
    }

    // function modifyAttributeByIndex(address _to, uint _attributeIndex, uint _modifiedValueIndex) external onlyOwner {
    //     // uint attributeIndex = getIndexOfAttribute(_attributeName);
    //     //require(currentHolders[_to].data.length > _attributeIndex, "data doesn't exist for the user");
        
    //     uint prevIndex = currentHolders[_to].data[_attributeIndex];
    //     bytes32 prevValue = attributeValueCollection[_attributeIndex][prevIndex];
    //     currentHolders[_to].data[_attributeIndex] = _modifiedValueIndex;
    //     bytes32 modifiedValue = attributeValueCollection[_attributeIndex][_modifiedValueIndex];
        
    //     emit ModifiedAttributes(
    //         _to,
    //         _attributeIndex,
    //         prevIndex,
    //         prevValue,
    //         _modifiedValueIndex,
    //         modifiedValue
    //     );
    // }

    function getAllMembers() external view returns (address[] memory) {
        return allHolders;
    }

    function getCurrentMemberCount() external view returns (uint) {
        return currentMemberCount;
    }

    function getAttributeNames() external view returns (bytes32[] memory) {
        return attributeNames;
    }

    // function getAttributes(address _to) external view returns (bytes32[] memory) {
    //     require(_to != address(0), "Address cannot be zero");
    //     return currentHolders[_to].data;
    // }

    function getAttributeExhaustiveCollection(uint _index) external view returns (bytes32[] memory) {
        return attributeValueCollection[_index];
    }

    // function getAttributeByIndex(address _to, uint _attributeIndex) external view returns (bytes32) {
    //     require(currentHolders[_to].data.length > _attributeIndex,"data doesn't exist for the user");
    //     return currentHolders[_to].data[_attributeIndex];
    // }

    function isCurrentMember(address _to) public view returns (bool) {
        require(_to != address(0), "Zero address can't be a member");
        return currentHolders[_to].hasToken;
    }

    // function _assign(address _to, uint[] memory _attributeIndexes) internal {
    //     require(_to != address(0), "Can't assign to zero address");
    //     require(
    //         _attributeIndexes.length == attributeNames.length,
    //         "Need to input all attributes"
    //     );
    //     MemberData memory member;
    //     member.hasToken = true;
    //     currentHolders[_to] = member;
    //     for (uint index = 0; index < _attributeIndexes.length; index++) {
    //         currentHolders[_to].data.push(_attributeIndexes[index]);
    //     }
    //     allHolders.push(_to);
    //     currentMemberCount += 1;
    // }

    function _revoke(address _from) internal {
        require(_from != address(0), "Can't revoke from zero address");
        MemberData storage member = currentHolders[_from];
        member.hasToken = false;
        currentMemberCount -= 1;
    }
}