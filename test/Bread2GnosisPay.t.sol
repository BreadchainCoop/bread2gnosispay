// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bread2GnosisPay} from "../src/Bread2GnosisPay.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
abstract contract Bread is IERC20 {
    function mint(address receiver) external payable virtual;
}
interface IStableSwap3Pool {
    // https://github.com/curvefi/curve-contract/blob/master/contracts/pools/3pool/StableSwap3Pool.vy#L431
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
    // https://github.com/curvefi/curve-contract/blob/master/contracts/pools/3pool/StableSwap3Pool.vy#L402
    function get_dy(int128 i, int128 j, uint256 dx) external view ;
}
contract Bread2GpayTest is Test {
    Bread2GnosisPay public bread2gnosispay;
    Bread public bread= Bread(0xa555d5344f6FB6c65da19e403Cb4c1eC4a1a5Ee3);
    IStableSwap3Pool public pool = IStableSwap3Pool(0x32b0456100e4fEBcA554244B225706B1BEeeaEB1);
    IERC20 public gbpeToken = IERC20(0x5Cb9073902F2035222B9749F8fB0c9BFe5527108);

    function setUp() public {
        Bread2GnosisPay bread2gnosispayimplementation = new Bread2GnosisPay();
        bread2gnosispay =  Bread2GnosisPay(
            address(
                new TransparentUpgradeableProxy(
                    address(bread2gnosispayimplementation),
                    address(msg.sender),
                    "" 
                )
            )
        );
        vm.deal(address(this),10000000000000);
    }

    function test_approve_and_swap() public {
        address randomHolder = address(0x42);
        vm.deal(randomHolder,10 ether);
        vm.prank(randomHolder);
        bread.mint{value: 1 ether}(randomHolder);
        vm.prank(randomHolder);
        bread.approve(address(bread2gnosispay), 1 ether);
        uint256 allowance = bread.allowance(randomHolder, address(bread2gnosispay));
        assertEq(allowance, 1 ether);
        // bread.transferFrom(address(this), address(0x42), 1 ether);
        // vm.roll(424242424242);
        uint256 amount = 20;
        // address randomHolder = address(0x42);
        // vm.deal(randomHolder,10000000000000);
        // bread.mint{value:amount}(randomHolder);
        // assertGt(bread.balanceOf(randomHolder), 0);
        // vm.roll(424242424243);
        // vm.prank(randomHolder);
        // bread.approve(address(bread2gnosispay), type(uint256).max);
        // // vm.roll(424242424244);
        // // pool.get_dy(1, 0, amount); 
        // // uint256 min_dy = pool.get_dy(1, 0, amount); 
        // vm.roll(424242424244);
        // vm.prank(randomHolder);
        // // uint256 allowance = bread.allowance(randomHolder, address(bread2gnosispay));
        // // assertEq(allowance, 1000000);
        // uint256 breadBalance = bread.balanceOf(randomHolder);
        // assertEq;
        vm.prank(randomHolder);
        bread2gnosispay.swapAndTransfer(address(0x32), amount, amount-1);
        uint256 gbpeBalance = gbpeToken.balanceOf(address(0x32));
        assert(gbpeBalance >= amount-1);
    }
}
