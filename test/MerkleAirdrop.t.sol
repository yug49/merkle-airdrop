//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {RandomToken} from "../src/RandomToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    RandomToken public token;

    uint256 public constant AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public constant AMOUNT_TO_MINT = 4 * AMOUNT_TO_CLAIM;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0x3daa16ff013540280ab04f47046fbf370a0704b8ab404f4caa60aedcbc3d5326;
    bytes32[] public PROOF = [proofOne, proofTwo];

    bytes32 public ROOT = 0xfa1ebfe7e2ebaa4564d7e1fa95818b2ccc76d58a6b8a6303df2af2ae37cb4669;
    address user;
    uint256 userPrivKey;
    address public gasPayer;

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.deployMerkleAirdrop();
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        //sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        //gas payer calls claim using signed message
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance of the user: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
