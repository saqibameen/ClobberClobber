# Cmput 455 sample code
# Boolean Negamax
# Written by Martin Mueller

import random
import time

from game_basics import BLACK, COLOR_MAPPING, colorAsString, isBlackWhite, opponent
from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.utility cimport pair


win_move = None
cdef long long node_count = 0
cdef double start = time.process_time()

cdef storeResult(tt, board_hash, result):
    tt.store(board_hash, result)
    return result

cdef negamaxBoolean(state, tt, time_limit, board_hash, hash_list, current_legal_moves, current, opposite):
    global win_move, node_count, start
    node_count += 1
    result = tt.lookup(board_hash)
    if result != None:
        return result, win_move
    if len(current_legal_moves) == 0:
        return storeResult(tt, board_hash, False), win_move

    for m in current_legal_moves:
        
        opp_moves = state.get_opponents_moves(current_legal_moves, m, current, opposite)

        changed_position = hash_list[opposite-1][m[1]]
        updated_hash = board_hash ^ changed_position ^ hash_list[current-1][m[1]] ^ hash_list[current-1][m[0]]

        state.play(m)

        success = not negamaxBoolean(state, tt, time_limit, updated_hash, hash_list, opp_moves, opposite, current)[0]
        state.undoMove()
        timeUsed = time.process_time() - start
        if(timeUsed >= time_limit):
            win_move = None
            return None, None
        elif success:
                win_move = m
                return storeResult(tt, board_hash, True), win_move
    return storeResult(tt, board_hash, False), None

def timed_solve(state, tt, time_limit, board): 
    global start
    start = time.process_time()
    cdef list hash_list = generate_hash(board)
    cdef unsigned long long board_hash = generate_board_hash(board, hash_list)
    cdef vector[pair[short, short]] current_legal_moves = state.legalMoves()
    
    cdef short current = state.getToPlay()
    cdef short opposite =  2 + 1 - current

    win, m = negamaxBoolean(state, tt, time_limit, board_hash, hash_list, current_legal_moves, current, opposite)
    timeUsed = time.process_time() - start
    return win, m, timeUsed, node_count

cdef list generate_hash(board):
        cdef list hash_list = [[],[]]
        for _ in range(len(board)):
            hash_list[0].append(random.randint(1, 2**64 - 1))
            hash_list[1].append(random.randint(1, 2**64 - 1))

        # Check all the entries are unique.
        # assert len(hash_list[0]) == len(set(hash_list[0]))
        # assert len(hash_list[1]) == len(set(hash_list[1]))

        return hash_list

# Initial board hash
cdef unsigned long long generate_board_hash(board, hash_list): 
    # Calculate hash code
    cdef unsigned long long hash_code = 0
    for index, value in enumerate(board):
        if value == '.': continue
        hash_code = hash_code ^ hash_list[COLOR_MAPPING[value]-1][index]
    return hash_code