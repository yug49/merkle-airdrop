
# merkle-airdrop
It is a smart contract project written in [Solidity](https://docs.soliditylang.org/en/latest/) using [Foundry](https://book.getfoundry.sh/).
- It a smart contract I developed leveraging Foundry.
- It contist of two sub parts:
  - Random Token: An ERC-20 token built with the help of OpenZeppline contracts.
  - Merkle Airdrop: An airdrop that drips Random Token to some of selected addresses. It is developed using concepts Merkle Trees, Merkle Proofs, and Root Hashes.
- In traditional airdrops, a problem can occur when the list of addresses(the users who can claim the airdrop) is very huge. The computional time and gas fees to iterate though the whole list would be reaching the moon! To tackle this problem, "merkle-airdrop" comes in the equation.
- This airdrop also implements EIP-712 i.e. a standard for typed structured data hashing and signing. For example, a person A can sign a message to another person B allowing him to call the funtion `claim()` in the `MerkleAirdrop` contract. By this the tokens will be dripped to person A but the gas of doing so will have to pe paid by person B.



## Getting Started

 - [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git): You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
 - [foundry](https://getfoundry.sh/): You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`
 - [make](https://www.gnu.org/software/make/manual/make.html) (optional - either you can install `make` or you can simply substitute the make commands with forge commands by referring to the Makefile after including your .env file): You'll know you did it right if you can run `make --version` and you will see a response like `GNU Make 3.81...`

 
## Installation

- Install merkle-airdrop
```bash
    git clone https://github.com/yug49/merkle-airdrop
    cd merkle-airdrop
```

- Make a .env file
```bash
    touch .env
```

- Open the .env file and fill in the details similar to:
```env
    SEPOLIA_RPC_URL=<YOUR SEPOLIA RPC URL>
    ETHERSCAN_API_KEY=<YOUR ETHERSCAN API KEY>
    SEPOLIA_PRIVATE_KEY=<YOUR PRIVATE KEY>
```
- Remove pre installed cache, unecessary or partially cloned modules modules etc.
```bash
    make clean
    make remove
```

- Build Project
```bash
    make build
```

## Deployment

### Pre-Deployment steps - Generating Merkle Proofs:
- If deploying on Anvil, you can directly skip to the `deployment` steps. 
- Before deploying, open `script/GenerateInput.s.sol`.
- In this contract, under `run()` function you can see the addresses being defined in the `whitelist[]` array of strings. These are the egible addresses that can claim the airdrop. You can replace these addresses according to you.
- Once replaced run the following command:
```bash
    make merkle
```
- This will modify `script/target/input.json` and `script/target/output.json` with your respective inputs and outputs(this contains the merkle proofs)
- Now copy the `root` hash (same for all inputs) from the `output.json` and assign it to the `ROOT` contant variable in `script/DeployMerkleAirdrop.s.sol`.

### Deployment
- For anvil, make sure you have your local anvil node running on another terminal. Use command `make anvil` on second terminal to do so.
```bash
    make deploy
```

- For Sepolia
```bash
    make deploy ARGS="--network sepolia"
```

## Interactions / Usage
- Go to `script/Interactions.s.sol`
- Replace `CLAIMING_ADDRESS`, `CLAIMING_AMOUNT`, `PROOF_ONE` and `PROOF_TWO` with the respective values of the account you want to claim the airdrop with. (The values are available in `script/target/output.json`).

### Creating Signature
- We need to create a signature for person A so that person B can call `claim()` on his behalf can pay his gas fees.
- First of all open `Makefile`
- Here you can see the following variable:
```
  - DEFAULT_ANVIL_KEY := <Person-A Private Key>
  - DEFAULT_ANVIL_KEY_2 := <Person-B Private Key>
  - DEFAULT_ANVIL_ADDRESS := <Person-A Public Key>
  - DEFAULT_ANVIL_ADDRESS_2 := <Person-B Public Key>
  - AIRDROP_AMOUNT := <airdrop amount>
  - AIRDROP_ADDRESS := <Your deployed merkel-airdrop contract address>
  - TOKEN_ADDRESS := <Your deployed random-token contract address>
```
- Replace this values with your respective addresses and keys.
- Now run command:
```bash
    make sign
```
- You would get a output like: `0xac1511dded56ec94d8290d8dc9ca84370ff3cb711b0593991275156123e2432f5385f80b0c037a1b97709b44083742b2fd3a4b442ffeba2fb0ea9a8987b87a6e1c`
- Copy this whole expect the first two charecters(i.e. except `0` and `x`). In this case, the signature is `ac1511dded56ec94d8290d8dc9ca84370ff3cb711b0593991275156123e2432f5385f80b0c037a1b97709b44083742b2fd3a4b442ffeba2fb0ea9a8987b87a6e1c`
- Assign this to the private `signature` variable in `script/Interactions.s.sol` in the format: `hex"signature"`.

### Claiming the airdrop
- To claim the airdrop as Person B run command:
```bash
    make claim
```
- If successfull then command `make balance` should return the amount of airdroped tokens to Person A.



## Formatting
- to format all the solidity files:
```bash
    make format
```

## Testing
- to test:
```bash
    make test
```


    
## 🔗 Links
Loved it? lets connect on:

[![twitter](https://img.shields.io/badge/twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://x.com/yugAgarwal29)
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/yug-agarwal-8b761b255/)

