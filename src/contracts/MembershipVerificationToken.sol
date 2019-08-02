pragma solidity ^0.5.8;

import "./Ownable.sol";
import "./ERC165.sol";
import "./Interfaces.sol";

contract MembershipVerificationToken is Ownable, ERC165 {

    string public name = "Blockchain Australia";

    struct MemberData {
        uint from;
        uint to;
        uint[] data;
    }

    struct PendingRequest {
        bool isPending;
        uint[] attributeIndexes;
    }

    struct MembershipType {
        uint256 fee;
        uint256 duration;
    }

    bytes32[] public attributeNames;

    mapping(bytes32 => MembershipType) public membershipTypes;
    mapping(uint => bytes32[]) public attributeValueCollection;
    mapping(address => MemberData) public currentHolders;
    mapping(address => PendingRequest) public pendingRequests;

    address[] public allHolders;
    uint public currentMemberCount;

    event ApprovedMembership(address indexed _to, uint[] attributeIndexes);
    event RequestedMembership(address indexed _to);
    event Assigned(address indexed _to, uint[] attributeIndexes);
    event Revoked(address indexed _to);
    event Forfeited(address indexed _to);
    
    event ModifiedAttributes(address indexed _to, uint attributeIndex, uint prevValueIndex, bytes32 prevValue, uint modifiedValueIndex, bytes32 modifiedValue);

    constructor() public {
        _registerInterface(0x912f7bb2); //IERC1261
        _registerInterface(0x83adfb2d); //Ownable

        attributeNames.push("type");
        attributeValueCollection[0].push("life");
        attributeValueCollection[0].push("board");
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
        request.attributeIndexes = _attributeIndexes;
        
        emit RequestedMembership(msg.sender);
    }

    function forfeitMembership() external payable isCurrentHolder() {
        _revoke(msg.sender);
        emit Forfeited(msg.sender);
    }

    function approveRequest(address _user) external onlyOwner {
        require(!isCurrentMember(_user), "Already a member");

        PendingRequest storage request = pendingRequests[_user];

        require(request.isPending, "Hasn't sent ether yet");

        //
        for (uint256 i = 0; i < request.attributeIndexes.length; i++) {
            currentHolders[_user].data[i] = request.attributeIndexes[i];
        }

        currentHolders[_user].from = now;
        //member.to = _to;

        allHolders.push(_user);
        currentMemberCount += 1;

        emit ApprovedMembership(_user, request.attributeIndexes);
    }

    function discardRequest(address _user) external onlyOwner {
        PendingRequest storage request = pendingRequests[_user];
        request.isPending = false;

        delete request.attributeIndexes;
    }

    function assignTo(address _to, uint[] calldata _attributeIndexes) external onlyOwner() {
        _assign(_to, _attributeIndexes);
        emit Assigned(_to, _attributeIndexes);
    }

    function revokeFrom(address _from) external onlyOwner() {
        _revoke(_from);
        emit Revoked(_from);
    }

    function addMembershipType(uint256 _fee, uint256 _duration) public onlyOwner() {
        
    }

    function modifyMembershipType(bytes32 _type, uint256 _fee, uint256 _duration) public onlyOwner() {

    }

    function removeMembershipType(bytes32 _type) public onlyOwner() {
        delete membershipTypes[_type];
    }

    function addAttributeSet(bytes32 _name, bytes32[] calldata values) external {
        attributeNames.push(_name);
        bytes32[] storage storedValues = attributeValueCollection[attributeNames.length - 1];
        //storedValues.push(0x756e646566696e65640000000000000000000000000000000000000000000000);

        for (uint index = 0; index < values.length; index++) {
            storedValues.push(values[index]);
        }
    }

    function modifyAttributeByIndex(address _to, uint _attributeIndex, uint _modifiedValueIndex) external onlyOwner() {
        require(currentHolders[_to].data.length > _attributeIndex, "data doesn't exist for the user");
        
        uint prevIndex = currentHolders[_to].data[_attributeIndex];
        bytes32 prevValue = attributeValueCollection[_attributeIndex][prevIndex];
        currentHolders[_to].data[_attributeIndex] = _modifiedValueIndex;
        bytes32 modifiedValue = attributeValueCollection[_attributeIndex][_modifiedValueIndex];
        
        emit ModifiedAttributes(
            _to,
            _attributeIndex,
            prevIndex,
            prevValue,
            _modifiedValueIndex,
            modifiedValue
        );
    }

    function getAllMembers() external view returns (address[] memory) {
        return allHolders;
    }

    function getCurrentMemberCount() external view returns (uint) {
        return currentMemberCount;
    }

    function getAttributeNames() external view returns (bytes32[] memory) {
        return attributeNames;
    }

    function getAttributes(address _to) external view returns (uint[] memory) {
        require(_to != address(0), "Address cannot be zero");
        return currentHolders[_to].data;
    }

    function getAttributeExhaustiveCollection(uint _index) external view returns (bytes32[] memory) {
        return attributeValueCollection[_index];
    }

    function getAttributeByIndex(address _who, uint _attributeIndex) external view returns (uint) {
        require(currentHolders[_who].data.length > _attributeIndex, "data doesn't exist for the user");
        return currentHolders[_who].data[_attributeIndex];
    }

    function isCurrentMember(address _who) public view returns (bool) {
        require(_who != address(0), "Zero address can't be a member");
        return currentHolders[_who].to > now && now > currentHolders[_who].from;
    }

    function _assign(address _who, uint[] memory _attributeIndexes) internal {
        require(_who != address(0), "Can't assign to zero address");
        require(_attributeIndexes.length == attributeNames.length, "Need to input all attributes");

        for (uint index = 0; index < _attributeIndexes.length; index++) {
            currentHolders[_who].data.push(_attributeIndexes[index]);
        }
    }

    function _revoke(address _from) internal {
        require(_from != address(0), "Can't revoke from zero address");
        MemberData storage member = currentHolders[_from];
        member.to = now;
        currentMemberCount -= 1;
    }

    function _getEndDate(bytes32 _level) internal returns (uint256) {
        return now + 365 days;
    }

    // function _getMembershipLevelForMember(address _who) internal view returns (bytes32) {
    //     //6d656d626572736869706c6576656c
    //     return currentHolders[_who].data[0];
    // }
}