const EthDonation = artifacts.require("./EthDonation.sol");
let BN = web3.utils.BN;
let { catchRevert } = require("./exceptionsHelpers.js");

contract("EthDonation test", function (accounts) {

  // var instance = null;
  const mainAccount = accounts[0];
  const anotherAccount = accounts[1];
  const _title = "example project title";
  const _description = "example project description";
  const _endTime = Math.ceil(addDays(new Date(), 1) / 1000);
  const _expenseDescription = "example expense description";
  const _expenseAllocation = web3.utils.toWei("1.1");
  const _donateAmount = web3.utils.toWei("2.1");

  beforeEach(async () => {
    instance = await EthDonation.new();
  });

  it("should owned by owner", async () => {
    assert.equal(await instance.owner.call(), mainAccount, "contract owner is incorrect");
  });

  it("should create an project and update project count", async () => {
    const projectCountBefore = await instance.projectCount();
    assert.equal(projectCountBefore, 0);

    await instance.createProject(_title, _description, _endTime, { from: mainAccount });
    const projectCountAfter = await instance.projectCount();
    assert.equal(projectCountAfter, 1);

    const project = await instance.projects(1);

    expectedResult = {
      founder: mainAccount,
      title: _title,
      description: _description,
      endTime: _endTime,
      amountFunded: 0,
      amountAllocated: 0,
      expenseCount: 0,
    };

    assert.equal(
      expectedResult.founder,
      project.founder,
      "created project founder is incorrect",
    );

    assert.equal(
      expectedResult.title,
      project.title,
      "created project title is incorrect",
    );

    assert.equal(
      expectedResult.description,
      project.description,
      "created project description is incorrect",
    );

    assert.equal(
      expectedResult.endTime,
      project.endTime,
      "created project endTime is incorrect",
    );

    assert.equal(
      expectedResult.amountFunded,
      project.amountFunded,
      "created project amountFunded is incorrect",
    );

    assert.equal(
      expectedResult.amountAllocated,
      project.amountAllocated,
      "created project amountAllocated is incorrect",
    );

    assert.equal(
      expectedResult.expenseCount,
      project.expenseCount,
      "created project expenseCount is incorrect",
    );
  });

  it("should create an expense for an existing project", async () => {
    // create a project
    await instance.createProject(_title, _description, _endTime, { from: mainAccount });
    const expenseCountBefore = await instance.getExpenseCount(1);
    assert.equal(expenseCountBefore, 0);
    // create an expense for project 1
    await instance.createExpense(1, _expenseAllocation, _expenseDescription, {from: mainAccount});
    const expenseCountAfter = await instance.getExpenseCount(1);
    assert.equal(expenseCountAfter, 1);
    // get expense result
    const result = await instance.getExpense(1, 1);
    expectedResult = {
      description: _expenseDescription,
      allocation: _expenseAllocation,
      amountApproved: '0',
      state: '0'
    };

    assert.equal(
      expectedResult.description,
      result[0],
      "created expense field description is incorrect",
    );
  
    assert.equal(
      expectedResult.allocation,
      new BN(result[1]).toString(),
      "created expense field allocation is incorrect",
    );

    assert.equal(
      expectedResult.amountApproved,
      new BN(result[2]).toString(),
      "created expense field amountApproved is incorrect",
    );

    assert.equal(
      expectedResult.state,
      new BN(result[3]).toString(),
      "created expense field state is incorrect",
    );

  });

  it("should fail creating an expense for an non-existing project", async () => {
      // create an expense for project not existed
      await catchRevert(instance.createExpense(1, _expenseAllocation, _expenseDescription, {from: mainAccount}));
  });

  it("should update donations after another account donated", async () => {
      // create a project
      await instance.createProject(_title, _description, _endTime, { from: mainAccount });
      // donate to a project from another account
      const tx = await instance.donate(1, { from: anotherAccount, value: _donateAmount });
      assert.equal("LogDonationMade", tx.logs[0].event);
      const project = await instance.projects(1);
      // project info amount funded reflected with donated amount
      assert.equal(project.amountFunded.toString(), _donateAmount);
  });

  it("should update amount allocation after expense approved and allocated", async () => {
      // create a project and expense
      await instance.createProject(_title, _description, _endTime, { from: mainAccount });
      await instance.createExpense(1, _expenseAllocation, _expenseDescription, {from: mainAccount});
      // donate to a project from another account
      await instance.donate(1, { from: anotherAccount, value: _donateAmount });

      const balanceBefore = await web3.eth.getBalance(mainAccount);
      // approve an expense
      const tx = await instance.approveExpense(1, 1, {from: anotherAccount});
      assert.equal("LogExpenseApproved", tx.logs[0].event);
      assert.equal("LogExpenseAllocated", tx.logs[1].event);

      // get project info
      const project = await instance.projects(1);
      // get expense result
      const expense = await instance.getExpense(1, 1);
      assert.equal(project.amountAllocated.toString(), _expenseAllocation);
      assert.equal(new BN(expense[2]).toString(), _expenseAllocation);
      assert.equal(new BN(expense[3]).toString(), 1);

      // approved amount should be transferred to founder's account
      const balanceAfter = await web3.eth.getBalance(mainAccount);
      assert.equal((balanceAfter - balanceBefore).toString(), _expenseAllocation);
  });

  it("should update amount allocation after expense approved but state is pending since approved amount is not reached to allocation", async () => {
    // create a project and expense
    await instance.createProject(_title, _description, _endTime, { from: mainAccount });
    await instance.createExpense(1, _expenseAllocation, _expenseDescription, {from: mainAccount});
    // donate to a project from another account
    const tempDonateAmount = web3.utils.toWei("1");
    await instance.donate(1, { from: anotherAccount, value: tempDonateAmount });

    const balanceBefore = await web3.eth.getBalance(mainAccount);
    // approve an expense
    const tx = await instance.approveExpense(1, 1, {from: anotherAccount});
    assert.equal("LogExpenseApproved", tx.logs[0].event);

    // get project info
    const project = await instance.projects(1);
    // get expense result
    const expense = await instance.getExpense(1, 1);
    assert.equal(project.amountAllocated, 0);
    assert.equal(new BN(expense[2]).toString(), tempDonateAmount); // amount approved
    assert.equal(new BN(expense[3]).toString(), 0);

    // approved amount has not been transferred to founder's account
    const balanceAfter = await web3.eth.getBalance(mainAccount);
    assert.equal(balanceAfter - balanceBefore, 0);
  });
});



function addDays(date, days) {
  var result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}


