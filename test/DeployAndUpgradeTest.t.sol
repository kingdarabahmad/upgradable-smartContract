//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployBox;
    UpgradeBox public upgradeBox;

    address public constant OWNER = address(1);

    function setUp() public {
        deployBox = new DeployBox();
        upgradeBox = new UpgradeBox();
    }

    function testDeployBoxWorks() public {
        address proxyAddress = deployBox.deployBox();
        uint256 expectedValue = 1;
        assertEq(expectedValue, BoxV1(proxyAddress).version());
    }

    function testDeploymentIsV1() public {
        address proxyAddress = deployBox.deployBox();
        uint256 expectedValue = 7;
        vm.expectRevert();
        BoxV2(proxyAddress).setNumber(expectedValue);
    }

    function testUpgradeWorks() public {
        address proxyAddress = deployBox.deployBox();

        //new implementation
        BoxV2 newBox = new BoxV2();

        address proxy = upgradeBox.upgradeBox(proxyAddress, address(newBox));

        uint256 expectValue = 2;

        assertEq(expectValue, BoxV2(proxy).version());

        BoxV2(proxy).setNumber(expectValue);

        assertEq(expectValue, BoxV2(proxy).getNumber());
    }
}
