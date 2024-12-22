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

  const allowedTokensStr = JSON.stringify(m.getParameter("managerAdmin-allowedTokens"));
  const allowedTokens = JSON.parse(allowedTokensStr);
  for (var i = 0; i < allowedTokens.length; i++) {
    let tokenAddress = allowedTokens[i]['tokensAddress'];
    let tokenSymbol = allowedTokens[i]['tokenSymbol'];
    m.call(managerAdmin, "addAllowedToken", [tokenAddress, tokenSymbol], {id: "addAllowedTokenCall"});
    m.call(managerAdmin, "setIsAllowedToken", [tokenAddress, true]), {id: "setIsAllowedTokenCall"};
  }

  const allowedInterestTokensStr = JSON.stringify(m.getParameter("managerAdmin-allowedInterestTokens"));
  const allowedInterestTokens = JSON.parse(allowedInterestTokensStr);
  for (var i = 0; i < allowedInterestTokens.length; i++) {
    let tokenAddress = allowedInterestTokens[i]['tokensAddress'];
    let tokenSymbol = allowedInterestTokens[i]['tokenSymbol'];
    let protocol = token['protocol'];
    m.call(managerAdmin, "addAllowedInterestToken", [tokenAddress, tokenSymbol, protocol], {id: "addAllowedInterestTokenCall"});
    m.call(managerAdmin, "setIsAllowedInterestToken", [tokenAddress, true], {id: "setIsAllowedInterestTokenCall"});
  }

  return { managerAdmin };
});
module.exports = ManagerAdminModule;

const SMAAddressProviderModule = buildModule("SMAAddressProviderModule", (m) => {
  const { managerAdmin } = m.useModule(ManagerAdminModule);

  const addressProvider = m.contract("SMAAddressProvider", [managerAdmin]);

  const protocolAdressesStr = JSON.stringify(m.getParameter("addressProvider-protocols"));
  const protocolAdresses = JSON.parse(protocolAdressesStr);
  for (var i = 0; i < protocolAdresses.length; i++) {
    let protocolName = protocolAdresses[i]['protocolName'];
    let protocolPoolAddress = protocolAdresses[i]['poolAdress'];
    m.call(addressProvider, "setProtocol", [protocolName, protocolPoolAddress], {id: "setProtocolCall"});
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
