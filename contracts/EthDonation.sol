// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract EthDonation {

  // owner is the owner of the contract
  address payable public owner;
  uint projectCount;
  // TODO: evaluate whether projectBalances is useful
  mapping(uint => uint256) private projectBalances; // projectId to project balance
  mapping(uint => Project) public projects; // projectId to project

  enum ExpenseState {
    Pending,
    Approved
  }

  event LogDonationMade(address donatorAddress, uint256 amount, uint projectId);
  event LogExpenseApproved(uint projectId, uint expenseId, address approver);
  event LogExpenseAllocated(uint projectId, uint expenseId, uint256 allocation);
  event LogExpenseAllocationFailure(uint projectId, uint expenseId, uint256 allocation);
  event LogRefund(uint projectId, address donator, uint256 amount);
  event LogRefundFailure(uint projectId, address donator, uint256 amount);

  constructor() payable {
    owner = payable(msg.sender);
  }

  struct Donation {
    uint256 total;
    uint256 available;
    bool refunded;
  }

  // Project is the information of the project to be funded by donators 
  struct Project {
    address payable founder;
    string title;
    string description;
    uint endTime;
    // TODO: check if it is useful
    // the total amount funded, but it is temperorally stored in the contract balances
    uint256 amountFunded;
    // the amount that has been allocated to the founder - expenses approved
    uint256 amountAllocated;
    // mapping of each donator to the amount, if the amount is partially consumed by an expense,
    // the amount is the left amount of that donator
    mapping(address => Donation) donations;
    uint expenseCount;
    mapping(uint => Expense) expenses;
  }

  // Expense is the detail of a single expense item in a project
  // 
  struct Expense {
    // TODO: check whether expenseId is useful
    // uint expenseId;
    string description;
    uint256 allocation;
    uint256 approvedAmount;
    ExpenseState state;
  }

  // createProject creates a project to be donated with project title, description and the project endTime
  function createProject(string memory _title, string memory _description, uint _endTime) public returns(uint) {
    require(_endTime > block.timestamp);
    projectCount += 1;
    Project storage proj = projects[projectCount];
    proj.founder = payable(msg.sender);
    proj.title= _title;
    proj.description= _description;
    proj.endTime= _endTime;
    return projectCount;
  }

  // donate collects the amount of ETH from donator and transfer to the project founder's account
  function donate(uint projectId) public payable {
    require(msg.value > 0);
    require(projects[projectId].endTime > block.timestamp);
    
    Project storage proj = projects[projectId];
    proj.amountFunded += msg.value;
    Donation storage donation = proj.donations[msg.sender];
    donation.total += msg.value;
    donation.available += msg.value;
    emit LogDonationMade(msg.sender, msg.value, projectId);
  }

  // refund donations to the original donator if the project ends and there are donations left
  function refund(uint projectId) public {
    require(projectId >= 1 && projectId <= projectCount);
    // project should be ended
    require(projects[projectId].endTime < block.timestamp);
    // msg.sender should be one of the donator and has available amount
    require(projects[projectId].donations[msg.sender].available > 0);

    Project storage proj = projects[projectId];
    uint256 amount = proj.donations[msg.sender].available;
    Donation storage dona = proj.donations[msg.sender];
    dona.available = 0;
    dona.refunded = true;
    (bool success, ) = msg.sender.call{value: amount}("");
    if (success) {
      emit LogRefund(projectId, msg.sender, amount);
    } else {
      emit LogRefundFailure(projectId, msg.sender, amount);
      dona.available = amount;
      dona.refunded = false;
    }
  }

  // createExpense creates an expense to a project
  function createExpense(uint projectId, uint256 allocation, string memory description) public returns(uint) {
    require(projects[projectId].founder == msg.sender);
    require(projectId >= 1 && projectId <= projectCount);
    require(allocation > 0);

    Project storage proj = projects[projectId];
    uint expenseId = proj.expenseCount + 1;
    Expense storage exps = proj.expenses[expenseId];
    exps.description = description;
    exps.allocation = allocation;
    exps.state = ExpenseState.Pending;
    proj.expenseCount += 1;
    return expenseId;
  }

  function getExpense(uint projectId, uint expenseId) public view returns (string memory, uint256, uint256, uint) {
    require(projectId >= 1 && projectId <= projectCount);
    require(expenseId >= 1 && expenseId <= projects[projectId].expenseCount);
    require(projects[projectId].expenses[expenseId].allocation > 0);

    Expense storage exp = projects[projectId].expenses[expenseId];
    return (exp.description, exp.allocation, exp.approvedAmount, uint(exp.state));
  }

  function getMyDonation(uint projectId) public view returns (uint256, uint256) {
    require(projectId >= 1 && projectId <= projectCount);
    require(projects[projectId].donations[msg.sender].total > 0, "you must be one of the donators");

    Donation memory dona = projects[projectId].donations[msg.sender];
    return (dona.total, dona.available);
  }

  // approveExpense approves an expense to a project
  // when the total approved amount is greater than or equal to the allocation for the proposed expense
  // the approved amount will be transferred to the project founder's address
  function approveExpense(uint projectId, uint expenseId) public {
    // projectId should be valid
    require(projectId >= 1 && projectId <= projectCount);
    // msg.sender should be one of the donator and has available amount
    require(projects[projectId].donations[msg.sender].available > 0);
    // expenseId should be valid
    require(expenseId >= 1 && expenseId <= projects[projectId].expenseCount);
    // expense should be in pending state
    require(projects[projectId].expenses[expenseId].state == ExpenseState.Pending);

    Project storage project = projects[projectId];
    Expense storage expense = project.expenses[expenseId];
    uint256 amountToApprove = Math.min(expense.allocation - expense.approvedAmount, project.donations[msg.sender].available);
    expense.approvedAmount += amountToApprove;
    project.donations[msg.sender].available -= amountToApprove;
    emit LogExpenseApproved(projectId, expenseId, msg.sender);
    if (expense.approvedAmount == expense.allocation) {  // expense allocation is filled, yay
      expense.state = ExpenseState.Approved;
      project.amountAllocated += expense.allocation;
      (bool success, ) = project.founder.call{value:expense.allocation}("");
      if (success) {
        emit LogExpenseAllocated(projectId, expenseId, expense.allocation);
      } else {
        emit LogExpenseAllocationFailure(projectId, expenseId, expense.allocation);
        expense.state = ExpenseState.Pending;
        project.amountAllocated -= expense.allocation;
      }
    }
  }
}
