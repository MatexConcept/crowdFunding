// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CrowdFundingModule = buildModule("CrowdFundingModule", (m) => {

  const crowdFundingModule = m.contract("CrowdFunding", );

  return { crowdFundingModule};
});

export default CrowdFundingModule;