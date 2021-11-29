# Design Patterns

## Inheritance and Interfaces

- The main contract `EthDonation.sol` imports `DonationEvents.sol` contract and inherits `@openzeppelin/contracts/access/Ownable.sol"` ([link](https://docs.openzeppelin.com/contracts/4.x/access-control#ownership-and-ownable)). It also imports `@openzeppelin/contracts/utils/math/Math.sol` ([link](https://docs.openzeppelin.com/contracts/4.x/api/utils#Math)) to call `Math.min(a, b)`.

## Access Control Design Patterns

- `Ownable` design pattern is used in this contract. Right now, function `migrateTo` is designed to `onlyOwner` that allows the owner to migrate all funds to a different address in an emergency. 

- I plan to upgrade it to Role-Based Access Control with at least three roles: `administors`, `founders`, `donators`.

## Upgradable Contracts

- TODO: Future plan is to optimize the design to an upgradable contract to allow state and data transferrable.