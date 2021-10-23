// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../access/manager/ManagerRole.sol";
import "../access/governance/GovernanceRole.sol";

import "./interface/IPairFactory.sol";
import "./interface/IPair.sol";

import "@openzeppelin/contracts/utils/Context.sol";

import "./Pair.sol";

contract PairFactory is Context, IPairFactory {

    using ManagerRole for RoleStore;
    using GovernanceRole for RoleStore;

    RoleStore private _s;

    bytes32 private constant _INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(Pair).creationCode));

    address public override router;

    address public override feeTo;

    mapping(address => mapping(address => address)) public override getPair;
    
    address[] public override allPairs;

    modifier onlyManagerOrGovernance() {
        require(
            _s.isManager(_msgSender()) || _s.isGovernor(_msgSender()),
            "Pair::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    constructor(address _treasury) {
        feeTo = _treasury;
        _s.initializeManagerRole(_msgSender());
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'PairFactory::createPair: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PairFactory::createPair: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'PairFactory::createPair: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address feeTo_) external onlyManagerOrGovernance override {
        feeTo = feeTo_;
    }

    // set a router address to permission critical incoming calls to Pair contracts
    function setRouter(address router_) external onlyManagerOrGovernance override {
        router = router_;
    }

}