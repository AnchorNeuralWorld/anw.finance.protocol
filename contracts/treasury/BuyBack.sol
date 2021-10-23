// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../saver/DeFiInterfaces/IUniswapV2Router.sol";

import "../access/manager/ManagerRole.sol";
import "../access/governance/GovernanceRole.sol";

contract BuyBack is Context, Initializable {
    using SafeERC20 for IERC20;
    using ManagerRole for RoleStore;
    using GovernanceRole for RoleStore;
    
    RoleStore private _s;

    modifier onlyManagerOrGovernance() {
        require(
            _s.isManager(_msgSender()) || _s.isGovernor(_msgSender()),
            "Treasury::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    // expose manager and governance getters
    function isManager(address account) external view returns (bool) {
        return _s.isManager(account);
    }

    function isGovernor(address account) external view returns (bool) {
        return _s.isGovernor(account);
    }

    mapping( uint256 => address ) private _tokens;
    uint256 public count;

    address private _anwfi;
    address private _grinder;
    address private _uRouterV2;
    
    event Initialize();
    event AddAsset( address token );

    function initialize( address storage_, address grinder_, address anwfi_, address uRouterV2_ ) public initializer {
        _grinder = grinder_;
        _anwfi = anwfi_;
        _uRouterV2 = uRouterV2_;
        emit Initialize();
    }

    function addAsset( address token ) public onlyManagerOrGovernance {
        require( IERC20(token).totalSupply() > 0, "TREASURY : token is Invalid" );
        require( !existToken(token), "TREASURY : Already Registry Token" );
        _tokens[count] = token;
        count++;
        emit AddAsset(token);
    }

    function buyBack() public onlyManagerOrGovernance {
        for( uint i = 0 ; i < count ; i++ ){
            
            uint balance = IERC20( _tokens[ i ] ).balanceOf( address( this ) );
            if( balance > 0 ){
                IERC20( _tokens[ i ] ).safeApprove(address(_uRouterV2), balance);
            
                address[] memory path = new address[](3);
                path[0] = address( _tokens[i] );
                path[1] = IUniswapV2Router(_uRouterV2).WETH();
                path[2] = address( _anwfi );

                IUniswapV2Router(_uRouterV2).swapExactTokensForTokens(
                    balance,
                    1,
                    path,
                    _grinder,
                    block.timestamp + ( 15 * 60 )
                );
            }
        }

        // For SwapEthForToken
        if( address(this).balance > 0 ){
            address[] memory pathForSwapEth = new address[](2);
            pathForSwapEth[0] = IUniswapV2Router(_uRouterV2).WETH();
            pathForSwapEth[1] = address( _anwfi );

            (bool success, ) = address(_uRouterV2).call{value:address(this).balance}(
                abi.encodeWithSignature("swapExactETHForTokens", 
                    1,
                    pathForSwapEth,
                    _grinder,
                    block.timestamp + ( 15 * 60 )
                )
            );
            require(
                success,
                "swapExactETHForTokens FAIl"
            );
        }
    }

    function existToken( address token ) public view returns(bool){
        for( uint i = 0 ; i < count ; i++ ){
            if( _tokens[i] == token ) return true;
        }
        return false;
    }

    receive() external payable {
        payable(_msgSender()).transfer(msg.value);
    }
    
}