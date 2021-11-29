# Contract security measures

## SWC-104 (Unchecked Call Return Value) and Favor pull over push for external calls

Low-level call methods `address.call()` is handled by checking the return value. E.g.
```
    //   function refund(uint projectId) public
    (bool success, ) = project.founder.call{value:expense.allocation}("");
    if (success) {
        emit LogExpenseAllocated(projectId, expenseId, expense.allocation);
    } else {
        emit LogExpenseAllocationFailure(projectId, expenseId, expense.allocation);
        expense.state = ExpenseState.Pending;
        project.amountAllocated -= expense.allocation;
    }
```
and 
```
    //   function approveExpense(uint projectId, uint expenseId) public {
    (bool success, ) = msg.sender.call{value: amount}("");
    if (success) {
      emit LogRefund(projectId, msg.sender, amount);
    } else {
      emit LogRefundFailure(projectId, msg.sender, amount);
      dona.available = amount;
      dona.refunded = false;
    }
```

## SWC-105 (Unprotected Ether Withdrawal)

`refund` is protected by requiring the caller should be one of the donators to the target project, and they will only be refunded with the available amount and it will not be more than they paid. The available amount is set to 0 after refund. E.g.

```
    function refund(uint projectId) public {
        require(projectId >= 1 && projectId <= projectCount);
        // project should be ended
        require(projects[projectId].endTime < block.timestamp);
        // msg.sender should be one of the donator and has available amount
        require(projects[projectId].donations[msg.sender].available > 0);
        ...
    }
```