// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Events definition for charity funding with ether donations
/// @author Pengyang Zhou
/// @notice Events definition
contract DonationEvents {

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
}