// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Contract for charity funding with ether donations
/// @author Pengyang Zhou
/// @notice Allows users to propose charity funding project and expense and get donations
/// @dev EthDonation is contract manages charity projects. A project founder proposes a project,
/// and adds expenses plans. A donator or investor donates to a project and approve expense according
/// to their available donations.
contract EthDonation is Ownable{
  
  /// @dev Tracks total project count
  uint public projectCount;

  /// @dev Tracks mapping between project ID and project detail
  mapping(uint => Project) public projects;

  /// @dev ExpenseState is the two states of an expense
  enum ExpenseState {
    Pending,
    Approved
  }

  /// @notice Emitted when a new donation is made to a project
  /// @param donatorAddress Donator Address
  /// @param amount Donation amount
  /// @param projectId Project ID
  event LogDonationMade(address donatorAddress, uint256 amount, uint projectId);

  /// @notice Emitted when an expense is approved from a donator
  /// @param projectId Project ID
  /// @param expenseId Expense ID
  /// @param approver Approver Address
  event LogExpenseApproved(uint projectId, uint expenseId, address approver);

  /// @notice Emitted when an expense reached to an approved state and allocation will be transferred
  /// @param projectId Project ID
  /// @param expenseId Expense ID
  /// @param allocation Allocation amount
  event LogExpenseAllocated(uint projectId, uint expenseId, uint256 allocation);

  /// @notice Emitted when an expense reached to an approved state and but allocation transfer is failed
  /// @param projectId Project ID
  /// @param expenseId Expense ID
  /// @param allocation Allocation amount
  event LogExpenseAllocationFailure(uint projectId, uint expenseId, uint256 allocation);

  /// @notice Emitted when a refund is made to a donator
  /// @param projectId Project ID
  /// @param donator Donator Address
  /// @param amount Refund amount
  event LogRefund(uint projectId, address donator, uint256 amount);

  /// @notice Emitted when a refund to a donator is failed
  /// @param projectId Project ID
  /// @param donator Donator Address
  /// @param amount Refund amount
  event LogRefundFailure(uint projectId, address donator, uint256 amount);

  constructor() {
  }

  /// @dev Donation tracks donations from a donator with total amount and available amount
  /// to approve expenses. If an expense is approved, the available amount will be substracted
  /// by the approved amount.
  struct Donation {
    uint256 total;
    uint256 available;
    bool refunded;
  }

  /// @dev Project is the information of the project to be funded by donators
  /// amountFunded tracks the total amount funded and it is temperorally stored in the contract balances
  /// amountAllocated tracks the amount that has been allocated to the founder.
  struct Project {
    address payable founder;
    string title;
    string description;
    uint endTime;
    uint256 amountFunded;
    uint256 amountAllocated;
    uint expenseCount;
    address[] donators;
    mapping(address => Donation) donations;
    mapping(uint => Expense) expenses;
  }

  /// @dev Expense is the detail of a single expense item in a project
  struct Expense {
    string description;
    uint256 allocation;
    uint256 approvedAmount;
    ExpenseState state;
  }

  /// @notice Creates a project to be donated with project title, description and the project end time
  /// @param _title Project title
  /// @param _description Project description
  /// @param _endTime Project end time in unix seconds
  /// @return Returns project ID
  function createProject(string memory _title, string memory _description, uint _endTime) public returns(uint) {
    require(_endTime > block.timestamp);
    projectCount += 1;
    Project storage proj = projects[projectCount];
    proj.founder = payable(msg.sender);
    proj.title= _title;
    // TODO: project description could be optimized to use S3 along with more functionalities like adding images
    proj.description= _description;
    proj.endTime= _endTime;
    return projectCount;
  }

  /// @notice Donates the amount of ETH from donator and temporally stored in the contract address
  /// @param projectId Project ID
  function donate(uint projectId) public payable {
    require(msg.value > 0);
    require(projects[projectId].endTime > block.timestamp);
    Project storage proj = projects[projectId];
    proj.amountFunded += msg.value;
    Donation storage donation = proj.donations[msg.sender];
    if (donation.total == 0) {
      proj.donators.push(msg.sender);
    }
    donation.total += msg.value;
    donation.available += msg.value;
    emit LogDonationMade(msg.sender, msg.value, projectId);
  }

  /// @notice Refunds donations to the original donator if the project ends and there are their donations left
  /// @param projectId Project ID
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

  /// @notice Creates an expense for a project
  /// @param projectId Project ID
  /// @param allocation Expense allocation asked
  /// @param description Expense description
  /// @return Returns expense ID
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

  /// @notice Gets expense count for a project
  /// @param projectId Project ID
  /// @return Returns expense count
  function getExpenseCount(uint projectId) public view returns (uint) {
    require(projectId >= 1 && projectId <= projectCount);
    return projects[projectId].expenseCount;
  }

  /// @notice Gets an expense by expense ID and project ID
  /// @param projectId Project ID
  /// @param expenseId Expense ID
  /// @return Returns expense detail with description, allocation, amount approved and state
  function getExpense(uint projectId, uint expenseId) public view returns (string memory, uint256, uint256, uint) {
    require(projectId >= 1 && projectId <= projectCount);
    require(expenseId >= 1 && expenseId <= projects[projectId].expenseCount);
    require(projects[projectId].expenses[expenseId].allocation > 0);

    Expense storage exp = projects[projectId].expenses[expenseId];
    return (exp.description, exp.allocation, exp.approvedAmount, uint(exp.state));
  }

  /// @notice Gets the donation a project of a caller
  /// @param projectId Project ID
  /// @return Returns the total donation amount and the available amount 
  function getMyDonation(uint projectId) public view returns (uint256, uint256) {
    require(projectId >= 1 && projectId <= projectCount);
    require(projects[projectId].donations[msg.sender].total > 0, "you must be one of the donators");
    Donation memory dona = projects[projectId].donations[msg.sender];
    return (dona.total, dona.available);
  }

  /// @notice Gets the donations a project
  /// @param projectId Project ID
  /// @return Returns a list of donators, a list of their total donation amounts, and a list of their the available amounts
  function getDonations(uint projectId) public view returns (address[] memory, uint256[] memory, uint256[] memory){
    require(projectId >= 1 && projectId <= projectCount);

    Project storage proj = projects[projectId];
    uint length = proj.donators.length;
    address[] memory donators = new address[](length);
    uint256[] memory allocations = new uint256[](length);
    uint256[] memory availables = new uint256[](length);

    for (uint i = 0; i < length; i++) {
      address donator = proj.donators[i];
      Donation memory dona = proj.donations[donator];
      donators[i] = donator;
      allocations[i] = dona.total;
      availables[i] = dona.available;
    }
    return (donators, allocations, availables);
  }

  /// @notice Approves an expense of a project
  /// @dev When the total approved amount is greater than or equal to the allocation for the proposed expense
  /// the approved amount will be transferred to the project founder's address
  function approveExpense(uint projectId, uint expenseId) public {
    /// projectId should be valid
    require(projectId >= 1 && projectId <= projectCount);
    /// msg.sender should be one of the donator and has available amount
    require(projects[projectId].donations[msg.sender].available > 0);
    /// expenseId should be valid
    require(expenseId >= 1 && expenseId <= projects[projectId].expenseCount);
    /// expense should be in pending state
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
