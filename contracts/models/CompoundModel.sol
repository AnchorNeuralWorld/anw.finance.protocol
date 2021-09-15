// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../Ownable.sol";
import "../interfaces/ModelInterface.sol";
import "../ModelStorage.sol";
import "../DeFiInterfaces/CTokenInterface.sol";
import "../DeFiInterfaces/IUniswapV2Router.sol";

contract CompoundModel is ModelInterface, ModelStorage, Initializable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event Swap( uint compAmount, uint underlying );
    event Initialize();

    address creator;

    address _cToken;
    address _comp;
    address _comptroller;
    address _uRouterV2;

    modifier onlyCreator() {
        require( creator == msg.sender, "MODEL : Not Creator" );
        _;
    }

    constructor(){
        creator = msg.sender;
    }

    function initialize( 
        address forge_, 
        address token_,
        address cToken_, 
        address comp_, 
        address comptroller_,
        address uRouterV2_ ) public initializer onlyCreator
        {
            addToken( token_ );
            setForge( forge_ );
            _cToken         = cToken_;
            _comp           = comp_;
            _comptroller    = comptroller_;
            _uRouterV2      = uRouterV2_;

            emit Initialize();
    }

    function underlyingBalanceInModel() public override view returns ( uint256 ){
        return IERC20( token( 0 ) ).balanceOf( address( this ) );
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 ){
        return underlyingBalanceInModel().add( CTokenInterface( _cToken ).exchangeRateStored().mul( _cTokenBalanceOf() ).div( 1e18 ) );
    }

    function invest() public override {
        IERC20( token( 0 ) ).safeApprove( _cToken, underlyingBalanceInModel() );
        emit Invest( underlyingBalanceInModel(), block.timestamp );
        CTokenInterface( _cToken ).mint( underlyingBalanceInModel() );
    }
    
    function reInvest() public{
        _claimComp();
        _swapCompToUnderlying();
        invest();
    }

    function withdrawAllToForge() public OnlyForge override{
        _claimComp();
        _swapCompToUnderlying();

        emit Withdraw(  underlyingBalanceWithInvestment(), forge(), block.timestamp);
        CTokenInterface( _cToken ).redeem( _cTokenBalanceOf() );
    }

    function withdrawToForge( uint256 amount ) public OnlyForge override{
        withdrawTo( amount, forge() );
    }

    function withdrawTo( uint256 amount, address to ) public OnlyForge override{
        uint oldBalance = IERC20( token(0) ).balanceOf( address( this ) );
        CTokenInterface( _cToken ).redeemUnderlying( amount );
        uint newBalance = IERC20( token(0) ).balanceOf( address( this ) );
        require(newBalance.sub( oldBalance ) > 0, "MODEL : REDEEM BALANCE IS ZERO");
        IERC20( token( 0 ) ).safeTransfer( to, newBalance.sub( oldBalance ) );
        
        emit Withdraw( amount, forge(), block.timestamp);
    }

    function _cTokenBalanceOf() internal view returns( uint ){
        return CTokenInterface( _cToken ).balanceOf( address( this ) );
    }

    function _claimComp() internal {
        CTokenInterface( _comptroller ).claimComp( address( this ) );
    }

    function _swapCompToUnderlying() internal {
        uint balance = IERC20(_comp).balanceOf(address(this));
        if (balance > 0) {

            IERC20(_comp).safeApprove(_uRouterV2, balance);
            
            address[] memory path = new address[](3);
            path[0] = address(_comp);
            path[1] = IUniswapV2Router( _uRouterV2 ).WETH();
            path[2] = address( token( 0 ) );

            IUniswapV2Router(_uRouterV2).swapExactTokensForTokens(
                balance,
                1,
                path,
                address(this),
                block.timestamp + ( 15 * 60 )
            );

            emit Swap(balance, underlyingBalanceInModel());
        }
    }

}