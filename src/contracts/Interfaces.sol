pragma solidity ^0.5.8;

/// @title ERC-1261 MVT Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1261.md
///  The constructor should define the attribute set for this MVT.
///  Note: the ERC-165 identifier for this interface is 0x1d8362cf.
interface IERC1261 {/* is ERC173, ERC165 */
    /// @dev This emits when a token is assigned to a member.
    event Assigned(address indexed _to, uint[] attributeIndexes);

    /// @dev This emits when a membership is revoked.
    event Revoked(address indexed _to);

    /// @dev This emits when a user forfeits his membership
    event Forfeited(address indexed _to);

    /// @dev This emits when a membership request is accepted
    event ApprovedMembership(address indexed _to, uint[] attributeIndexes);

    /// @dev This emits when a membership is requested by an user
    event RequestedMembership(address indexed _to);

    /// @dev This emits when data of a member is modified.
    ///  Doesn't emit when a new membership is created and data is assigned.
    event ModifiedAttributes(address indexed _to, uint attributeIndex, uint attributeValueIndex);

    /// @notice Adds a new attribute (key, value) pair to the set of pre-existing attributes.
    /// @dev Adds a new attribute at the end of the array of attributes and maps it to `values`.
    ///  Contract can set a max number of attributes and throw if limit is reached.
    /// @param _name Name of the attribute which is to be added.
    /// @param values List of values of the specified attribute.
    function addAttributeSet(bytes32 _name, bytes32[] calldata values) external;

    /// @notice Modifies the attribute value of a specific attribute for a given `_to` address.
    /// @dev Use appropriate checks for whether a user/admin can modify the data.
    ///  Best practice is to use onlyOwner modifier from ERC173.
    /// @param _to The address whose attribute is being modified.
    /// @param _attributeIndex The index of attribute which is being modified.
    /// @param _modifiedValueIndex The index of the new value which is being assigned to the user attribute.
    function modifyAttributeByIndex(address _to, uint _attributeIndex, uint _modifiedValueIndex) external;

    /// @notice Requests membership from any address.
    /// @dev Throws if the `msg.sender` already has the token.
    ///  The individual `msg.sender` can request for a membership if some existing criteria are satisfied.
    ///  When a membership is requested, this function emits the RequestedMembership event.
    ///  dev can store the membership request and use `approveRequest` to assign membership later
    ///  dev can also oraclize the request to assign membership later
    /// @param _attributeIndexes the attribute data associated with the member.
    ///  This is an array which contains indexes of attributes.
    function requestMembership(uint[] calldata _attributeIndexes) external payable;

    /// @notice User can forfeit his membership.
    /// @dev Throws if the `msg.sender` already doesn't have the token.
    ///  The individual `msg.sender` can revoke his/her membership.
    ///  When the token is revoked, this function emits the Revoked event.
    function forfeitMembership() external payable;

    /// @notice Owner approves membership from any address.
    /// @dev Throws if the `_user` doesn't have a pending request.
    ///  Throws if the `msg.sender` is not an owner.
    ///  Approves the pending request
    ///  Make oraclize callback call this function
    ///  When the token is assigned, this function emits the `ApprovedMembership` and `Assigned` events.
    /// @param _user the user whose membership request will be approved.
    function approveRequest(address _user) external;

    /// @notice Owner discards membership from any address.
    /// @dev Throws if the `_user` doesn't have a pending request.
    ///  Throws if the `msg.sender` is not an owner.
    ///  Discards the pending request
    ///  Make oraclize callback call this function if criteria are not satisfied
    /// @param _user the user whose membership request will be discarded.
    function discardRequest(address _user) external;

    /// @notice Assigns membership of an MVT from owner address to another address.
    /// @dev Throws if the member already has the token.
    ///  Throws if `_to` is the zero address.
    ///  Throws if the `msg.sender` is not an owner.
    ///  The entity assigns the membership to each individual.
    ///  When the token is assigned, this function emits the Assigned event.
    /// @param _to The address to which the token is assigned.
    /// @param _attributeIndexes The attribute data associated with the member.
    ///  This is an array which contains indexes of attributes.
    function assignTo(address _to, uint[] calldata _attributeIndexes) external;

    /// @notice Only Owner can revoke the membership.
    /// @dev This removes the membership of the user.
    ///  Throws if the `_from` is not an owner of the token.
    ///  Throws if the `msg.sender` is not an owner.
    ///  Throws if `_from` is the zero address.
    ///  When transaction is complete, this function emits the Revoked event.
    /// @param _from The current owner of the MVT.
    function revokeFrom(address _from) external;

    /// @notice Queries whether a member is a current member of the organization.
    /// @dev MVT's assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _to An address for whom to query the membership.
    /// @return Whether the member owns the token.
    function isCurrentMember(address _to) external view returns (bool);

     /// @notice Gets the value collection of an attribute.
    /// @dev Returns the values of attributes as a bytes32 array.
    /// @param _name Name of the attribute whose values are to be fetched
    /// @return The values of attributes.
    function getAttributeExhaustiveCollection(bytes32 _name) external view returns (bytes32[] memory);

    /// @notice Returns the list of all past and present members.
    /// @dev Use this function along with isCurrentMember to find wasMemberOf() in Js.
    ///  It can be calculated as present in getAllMembers() and !isCurrentMember().
    /// @return List of addresses who have owned the token and currently own the token.
    function getAllMembers() external view returns (address[] memory);

    /// @notice Returns the count of all current members.
    /// @dev Use this function in polls as denominator to get percentage of members voted.
    /// @return Count of current Members.
    function getCurrentMemberCount() external view returns (uint);

    /// @notice Returns the list of all attribute names.
    /// @dev Returns the names of attributes as a bytes32 array.
    ///  AttributeNames are stored in a bytes32 Array.
    ///  Possible values for each attributeName are stored in a mapping(attributeName => attributeValues).
    ///  AttributeName is bytes32 and attributeValues is bytes32[].
    ///  Attributes of a particular user are stored in bytes32[].
    ///  Which has a single attributeValue for each attributeName in an array.
    ///  Use web3.toAscii(data[0]).replace(/\u0000/g, "") to convert to string in JS.
    /// @return The names of attributes.
    function getAttributeNames() external view returns (bytes32[] memory);

    /// @notice Returns the attributes of `_to` address.
    /// @dev Throws if `_to` is the zero address.
    ///  Use web3.toAscii(data[0]).replace(/\u0000/g, "") to convert to string in JS.
    /// @param _to The address whose current attributes are to be returned.
    /// @return The attributes associated with `_to` address.
    function getAttributes(address _to) external view returns (bytes32[] memory);

    /// @notice Returns the `attribute` stored against `_to` address.
    /// @dev Finds the index of the `attribute`.
    ///  Throws if the attribute is not present in the predefined attributes.
    ///  Returns the attributeValue for the specified `attribute`.
    /// @param _to The address whose attribute is requested.
    /// @param _attributeIndex The attribute Index which is required.
    /// @return The attribute value at the specified name.
    function getAttributeByIndex(address _to, uint _attributeIndex) external view returns (bytes32);
}

interface IERC173 /* is ERC165 */ {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return The address of the owner.
    function owner() external view;

    /// @notice Set the address of the new owner of the contract
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}