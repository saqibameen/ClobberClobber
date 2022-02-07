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


cdef class Clobber_1d(object):
# Board is stored in 1-d array of EMPTY, BLACK, WHITE


    cdef vector[int] board
    cdef vector[int[2]] moves
    cdef int toPlay
            
    cpdef vector[int] custom_board(self, str start_position): # str of B, W, E or .
        cpdef dict color_map = { 'B': BLACK, 'W': WHITE, 'E': EMPTY, '.': EMPTY }

        for c in start_position:
            self.board.push_back(color_map[c])

        print(f"self.board: {self.board}")
        return self.board

    def __init__(self, str start_position, int first_player): 
        # we take either a board size for standard "BWBW...", 
        # or a custom start string such as "BWEEWWB"

        assert type(start_position) == str
        self.board = self.custom_board(start_position)
        self.toPlay = first_player
        # self.moves = []
    

    cpdef int getToPlay(self):
        return self.toPlay

    cpdef int opp_color(self):
        cdef int temp = 2 + 1 - self.toPlay
        return temp
        
    cpdef void switchToPlay(self):
        self.toPlay = self.opp_color()

    # TODO: int[2] move declaration
    cpdef void play(self, int move_0, int move_1):
        cdef int src = move_0
        cdef int to = move_1
        cdef int[2] typedMove = [move_0, move_1]

        assert self.board[src] == self.toPlay
        assert self.board[to] == self.opp_color()
        self.board[src] = EMPTY
        self.board[to] = self.toPlay
        self.moves.push_back(typedMove)
        self.switchToPlay()

    cpdef void undoMove(self):
        self.switchToPlay()
        # TODO moves.back() what does it return?
        cdef int[2] move_t = self.moves.back()
        cdef int src = move_t[0] 
        cdef int to = move_t[1]
        self.moves.pop_back()

        print(f"src: {src} , to: {to}")

        assert self.board[src] == EMPTY
        assert self.board[to] == self.toPlay
        self.board[to] = self.opp_color()
        self.board[src] = self.toPlay
    

    cpdef vector[int[2]] legalMoves(self):
        # To do: this is super slow. Should keep track of moves
        cdef vector[int[2]] moves
        cdef int opp = self.opp_color()
        cdef int last = len(self.board) - 1
        cdef int p
        for i in range(len(self.board)):
            p = self.board[i]
            if p == self.toPlay:
                if i > 0 and self.board[i-1] == opp:
                    moves.push_back([i, i-1])
                if i < last and self.board[i+1] == opp:
                    moves.push_back([i, i+1])
        return moves
    
        
    cpdef vector[int[2]] get_opponents_moves(self, current_legal_moves, m, current, opposite):
        cdef vector[int[2]] current_copy = current_legal_moves.copy()
        cdef int src = m[0]
        cdef int to = m[1]
        
        cdef vector[int[2]] elements_to_be_removed_from_current = [m]

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
        cdef vector[int[2]] return_current_copy

        for i in range(len(current_copy)):
            e = current_copy[i]
            for j in range(len(elements_to_be_removed_from_current)):
                k = elements_to_be_removed_from_current[j]
                if(e[0] == k[0] and e[1] == k[1]):
                    continue
                else:
                    return_current_copy.push_back([e[1], e[0]])
        # current_copy = [(e[1], e[0]) for e in current_copy if e not in elements_to_be_removed_from_current]
        return return_current_copy