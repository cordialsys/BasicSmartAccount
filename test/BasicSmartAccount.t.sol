// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {BasicSmartAccount} from "../src/BasicSmartAccount.sol";

error InvalidSignature();

contract MockERC20 {
    function transfer(address to, uint256 amount) external {}
}

contract BasicSmartAccountTest is Test {
    BasicSmartAccount public basicSmartAccount;
    MockERC20 public token;

    // test vector from holesky that:
    // - transfers eth
    // - transfers erc20
    bytes userOps =
        hex"91325d5b27a4895bfaca49f50eed2a364127b4ba00000000000000000000000000000000000000000000000000000000000003e80000000000000000000000000000000000000000000000000000000000000000685ce6742351ae9b618f383883d6d1e0c5a31b4b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a9059cbb00000000000000000000000091325d5b27a4895bfaca49f50eed2a364127b4ba0000000000000000000000000000000000000000000000000000000000000064685ce6742351ae9b618f383883d6d1e0c5a31b4b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a9059cbb00000000000000000000000091325d5b27a4895bfaca49f50eed2a364127b4ba00000000000000000000000000000000000000000000000000000000000000ea685ce6742351ae9b618f383883d6d1e0c5a31b4b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a9059cbb00000000000000000000000091325d5b27a4895bfaca49f50eed2a364127b4ba0000000000000000000000000000000000000000000000000000000000000237";
    uint256 r =
        0x7336dbf879f708be84b8914d44e51bf63b05349e33342abf8fda080a8f4da963;
    uint256 vs =
        0x3c34c09c31b6ec0f7ab063a7e5e7028267c3ea4e1ad735dc9d8af3e97f4ac397;

    function setUp() public {
        // Holesky chain id
        vm.chainId(17000);
        address payable contractAddress = payable(
            0x0033fd20d6766Cf0d94080dB6fbdDaA7A0EaB1f4
        );
        deployCodeTo("BasicSmartAccount.sol", contractAddress);
        basicSmartAccount = BasicSmartAccount(contractAddress);

        // set an ether balance
        vm.deal(contractAddress, 10 ether);

        // deploy a mock erc20 token
        address tokenAddress = 0x685cE6742351ae9b618F383883D6d1e0c5A31B4B;
        token = MockERC20(tokenAddress);
    }

    function test_handleOps() public {
        assertEq(basicSmartAccount.getNonce(), 0);
        basicSmartAccount.handleOps(userOps, r, vs);
        assertEq(basicSmartAccount.getNonce(), 1);
    }

    function test_revert_if_missing_eth() public {
        vm.expectRevert();
        vm.deal(address(basicSmartAccount), 0);
        basicSmartAccount.handleOps(userOps, r, vs);
    }

    function test_handleOpsWrongSignature() public {
        assertEq(basicSmartAccount.getNonce(), 0);
        vm.expectRevert(InvalidSignature.selector);
        basicSmartAccount.handleOps(userOps, r, vs + 1);
        assertEq(basicSmartAccount.getNonce(), 0);
    }

    function test_handleOpsReplayProtection() public {
        assertEq(basicSmartAccount.getNonce(), 0);
        basicSmartAccount.handleOps(userOps, r, vs);
        vm.expectRevert(InvalidSignature.selector);
        basicSmartAccount.handleOps(userOps, r, vs);
        assertEq(basicSmartAccount.getNonce(), 1);
    }
}
