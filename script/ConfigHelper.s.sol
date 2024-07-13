// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract ConfigHelper is Script {
    NetworkConfig public activeNetworkConfig;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint8 public constant MOCK_DECIMALS = 8;
    uint256 public constant MOCK_INITIAL_ANSWER = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ethusd price feed address
    }

    constructor() {
        if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() private pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return config;
    }

    function getAnvilConfig() private returns (NetworkConfig memory) {
        // create mock aggregator contract
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        
        vm.startBroadcast();
        MockV3Aggregator agg = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        // get its address as price feed
        NetworkConfig memory config = NetworkConfig({priceFeed: address(agg)});
        return config;
    }
}
