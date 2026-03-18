# 🔐 ReceiverPays — Off-Chain Payment Channels in Solidity

> Part of my Solidity learning journey — implementing cryptographic payment channels from scratch.

[![Solidity](https://img.shields.io/badge/Solidity-0.8.x-363636?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Tested_with-Foundry-red)](https://book.getfoundry.sh/)
[![Tests](https://img.shields.io/badge/Tests-6%20passing-brightgreen)]()

---

## What this is

A smart contract that lets an **owner pre-fund ETH** so recipients can claim payments later — just by presenting a valid **off-chain signature**. No repeated on-chain transactions from the sender needed.

This is the foundation of **unidirectional payment channels**: sign once off-chain, settle on-chain whenever you want.

---

## How it works

```
Alice deploys contract + deposits ETH
        │
        ▼
Alice signs off-chain: keccak256(receiver, amount, nonce, contractAddress)
        │
        ▼
Bob calls claimPayment(amount, nonce, signature)
        │
        ▼
Contract verifies signature → sends ETH to Bob
```

The contract never trusts who's calling — it **recovers the signer** from the signature using `ecrecover` and checks it matches the owner.

---

## Key concepts I implemented

| Concept                                     | Where                |
| ------------------------------------------- | -------------------- |
| `ecrecover` for signature verification      | `recoverSigner()`    |
| Manual signature splitting via assembly     | `splitSignature()`   |
| Ethereum prefix hash (`eth_sign` standard)  | `prefixed()`         |
| Nonce tracking to prevent replay attacks    | `usedNonces` mapping |
| `abi.encodePacked` for message construction | `claimPayment()`     |

---

## Replay attack prevention

Each signature includes a **nonce** that gets marked as used after the first claim.

```solidity
require(!usedNonces[nonce]);
usedNonces[nonce] = true;
```

The contract address is also packed into the signed message — so a valid signature on one deployment **cannot be reused** on another.

---

## Tests (Foundry)

All 6 tests passing with realistic actors: Alice (owner + signer), Bob (receiver), Carol (adversary).

| Test                                    | What it checks                                       |
| --------------------------------------- | ---------------------------------------------------- |
| `testSetUp`                             | Owner is Alice, contract holds 10 ETH                |
| `testClaimPayment`                      | Bob successfully claims 1 ETH with a valid signature |
| `testCannotReuseNonce`                  | Second claim with same nonce reverts                 |
| `testClaimPaymentFailsForWrongReceiver` | Carol can't use a signature meant for Bob            |
| `testShutdownByOwner`                   | Alice reclaims all funds via `selfdestruct`          |
| `testShutdownFailsForNonOwner`          | Bob can't shut down the contract                     |

```bash
forge test -v
```

---

## Run it yourself

```bash
git clone <this-repo>
cd receiverpays
forge install
forge test
```

---

## What I'm learning

I'm currently going through the [Solidity docs](https://docs.soliditylang.org/) and building each concept hands-on. This project covers:

- Cryptographic signature verification on-chain
- Low-level `assembly` for byte manipulation
- Security patterns (nonce, address binding, replay protection)
- Testing adversarial scenarios with Foundry's `vm.prank` and `vm.expectRevert`

---

## About me

I'm a data scientist expanding into blockchain development — bringing the same rigorous, test-driven approach I use in Python to smart contract engineering.

🔗 [LinkedIn](https://www.linkedin.com/in/ichbinzeed)
