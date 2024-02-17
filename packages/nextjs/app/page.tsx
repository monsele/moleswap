import type { NextPage } from "next";

const Home: NextPage = () => {
  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-4xl font-bold">DEX Exchange</span>
          </h1>
          <p className="text-center text-lg">
            This is an implementation of an Decentralized Exchange similair to Uniswap
            <br />
            It implements the major functionalities in a Decentralized Exchange
          </p>
          <p className="text-center text-lg">
            Init: This functions just helps to initialize the contract with some liquidity
          </p>
          <p className="text-center text-lg">
            SwapTokenToEth: This is the fucntion that allows you exchange some DTokens for ETH
          </p>
          <p className="text-center text-lg">
            SwapEthToToken: This is the fucntion that allows you exchange some Eth for DTokens
          </p>
          <p className="text-center text-lg">
            ProvideLiquidity: This is the fucntion that allows liquidity providers add liquidity to the exchange
          </p>
          <p className="text-center text-lg">
            Withdraw: This is the fucntion that allows liquidity providers withdraw their liquidity
          </p>

          <p className="text-center text-lg"></p>
        </div>
      </div>
    </>
  );
};

export default Home;
