// SPDX-License-Identifier: MIT

/**
 * @title MerkleAirdrop
 * @author Yug Agarwal
 * @notice This contract allows a list of claimers to claim ERC-20 tokens based on a Merkle proof.
 */
pragma solidity ^0.8.24;

import {RandomToken} from "./RandomToken.sol";
import {IERC20, SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract MerkleAirdrop is ReentrancyGuard {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    // some list of addresses
    // allow someone in the list to claim ERC-20 tokens
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    event Claimed(address indexed account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /**
     *
     * @param account recipient address
     * @param amount amount of tokens to be claimed
     * @param merkleProof array of bytes32 hashes that prove the account is in the merkle tree
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external nonReentrant {
        // check if the account has already claimed
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount)))); // keccak256 hash is used twice to prevent second preimage attack i.e. sometime different account, amount can generate same hash and hash collisions could happen, to prevent this we hash it twice

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[account] = true;

        // transfer the tokens to the account
        i_airdropToken.safeTransfer(account, amount);

        // emit an event
        emit Claimed(account, amount);
    }

    function getMerkelRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
