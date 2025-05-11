// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const ManagerAdminModule = buildModule("ManagerAdminModule", (m) => {
  const admin = m.getParameter("managerAdmin-admin");
  const payToken = m.getParameter("managerAdmin-payToken");
  const payPeriod = m.getParameter("managerAdmin-payPeriod");
  const subscriptionFee = m.getParameter("managerAdmin-subFee");
  const maxAllowedSMAs = m.getParameter("amangerAdmin-maxAllowedSMAs");
  const smaFeeUSD = m.getParameter("managerAdmin-smaFeeUSD");

  const managerAdminParams = [admin, payToken, payPeriod, subscriptionFee, maxAllowedSMAs, smaFeeUSD];

  const usdcAddress = m.getParameter("USDC");
  const usdcSymbol = m.getParameter("USDC_SYMBOL");
  const aUSDCAddress = m.getParameter("aUSDC");
  const aUSDCSymbol = m.getParameter("aUSDC_SYMBOL");
  const cUSDCAddress = m.getParameter("cUSDC");
  const cUSDCSymbol = m.getParameter("cUSDC_SYMBOL");
  const aUSDCProtocol = m.getParameter("aUSDC_PROTOCOL");
  const cUSDCProtocol = m.getParameter("cUSDC_PROTOCOL");
  const usdcDecimals = m.getParameter("USDC_DECIMALS");

  const allowUSDCParams = [usdcAddress, usdcSymbol, usdcDecimals];
  const allowAUSDCParams = [aUSDCAddress, aUSDCSymbol, aUSDCProtocol, usdcAddress, usdcDecimals];
  const allowCUSDCParams = [cUSDCAddress, cUSDCSymbol, cUSDCProtocol, usdcAddress, usdcDecimals];

  const managerAdmin = m.contract("SMAManagerAdmin", managerAdminParams);

  m.call(managerAdmin, "addAllowedToken", allowUSDCParams);
  m.call(managerAdmin, "setIsAllowedToken", [usdcAddress, true]);

  m.call(managerAdmin, "addAllowedInterestToken", allowAUSDCParams, {id: "addAllowedInterestTokenaUSDC"});
  m.call(managerAdmin, "setIsAllowedInterestToken", [aUSDCAddress, true], {id: "setIsAllowedInterestTokenaUSDC"});

  m.call(managerAdmin, "addAllowedInterestToken", allowCUSDCParams, {id: "addAllowedInterestTokencUSDC"});
  m.call(managerAdmin, "setIsAllowedInterestToken", [cUSDCAddress, true], {id: "setIsAllowedInterestTokencUSDC"});

  return { managerAdmin };
});
module.exports = ManagerAdminModule;

const SMAAddressProviderModule = buildModule("SMAAddressProviderModule", (m) => {
  const { managerAdmin } = m.useModule(ManagerAdminModule);
  const aaveName = m.getParameter("AAVE_PROTOCOL");
  const compoundName = m.getParameter("COMPOUND_PROTOCOL");
  const aavePoolAddress = m.getParameter("AAVE_POOL");
  const compoundPoolAddress = m.getParameter("COMPOUND_POOL");

  const addressProvider = m.contract("SMAAddressProvider", [managerAdmin]);

  m.call(addressProvider, "setProtocolAddress", [aaveName, aavePoolAddress], {id: "setProtocolAAVE"});
  m.call(addressProvider, "setProtocolAddress", [compoundName, compoundPoolAddress], {id: "setProtocolCOMPOUND"});

  return { addressProvider };
});
module.exports = SMAAddressProviderModule;

const SMASuiteModule = buildModule("SMASuiteModule", (m) => {
  const { addressProvider } = m.useModule(SMAAddressProviderModule);
  const { managerAdmin } = m.useModule(ManagerAdminModule);

  const keeperAddress = m.getParameter("oracleKeeper");
  const initBestRateProtocol = m.getParameter("initBestRateProtocol");
  const usdcAddress = m.getParameter("USDC");

  const managementRegistry = m.contract("ManagementRegistry", [addressProvider]);
  const managementLogic = m.contract("ManagementLogic", [addressProvider]);
  const smaFactory = m.contract("SMAFactory", [addressProvider]);
  const smaOracle = m.contract("SMAOracle", [addressProvider, keeperAddress]);

  m.call(addressProvider, "setManagementRegistry", [managementRegistry]);
  m.call(addressProvider, "setManagementLogic", [managementLogic]);
  m.call(addressProvider, "setSMAFactory", [smaFactory]);
  m.call(addressProvider, "setOracle", [smaOracle]);

  m.call(managerAdmin, "setFactoryAddress", [smaFactory]);

  m.call(smaOracle, "setBestRateProtocol", [usdcAddress, initBestRateProtocol], {id: "setBestRateProtocolUSDC"});

  return { managementRegistry, managementLogic, smaFactory, smaOracle };
});
module.exports = SMASuiteModule;
