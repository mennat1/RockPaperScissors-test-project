// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

contract RockPaperScissors {
    address public player1;
    address public player2;
    bytes32 public hash1;
    bytes32 public hash2;
    string public player1_move;
    string public player2_move;
    uint public stake;

    event player1_enrolled(address p1);
    event player2_enrolled(address p2);
    event player1_won(address p1);
    event player2_won(address p2);
    event draw_game(address p1, address p2);

    modifier both_players_committed_moves{
        require((hash1 != bytes32(0)) && (hash2 != bytes32(0)));
        _;
    }

    modifier both_players_revealed_moves{
        require(keccak256(abi.encodePacked(player1_move)) != keccak256(abi.encodePacked("")));
        require(keccak256(abi.encodePacked(player2_move)) != keccak256(abi.encodePacked("")));
        _;
    }

    modifier valid_move(string memory move){
        require( 
            (keccak256(abi.encodePacked(move)) == keccak256(abi.encodePacked("ROCK"))) ||
            (keccak256(abi.encodePacked(move)) == keccak256(abi.encodePacked("PAPER"))) ||
            (keccak256(abi.encodePacked(move)) == keccak256(abi.encodePacked("SCISSORS")))
        );
        _;
       
    }

    function enroll() public payable{
        require(msg.value >= 1 ether);
        if(player1 == address(0)){
            player1 = msg.sender;
            stake += msg.value - 0.2 ether; // 0.2 ether are given to the contract for each enrolled player
            emit player1_enrolled(msg.sender);

        }else if(player2 == address(0)){
            player2 = msg.sender;
            stake += msg.value - 0.2 ether; // 0.2 ether are given to the contract for each enrolled player
            emit player2_enrolled(msg.sender);

        }else{
            revert("Two players are already enrolled");
        }
    }

    function commitMove(string memory move, string memory secret_phrase) public valid_move(move) {
        if(msg.sender == player1){
            require(hash1 == bytes32(0)); // i.e. didn't commit before
            hash1 = keccak256(abi.encodePacked(move,secret_phrase));
            

        }else if(msg.sender == player2){
            require(hash2 == bytes32(0)); // i.e. didn't commit before
            hash2 = keccak256(abi.encodePacked(move,secret_phrase));


        }else{
            revert("Wrong address");
        }
    }

    function revealMove(string memory move, string memory secret_phrase) public both_players_committed_moves() valid_move(move) {
        if(msg.sender == player1){
            require(hash1 == keccak256(abi.encodePacked(move,secret_phrase)));
            player1_move = move;
            

        }else if(msg.sender == player2){
            require(hash2 == keccak256(abi.encodePacked(move,secret_phrase)));
            player2_move = move;


        }else{
            revert("Wrong address");
        }

        // if both players revealed their moves
        if(
            (keccak256(abi.encodePacked(player1_move)) != keccak256(abi.encodePacked(""))) &&
            (keccak256(abi.encodePacked(player2_move)) != keccak256(abi.encodePacked("")))
        ){

            reward_players();

        }

    }

    function reward_players() private both_players_committed_moves() both_players_revealed_moves() valid_move(player1_move) valid_move(player2_move){
        if( 
            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("ROCK"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("ROCK")))) ||

            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("PAPER"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("PAPER")))) ||

            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("SCISSORS"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("SCISSORS"))))
        ){ // DRAW
            payable(player1).transfer((stake/2));
            stake -= (stake/2);
            payable(player2).transfer(stake);
            stake = 0;
            emit draw_game(player1, player2);

        }else if(
            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("ROCK"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("SCISSORS")))) ||

            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("PAPER"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("ROCK")))) ||

            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("SCISSORS"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("PAPER")))) 



        ){ // player1 wins
            payable(player1).transfer(stake);
            stake = 0;
            emit player1_won(player1);

        }else if(
            ((keccak256(abi.encodePacked(player1_move))== keccak256(abi.encodePacked("PAPER"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("SCISSORS")))) ||

            
            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("SCISSORS"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("PAPER")))) ||

            ((keccak256(abi.encodePacked(player1_move)) == keccak256(abi.encodePacked("ROCK"))) &&
            (keccak256(abi.encodePacked(player2_move)) == keccak256(abi.encodePacked("PAPER")))) 

        ){ // player2 wins
            payable(player2).transfer(stake);
            stake = 0;
            emit player2_won(player2);
        }

    }









}