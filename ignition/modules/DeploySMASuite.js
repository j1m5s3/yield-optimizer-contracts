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

  const managerAdmin = m.contract("SMAManagerAdmin", managerAdminParams);

  const allowedTokens = m.getParameter("managerAdmin-allowedTokens");
  for (const token of allowedTokens) {
    let tokenAddress = token['tokensAddress'];
    let tokenSymbol = token['tokenSymbol'];
    m.call(managerAdmin, "addAllowedToken", [tokenAddress, tokenSymbol]);
    m.call(managerAdmin, "setIsAllowedToken", [tokenAddress, true]);
  }

  const allowedInterestTokens = m.getParameter("managerAdmin-allowedInterestTokens");
  for (const token of allowedInterestTokens) {
    let tokenAddress = token['tokensAddress'];
    let tokenSymbol = token['tokenSymbol'];
    let protocol = token['protocol'];
    m.call(managerAdmin, "addAllowedInterestToken", [tokenAddress, tokenSymbol, protocol]);
    m.call(managerAdmin, "setIsAllowedInterestToken", [tokenAddress, true]);
  }

  return { managerAdmin };
});
module.exports = ManagerAdminModule;

const SMAAddressProviderModule = buildModule("SMAAddressProviderModule", (m) => {
  const { managerAdmin } = m.useModule(ManagerAdminModule);

  const addressProvider = m.contract("SMAAddressProvider", [managerAdmin]);

  const protocolAdresses = m.getParameter("addressProvider-protocols")
  for (const protocol of protocolAdresses) {
    let protocolName = protocol['protocolName'];
    let protocolPoolAddress = protocol['poolAdress'];
    m.call(addressProvider, "setProtocol", [protocolName, protocolPoolAddress]);
  }

  return { addressProvider };
});
module.exports = SMAAddressProviderModule;

const SMASuiteModule = buildModule("SMASuiteModule", (m) => {
  const { addressProvider } = m.useModule(SMAAddressProviderModule);

  const managementRegistry = m.contract("ManagementRegistry", [addressProvider]);
  const managementLogic = m.contract("ManagementLogic", [addressProvider]);
  const smaFactory = m.contract("SMAFactory", [addressProvider]);
  const smaOracle = m.contract("SMAOracle", [addressProvider]);

  m.call(addressProvider, "setManagementRegistry", [managementRegistry]);
  m.call(addressProvider, "setManagementLogic", [managementLogic]);
  m.call(addressProvider, "setSMAFactory", [smaFactory]);
  m.call(addressProvider, "setOracle", [smaOracle]);

  return { managementRegistry, managementLogic, smaFactory, smaOracle };
});
module.exports = SMASuiteModule;
