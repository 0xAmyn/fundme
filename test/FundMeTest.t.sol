// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); 

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100 ether);
    }

    function testMinimumUSDisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testI_OwnerIsMsgSender() public view {
        // vm.prank(USER);
        // assertEq(fundMe.i_owner(), USER);
        // this approach is wrong beccause USER is not deploying the contract. the deployer is msg.sender
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersionIsEquals4() public view {
        assertEq(fundMe.getVersion(), 4);
    }
    
    function testFundIslowerThanMinimumUSD() public {
        vm.expectRevert();
        fundMe.fund{value: 1}();
    }

    function testFundAndThenGetUserFundedAmount() public {
        vm.prank(USER);
        fundMe.fund{value: 0.1 ether}();
        uint256 fund = fundMe.getAddressToAmountFunded(USER);
        assertEq(fund, 0.1 ether); 
    }

    function testWithdrawDeniedForNotOwner() public {
        vm.prank(USER);
        fundMe.fund{value: 0.1 ether}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawIsSuccessfullByOwner() public {
        vm.prank(USER);
        fundMe.fund{value: 0.1 ether}();

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
    }

    function testWithdrawIsSuccessfullByOwnerWhenFundedMultipleTimes() public {
        // Arrange
        for (uint160 i = 1; i < 10; i++) {
            hoax(address(i), 10 ether);
            fundMe.fund{value: 0.1 ether}();
        }

        uint256 startBalanceOwner = address(fundMe.getOwner()).balance;
        uint256 startBalanceContract = address(fundMe).balance;


        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endBalanceOwner = address(fundMe.getOwner()).balance;
        uint256 endBalanceContract = address(fundMe).balance;
        assert(endBalanceContract == 0);
        assert(endBalanceOwner == startBalanceOwner + startBalanceContract);
    }
        
}
