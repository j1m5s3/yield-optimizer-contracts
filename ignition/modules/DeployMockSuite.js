// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const MockSuiteModule = buildModule("MockSuiteModule", (m) => {
    const usdcAddr = m.getParameter("USDC");

    const mockaUSDC = m.contract("MockaUSDC");
    const mockcUSDC = m.contract("MockcUSDC");
    const mockAAVEPool = m.contract("MockAAVEPool", [usdcAddr, mockaUSDC]);
    const mockCompoundPool = m.contract("MockCOMPComet", [usdcAddr, mockcUSDC]);

    return { mockaUSDC, mockcUSDC, mockAAVEPool, mockCompoundPool };
});
module.exports = MockSuiteModule;
