from clobber_1d import Clobber_1d
from game_basics import BLACK, WHITE, colorAsString
from transposition_table_simple import TranspositionTable
from boolean_negamax_tt import timed_solve as timed_solve_hash
from negamax_no_hash import timed_solve as timed_solve_no_hash
from bool_negamax_o4 import timed_solve as timed_solve_o4
from boolean_negamax_tt_ids import timed_solve as timed_solve_ids
import time
import sys

mode = "test" # run or test
player_to_char = {'.': 0,
                  'B': 1,
                  'W': 2}

char_to_player = {0: '.',
                  1: 'B',
                  2: 'W'}

def test_solve_with_tt(state, player, time_limit, board):
    tt = TranspositionTable()
    isWin, win_move, timeUsed, node_count =  timed_solve_hash(state, tt, time_limit, board)

    if(isWin == None):
        isWin = "?"
    elif((player == BLACK and isWin) or (player == WHITE and not isWin)):
        isWin = "B"
    elif((player == BLACK and not isWin) or (player == WHITE and isWin)):
        isWin = "W"

    # print("{} {} {:.4f} {}\n".format(isWin, win_move, timeUsed, node_count))
    result = "{} {}".format(isWin, win_move)
    return isWin, win_move, timeUsed

def test_solve_with_tt_ids(state, player, time_limit, board):
    max_depth = 1000
    tt = TranspositionTable()
    isWin, win_move, timeUsed, node_count, depth =  timed_solve_ids(state, tt, time_limit, board, max_depth)
        
    if(isWin == None):
        isWin = "?"
    elif((player == BLACK and isWin) or (player == WHITE and not isWin)):
        isWin = "B"
    elif((player == BLACK and not isWin) or (player == WHITE and isWin)):
        isWin = "W"
        
    # print("{} {} {:.4f} {} {}".format(isWin, win_move, timeUsed, node_count, depth))
    
    result = "{} {}".format(isWin, win_move)
    return isWin, win_move, timeUsed

def test_solve_with_tt_no_hash(state, player, time_limit, board):
    tt = TranspositionTable()
    isWin, win_move, timeUsed, node_count =  timed_solve_no_hash(state, tt, time_limit, board)

    if(isWin == None):
        isWin = "?"
    elif((player == BLACK and isWin) or (player == WHITE and not isWin)):
        isWin = "B"
    elif((player == BLACK and not isWin) or (player == WHITE and isWin)):
        isWin = "W"

    print("{} {} {:.4f} {}\n".format(isWin, win_move, timeUsed, node_count))
    result = "{} {}".format(isWin, win_move)
    return isWin, win_move, timeUsed

def verify_results_zobrist_hash():
    test_cases = open("testcases.txt", "r").readlines()
    test_cases = [x.strip() for x in test_cases]
    time_limit = 10 # base time limit, in seconds
    for test_no, test_case in enumerate(test_cases):
        board, player_char = test_case.split()

        if(player_char == "B"):
            player = BLACK
        else:
            player = WHITE

        state = Clobber_1d(board, player)
        result_hash, _, timeUsed_hash = test_solve_with_tt(state, player, time_limit, board)
        result_ids, _, timeUsed_ids = test_solve_with_tt_ids(state, player, time_limit, board)

        # The result should be same, not the move. IDS may or may not find a different move.

        if result_hash != result_ids:
            print(f"Test No. {test_no} | Board: {board} | Player to Play: {player_char}")
            print("Result Hash: {} | Time Hash: {:.4f}".format(result_hash, timeUsed_hash))
            print("Result IDS: {} | Time IDS: {:.4f}".format(result_ids, timeUsed_ids))
            print()
        else:
            assert result_hash == result_ids
            print("Test No. {} Passed! | Time Hash: {:.4f} | Time IDS {:.4f} | Board: {}".format(test_no, timeUsed_hash, timeUsed_ids, board))

if __name__ == "__main__":
    if mode == "run":
        if(len(sys.argv) == 4):
            board = str(sys.argv[1]).upper()
            player = str(sys.argv[2]).upper()
            time_limit = float(sys.argv[3])
            assert player == "B" or player == "W"

            if(player == "B"):
                player = BLACK
            else:
                player = WHITE

            state = Clobber_1d(board, player)
            # Playing the game, main
            test_solve_with_tt_ids(state, player, time_limit, board)
            # test_solve_with_tt(state, player, time_limit, board)
        else:
            print(f"Misisng Arguments")

    else: verify_results_zobrist_hash() # do the sanity check