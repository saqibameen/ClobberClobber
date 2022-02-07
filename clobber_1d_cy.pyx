# Cmput 655 sample code
# 1xn Clobber game board, rules, and a random game simulator
# Includes the code() method to compute a "hash code" for 
# use in a transposition table (This is actually a perfect code, 
# not a hash code, since the state space is so small)
# Written by Martin Mueller

import random
from game_basics import EMPTY, BLACK, WHITE, isEmptyBlackWhite, opponent
import heapq
from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.utility cimport pair


cdef class Clobber_1d(object):
# Board is stored in 1-d array of EMPTY, BLACK, WHITE


    cdef vector[short] board
    cdef vector[pair[short, short]] moves
    cdef short toPlay
            
    cpdef vector[short] custom_board(self, str start_position): # str of B, W, E or .
        cpdef dict color_map = { 'B': BLACK, 'W': WHITE, 'E': EMPTY, '.': EMPTY }

        for c in start_position:
            self.board.push_back(color_map[c])

        return self.board

    def __init__(self, str start_position, short first_player): 
        # we take either a board size for standard "BWBW...", 
        # or a custom start string such as "BWEEWWB"

        assert type(start_position) == str
        self.board = self.custom_board(start_position)
        self.toPlay = first_player
        # self.moves = []
    

    cpdef short getToPlay(self):
        return self.toPlay

    cpdef short opp_color(self):
        cdef short temp = 2 + 1 - self.toPlay
        return temp
        
    cpdef void switchToPlay(self):
        self.toPlay = self.opp_color()

    # TODO: ValidMove move declaration
    cpdef void play(self, pair[short, short] move):
        cdef short src = move.first
        cdef short to = move.second

        assert self.board[src] == self.toPlay
        assert self.board[to] == self.opp_color()
        self.board[src] = EMPTY
        self.board[to] = self.toPlay
        self.moves.push_back(move)
        self.switchToPlay()

    cpdef void undoMove(self):
        self.switchToPlay()
        # TODO moves.back() what does it return?
        cdef pair[short, short] move_t = self.moves.back()
        cdef short src = move_t.first
        cdef short to = move_t.second
        self.moves.pop_back()

        assert self.board[src] == EMPTY
        assert self.board[to] == self.toPlay
        self.board[to] = self.opp_color()
        self.board[src] = self.toPlay
    

    cpdef vector[pair[short, short]] legalMoves(self):
        # To do: this is super slow. Should keep track of moves
        cdef vector[pair[short, short]] moves
        cdef short opp = self.opp_color()
        cdef short last = len(self.board) - 1
        cdef short p
        for i in range(len(self.board)):
            p = self.board[i]
            if p == self.toPlay:
                if i > 0 and self.board[i-1] == opp:
                    moves.push_back([i, i-1])
                if i < last and self.board[i+1] == opp:
                    moves.push_back([i, i+1])
        return moves
    
        
    cpdef vector[pair[short, short]] get_opponents_moves(self, vector[pair[short, short]] current_legal_moves, pair[short, short] m, short current, short opposite):

        cdef vector[pair[short, short]] current_copy

        for i in current_legal_moves:
            current_copy.push_back(i)

        cdef short src = m.first
        cdef short to = m.second
        
        cdef vector[pair[short, short]] elements_to_be_removed_from_current = [m]

        # Check if there is next element. 
        if(to > src):
            if (to != len(self.board) - 1): # Next element.
                if (self.board[to + 1] == current):
                    elements_to_be_removed_from_current.insert(elements_to_be_removed_from_current.begin(), [to + 1, to])
                elif(self.board[to + 1] == opposite):
                    current_copy.push_back([to, to + 1])
            if(src != 0 and self.board[src - 1] == opposite): # Prev element.
                    elements_to_be_removed_from_current.insert(elements_to_be_removed_from_current.begin(), [src, src - 1])
        else:
            if (to != 0): 
                if(self.board[to - 1] == current):
                    elements_to_be_removed_from_current.insert(elements_to_be_removed_from_current.begin(), [to - 1, to])
                elif(self.board[to - 1] == opposite):
                    current_copy.push_back([to, to - 1])
            if(src != len(self.board) - 1 and self.board[src + 1] == opposite): 
                elements_to_be_removed_from_current.insert(elements_to_be_removed_from_current.begin(), [src, src + 1])

        # Remove in O(N) and swap.
        cdef vector[pair[short, short]] return_current_copy

        # print(f"current_copy: {current_copy}")

        # print(f"elements_to_be_removed_from_current: {elements_to_be_removed_from_current}")

        for i in range(len(current_copy)):
            e = current_copy[i]
            exists = False 
            for j in range(len(elements_to_be_removed_from_current)):
                k = elements_to_be_removed_from_current[j]

                # print(f"E: {e} , K: {k}")
                if(e.first == k.first and e.second == k.second):
                    exists = True
                    break
            if(not exists):
                return_current_copy.push_back([e.second, e.first])
                    

        # print(f"Move: {m}")
        # print(f"return_current_copy: {return_current_copy}")
        # current_copy = [(e.second, e.first) for e in current_copy if e not in elements_to_be_removed_from_current]
        return return_current_copy