// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
pragma solidity ^0.8.20;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
	//////////////////
	/////ERRORS/////
	error Exchange__TransferFailed(string message);
	error Exchange__AmountShouldBeGreaterThanZero();
	error Exchange__AmountIsLessThanMinimumAmount();
	error Exchange__InsufficientReturnReserve();
	error Exchange__LiquidityShouldBeZero(string message);

	address private tokenAddress;
	uint256 public totalLiquidity;
	mapping(address => uint256) public liquidity;

	using Math for uint256;

	constructor(address _tokenAddress) {
		tokenAddress = _tokenAddress;
	}
	// getReserve returns the balance of `token` held by `this` contract

	function getTokenReserve() public view returns (uint256) {
		return IERC20(tokenAddress).balanceOf(address(this));
	}

	function getEthBalance() public view returns (uint256) {
		return address(this).balance;
	}

	/**
	 * @dev This function is a simple initialize function.
	 * it helps to add some liquidity to the DEX on creation
	 */
	function init(uint256 tokenAmount) external payable returns (uint256) {
		if (totalLiquidity != 0) {
			revert Exchange__LiquidityShouldBeZero("DEX already has liquidity");
		}
		totalLiquidity = address(this).balance;
		liquidity[msg.sender] = totalLiquidity;
		if (
			!(
				IERC20(tokenAddress).transferFrom(
					msg.sender,
					address(this),
					tokenAmount
				)
			)
		) {
			revert Exchange__TransferFailed("Contract funding failed");
		}
		return totalLiquidity;
	}
	/**
	 * @dev This is the function returns the price
	 * it will cost a for a swap.
	 */
	function price(
		uint256 input_amount,
		uint256 input_reserve,
		uint256 output_reserve
	) public pure returns (uint256) {
		(, uint256 input_amount_with_fee) = Math.tryMul(input_amount, 997);
		(, uint256 numerator) = Math.tryMul(
			input_amount_with_fee,
			output_reserve
		);
		(, uint256 input_reserve_fee) = Math.tryMul(input_reserve, 1000);
		(, uint256 denominator) = Math.tryAdd(
			input_reserve_fee,
			input_amount_with_fee
		);
		// input_reserve.mul(1000).add(input_amount_with_fee);
		return numerator / denominator;
	}

	function swapEthToToken() external payable returns (uint256) {
		uint256 token_reserve = getTokenReserve();
		(, uint256 input_reserve) = Math.trySub(
			address(this).balance,
			msg.value
		);
		uint256 tokens_bought = price(msg.value, input_reserve, token_reserve);
		if (!(IERC20(tokenAddress).transfer(msg.sender, tokens_bought))) {
			revert Exchange__TransferFailed("Transfer failed");
		}
		return tokens_bought;
	}

	function SwapTokenToEth(uint256 tokens) external returns (uint256) {
		uint256 token_reserve = getTokenReserve();
		uint256 eth_bought = price(
			tokens,
			token_reserve,
			address(this).balance
		);
		payable(msg.sender).transfer(eth_bought);
		if (
			!(
				IERC20(tokenAddress).transferFrom(
					msg.sender,
					address(this),
					tokens
				)
			)
		) {
			revert Exchange__TransferFailed("Transfer failed");
		}
		return eth_bought;
	}
	/**
	 * @dev This is the function that allows
	 *  users add liquidity to the exchange
	 */
	function provideLiquidity() external payable returns (uint256) {
		(, uint256 eth_reserve) = Math.trySub(address(this).balance, msg.value);
		uint256 token_reserve = getTokenReserve();
		(, uint256 numerator) = Math.tryMul(msg.value, token_reserve);
		(, uint256 denominator) = Math.tryAdd(eth_reserve, 1);
		uint256 token_amount = (numerator / denominator);
		uint256 liquidity_minted = (msg.value * totalLiquidity) / eth_reserve;
		(, liquidity[msg.sender]) = Math.tryAdd(
			liquidity[msg.sender],
			liquidity_minted
		);
		(, totalLiquidity) = Math.tryAdd(totalLiquidity, liquidity_minted);
		if (
			!(
				IERC20(tokenAddress).transferFrom(
					msg.sender,
					address(this),
					token_amount
				)
			)
		) {
			revert Exchange__TransferFailed("Transfer failed");
		}
		return liquidity_minted;
	}

	function withdraw(uint256 amount) external returns (uint256, uint256) {
		uint256 token_reserve = getTokenReserve();
		(, uint256 eth_amt_numerator) = Math.tryMul(amount, getEthBalance());
		(, uint256 token_amt_numerator) = Math.tryMul(amount, token_reserve);
		uint256 eth_amount = eth_amt_numerator / totalLiquidity;

		uint256 token_amount = token_amt_numerator / totalLiquidity;
		(, liquidity[msg.sender]) = Math.trySub(
			liquidity[msg.sender],
			eth_amount
		);
		(, totalLiquidity) = Math.trySub(totalLiquidity, eth_amount);
		payable(msg.sender).transfer(eth_amount);
		if ((!IERC20(tokenAddress).transfer(msg.sender, token_amount))) {
			revert Exchange__TransferFailed("Transfer failed");
		}
		return (eth_amount, token_amount);
	}
}
