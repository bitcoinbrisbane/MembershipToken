const Contract = artifacts.require("MembershipVerificationToken");

contract("MembershipVerificationToken", function(accounts) {
  const OWNER = accounts[0];
  const ALICE = accounts[1];
  const BOB = accounts[2];

  let contractInstance;

  beforeEach(async function () {
    contractInstance = await Contract.new();
  });

  describe.only("MembershipVerificationToken tests", () => {
    it("should add member level attibute set", async function () {
      await contractInstance.addAttributeSet("0x4c6576656c", ["0x4c696665"]);

      // const actual = await tokenInstance._inventory(0);
      // assert.equal(Number(actual[0]), 100, "Stock not correct");
    });
  });
});