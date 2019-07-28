const Contract = artifacts.require("MembershipVerificationToken");

contract("MembershipVerificationToken", function(accounts) {
  const OWNER = accounts[0];
  const ALICE = accounts[1];
  const BOB = accounts[2];

  let contractInstance;

  beforeEach(async function () {
    contractInstance = await Contract.new();
  });

  describe("MembershipVerificationToken tests", () => {
    it("should add member level attibute set", async function () {
      await contractInstance.addAttributeSet("0x4c6576656c", ["0x4c696665"]);
    });
  });

  describe("Membership application tests", () => {
    beforeEach(async function () {
      //type
      await contractInstance.addAttributeSet("0x74797065", ["0x4c696665"]);
      //0x74797065
      //await contractInstance.addAttributeSet("0x4c6576656c", ["0x4c696665"]);
    });

    it("should get type attribute", async function () {
      await contractInstance.requestMembership([0], {value: 1000, from: ALICE});

      var isMember = await contractInstance.isCurrentMember(ALICE);
      assert.isFalse(isMember);
      
      await contractInstance.approveRequest(ALICE);
      isMember = await contractInstance.isCurrentMember(ALICE);
      assert.isTrue(isMember);
    });

    it("should apply for life member", async function () {
      await contractInstance.requestMembership([0], {value: 1000, from: ALICE});

      var isMember = await contractInstance.isCurrentMember(ALICE);
      assert.isFalse(isMember);
      
      await contractInstance.approveRequest(ALICE);
      isMember = await contractInstance.isCurrentMember(ALICE);
      assert.isTrue(isMember);
    });
  });
});