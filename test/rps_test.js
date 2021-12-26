var chai = require('chai');  
var assert = chai.assert;    // Using Assert style
// const truffleAssert = require('truffle-assertions');

const RockPaperScissors = artifacts.require("RockPaperScissors");

contract("RockPaperScissors", (accounts) => {
    let rps, p1_stake, p2_stake, game_fees, game_stake;
    let p1_eth_before, p2_eth_before, p1_eth_after, p2_eth_after;
    before(async () => {
        rps = await RockPaperScissors.deployed();
        console.log("acc0 = ", accounts[0]);
        console.log("acc1 = ", accounts[1]);
        game_fees = await web3.utils.toWei("0.2");
        console.log("game_fees per player = ", game_fees);
        console.log("player1 ETH balance = ", await web3.eth.getBalance(accounts[0]));
        console.log("player2 ETH balance = ", await web3.eth.getBalance(accounts[1]));
            
    });

    it("enrolls players and rewards winner", async() => {
        p1_stake = await web3.utils.toWei("2");
        console.log("p1_stake = ", p1_stake);
        await rps.enroll({value:p1_stake});
        console.log(await rps.player1());

        p2_stake = await web3.utils.toWei("2");
        console.log("p2_stake = ", p2_stake);
        await rps.enroll({value:p2_stake, from:accounts[1]});
        console.log(await rps.player2());
        

        assert.equal(accounts[0], await rps.player1());
        assert.equal(accounts[1], await rps.player2());
        // console.log(BigInt(2*game_fees));
        game_stake = (BigInt(p1_stake) + BigInt(p2_stake) - BigInt(2*game_fees));
        assert.equal(game_stake, BigInt(await rps.stake())); // 4 eth - 0.4 eth = 3.6 eth
        
        console.log("hash1 = ", await rps.hash1());
        console.log("hash2 = ", await rps.hash2());
        await rps.commitMove("ROCK", "First Player");
        await rps.commitMove("PAPER", "Second Player", {from:accounts[1]});
        console.log("hash1 = ", await rps.hash1());
        console.log("hash2 = ", await rps.hash2());


        console.log("move1 = ", await rps.player1_move());
        console.log("move2 = ", await rps.player2_move());

        p1_eth_before = await web3.eth.getBalance(accounts[0]);
        p2_eth_before = await web3.eth.getBalance(accounts[1]);

        console.log("player1 ETH balance before revealing move = ", p1_eth_before);
        console.log("player2 ETH balance before revealing move = ", p2_eth_before);
        console.log("game_stake = ", game_stake);
        await rps.revealMove("ROCK", "First Player");
        await rps.revealMove("PAPER", "Second Player", {from:accounts[1]});
        console.log("move1 = ", await rps.player1_move());
        console.log("move2 = ", await rps.player2_move());

        p1_eth_after = await web3.eth.getBalance(accounts[0]);
        p2_eth_after = await web3.eth.getBalance(accounts[1]);
        console.log("player1 ETH balance after rewarding the winner = ", p1_eth_after);
        console.log("player2 ETH balance after rewarding the winner = ", p2_eth_after);

        assert.isAbove(Number(p2_eth_after), Number(p2_eth_before));



    });
   
   
    


})