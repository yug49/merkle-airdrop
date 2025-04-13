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
    bytes32 proofOne = 0xb33df583925c44788716f78d82bca93cd5716721eefd680cdf5a2146a61f5832;
    bytes32 proofTwo = 0x3daa16ff013540280ab04f47046fbf370a0704b8ab404f4caa60aedcbc3d5326;
    bytes32[] public PROOF = [proofOne, proofTwo];

    bytes32 public ROOT = 0x0569dd132882dfc2838c8ec05a2399ff4a07db34e3a54d4bb0f1d14d6adb41b7;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.deployMerkleAirdrop();
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance of the user: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
