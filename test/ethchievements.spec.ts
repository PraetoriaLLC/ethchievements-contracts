import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Ethchievements, Ethchievements__factory } from "../typechain";
import chai from "chai";
import { BigNumber } from "@ethersproject/bignumber";
import { ContractTransaction } from "@ethersproject/contracts";

const expect = chai.expect;

describe("Ethchievements", () => {

  let deployer: SignerWithAddress;
  let user: SignerWithAddress;

  let ethchievements: Ethchievements;

  beforeEach(async () => {
    [ deployer, user ] = await ethers.getSigners();

    ethchievements = await new Ethchievements__factory(deployer).deploy("example.com");
  });

  describe("#constructor", async () => {
    let subjectBase: string;

    beforeEach(() => {
      subjectBase = "example.com";
    });

    async function subject(): Promise<Ethchievements> {
      return await new Ethchievements__factory(deployer).deploy(subjectBase);
    }

    it("should set the correct state variables", async () => {
      const deployedEthchievements = await subject();

      expect(await deployedEthchievements.base()).to.eq(subjectBase);
    });
  });

  describe("#mint", async () => {
    let subjectTo: string;
    let subjectIntegration: string;
    let subjectTask: string;
    let subjectCaller: SignerWithAddress;

    beforeEach(async () => {
      subjectTo = user.address;
      subjectIntegration = "aave";
      subjectTask = "deposit";
      subjectCaller = user;
    });

    async function subject(): Promise<ContractTransaction> {
      return await ethchievements.connect(subjectCaller).mint(subjectTo, subjectIntegration, subjectTask);
    }

    it("should increment the currentId", async () => {
      const initId = await ethchievements.currentId();
      await subject();
      const finalId = await ethchievements.currentId();

      expect(finalId.sub(initId)).to.eq(BigNumber.from(1));
    });

    it("should set the correct tokenURI", async () => {
      const id = await ethchievements.currentId();
      await subject();
      const tokenURI = await ethchievements.tokenURI(id);

      expect(tokenURI).to.eq(`example.com/${subjectIntegration}/${subjectTask}`);
    });
  });
});
