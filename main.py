from clobber_1d_cy import Clobber_1d
from game_basics import BLACK, WHITE
from transposition_table_simple_cy import TranspositionTable
from boolean_negamax_tt_cy import timed_solve as timed_solve_hash
import sys

mode = "test" # run or test

def test_solve_with_tt(state, player, time_limit, board):
    tt = TranspositionTable()
    isWin, win_move, timeUsed, node_count =  timed_solve_hash(state, tt, float(time_limit), board)

    if(isWin == None):
        isWin = "?"
    elif((player == BLACK and isWin) or (player == WHITE and not isWin)):
        isWin = "B"
    elif((player == BLACK and not isWin) or (player == WHITE and isWin)):
        isWin = "W"

    if mode == "run":
        print("{} {} {:.4f} {}\n".format(isWin, win_move, timeUsed, node_count))
    
    return isWin, win_move, timeUsed, node_count

def run_small_test_cases():
    smallTestCases = open("tests_small.txt", "r")
    # Read a file
    
    testCases = smallTestCases.readlines()
    for test in testCases:
        # Split by " "
        board, player, time_limit = test.split(" ")
        state = Clobber_1d(board)
        isWin, win_move, timeUsed, node_count = test_solve_with_tt(state, WHITE if player == "W" else BLACK, time_limit, board)

        # Open tests_small_results.txt and write the result
        logs_file = open("tests_small_results.txt", "a") 
        # Write test.
        logs_file.write(test)
        # Write result.
        logs_file.write("{} {} {:.4f} {}\n".format(isWin, win_move, timeUsed, node_count))
        # empty line.
        logs_file.write("\n")
        logs_file.close()

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
            test_solve_with_tt(state, player, time_limit, board)
        else:
            print(f"Misisng Arguments")
    else: run_small_test_cases() 