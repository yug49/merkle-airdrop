// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {RandomToken} from "../src/RandomToken.sol";
import {Script, console} from "../lib/forge-std/src/Script.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private constant ROOT = 0x0569dd132882dfc2838c8ec05a2399ff4a07db34e3a54d4bb0f1d14d6adb41b7;
    uint256 private constant AMOUNT_TO_MINT = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, RandomToken) {
        vm.startBroadcast();
        RandomToken token = new RandomToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(address(token)));
        token.mint(token.owner(), AMOUNT_TO_MINT);
        token.transfer(address(airdrop), AMOUNT_TO_MINT);
        vm.stopBroadcast();

        console.log("MerkleAirdrop deployed to: ", address(airdrop));
        console.log("RandomToken deployed to: ", address(token));

        return (airdrop, token);
    }

    function run() external returns(MerkleAirdrop, RandomToken) {
        return deployMerkleAirdrop();
    }
}