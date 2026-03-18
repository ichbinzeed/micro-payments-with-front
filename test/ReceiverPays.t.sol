// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ReceiverPays.sol";

contract ReceiverPaysTest is Test {
    ReceiverPays public receiverPays;

    // Create Alice with her private key
    uint256 alicePrivKey = 0x1234;
    address alice = vm.addr(alicePrivKey);

    // Bob will be the one who receives the money
    address bob = address(0xB0B);

    // Carol will be used for negative tests
    address carol = address(0xCA11);

    function setUp() public {
        vm.deal(alice, 10 ether);
        // Alice deploys the contract with 10 ETH
        vm.prank(alice);
        receiverPays = new ReceiverPays{value: 10 ether}();
    }

    function testSetUp() public view {
        address owner = receiverPays._owner();
        assertEq(owner, alice);
        assertEq(address(receiverPays).balance, 10 ether);
    }

    function testClaimPayment() public {
        uint256 amount = 1 ether;
        uint256 nonce = 1;
        bytes memory signature = signPayment(bob, amount, nonce);

        // 3. EXECUTE THE CLAIM (Bob calls the function)
        uint256 initialBalance = bob.balance;

        vm.prank(bob); // The msg.sender is now Bob
        receiverPays.claimPayment(amount, nonce, signature);

        // 4. VERIFY
        assertEq(bob.balance, initialBalance + amount);
        assertTrue(receiverPays.isNonceUsed(nonce));
    }

    function testCannotReuseNonce() public {
        uint256 amount = 1 ether;
        uint256 nonce = 1;
        bytes memory signature = signPayment(bob, amount, nonce);

        // First claim works and marks the nonce as used.
        vm.prank(bob);
        receiverPays.claimPayment(amount, nonce, signature);

        // Second claim with the same nonce must fail.
        vm.expectRevert();
        vm.prank(bob);
        receiverPays.claimPayment(amount, nonce, signature);
    }

    function testClaimPaymentFailsForWrongReceiver() public {
        uint256 amount = 1 ether;
        uint256 nonce = 1;

        // Alice signs a payment for Bob, not for Carol.
        bytes memory signature = signPayment(bob, amount, nonce);

        // Carol tries to use Bob's signature, so the call must fail.
        vm.expectRevert();
        vm.prank(carol);
        receiverPays.claimPayment(amount, nonce, signature);
    }

    function testShutdownByOwner() public {
        // The owner can close the contract and get the remaining ETH.
        vm.prank(alice);
        receiverPays.shutdown();

        assertEq(address(receiverPays).balance, 0);
        assertEq(alice.balance, 10 ether);
    }

    function testShutdownFailsForNonOwner() public {
        // A non-owner cannot close the contract.
        vm.expectRevert();
        vm.prank(bob);
        receiverPays.shutdown();
    }

    function signPayment(address receiver, uint256 amount, uint256 nonce) internal view returns (bytes memory) {
        // Recreate the same message that the contract will check.
        bytes32 messageHash = keccak256(abi.encodePacked(receiver, amount, nonce, address(receiverPays)));

        // Convert it to the Ethereum signed message hash.
        bytes32 ethSignedMessageHash = toEthSignedMessageHash(messageHash);

        // Sign the final digest with Alice's private key.
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivKey, ethSignedMessageHash);

        return abi.encodePacked(r, s, v);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
