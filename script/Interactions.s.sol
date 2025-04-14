// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {
    error Interactions__ClaimAirdrop_InvalidSignatureLength();

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25000000000000000000;
    bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO = 0x3daa16ff013540280ab04f47046fbf370a0704b8ab404f4caa60aedcbc3d5326;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private signature =
        hex"ac1511dded56ec94d8290d8dc9ca84370ff3cb711b0593991275156123e2432f5385f80b0c037a1b97709b44083742b2fd3a4b442ffeba2fb0ea9a8987b87a6e1c";

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert Interactions__ClaimAirdrop_InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
