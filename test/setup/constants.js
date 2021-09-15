const { ethers } = require('hardhat');

module.exports = {
  ZERO_ADDRESS: '0x0000000000000000000000000000000000000000',
  BYTES_ZERO: '0x0000000000000000000000000000000000000000000000000000000000000000',
  MAX_UINT256: ethers.BigNumber.from('2').pow(ethers.BigNumber.from('256')).sub(ethers.BigNumber.from('1')),
  MAX_INT256: ethers.BigNumber.from('2').pow(ethers.BigNumber.from('255')).sub(ethers.BigNumber.from('1')),
  MIN_INT256: ethers.BigNumber.from('2').pow(ethers.BigNumber.from('255')).mul(ethers.BigNumber.from('-1')),
  TEN_POW_18: ethers.BigNumber.from(10).pow(ethers.BigNumber.from(18))
};