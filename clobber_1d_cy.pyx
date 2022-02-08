# Cmput 655 sample code
# 1xn Clobber game board, rules, and a random game simulator
# Includes the code() method to compute a "hash code" for 
# use in a transposition table (This is actually a perfect code, 
# not a hash code, since the state space is so small)
# Written by Martin Mueller

import random
from game_basics import EMPTY, BLACK, WHITE, isEmptyBlackWhite, opponent
import heapq

cdef class Clobber_1d(object):
# Board is stored in 1-d array of EMPTY, BLACK, WHITE

    cdef list init_board
    cdef list board
    cdef list moves
    cdef short toPlay

    def custom_board(self, start_position): # str of B, W, E or .
        cpdef dict color_map = { 'B': BLACK, 'W': WHITE, 'E': EMPTY, '.': EMPTY }
        board = []
        for c in start_position:
            board.append(color_map[c])
        return board
    
    def getToPlay(self):
        return self.toPlay
    
    def __init__(self, start_position, first_player): 
        # we take either a board size for standard "BWBW...", 
        # or a custom start string such as "BWEEWWB"

        assert type(start_position) == str
        self.board = self.custom_board(start_position)
        self.toPlay = first_player
        self.moves = []

    def opp_color(self):
        return opponent(self.toPlay)
        
    def switchToPlay(self):
        self.toPlay = self.opp_color()

    cpdef void play(self, tuple move):
        cdef short src = move[0]
        cdef short to = move[1]
        
        assert self.board[src] == self.toPlay
        assert self.board[to] == self.opp_color()
        self.board[src] = EMPTY
        self.board[to] = self.toPlay
        self.moves.append(move)
        self.switchToPlay()

    cpdef void undoMove(self):
        self.switchToPlay()
        src, to = self.moves.pop()
        assert self.board[src] == EMPTY
        assert self.board[to] == self.toPlay
        self.board[to] = self.opp_color()
        self.board[src] = self.toPlay
    
    def winner(self):
        if self.endOfGame():
            return self.opp_color()
        else:
            return EMPTY

    cpdef list legalMoves(self):
        # To do: this is super slow. Should keep track of moves
        cdef list moves = []
        cdef opp = self.opp_color()
        cdef short last = len(self.board) - 1
        for i, p in enumerate(self.board):
            if p == self.toPlay:
                if i > 0 and self.board[i-1] == opp:
                    moves.append((i, i-1))
                if i < last and self.board[i+1] == opp:
                    moves.append((i, i+1))
        return moves
    
    cpdef list get_opponents_moves(self, current_legal_moves, m, current, opposite):
        cdef list current_copy = current_legal_moves.copy()   
        cdef short src = m[0]
        cdef short to = m[1]
        
        cdef list elements_to_be_removed_from_current = [m]

        # Check if there is next element. 
        if(to > src):
            if (to != len(self.board) - 1): # Next element.
                if (self.board[to + 1] == current):
                    elements_to_be_removed_from_current.insert(0, (to + 1, to))
                elif(self.board[to + 1] == opposite):
                    current_copy.append((to, to + 1))
            if(src != 0 and self.board[src - 1] == opposite): # Prev element.
                    elements_to_be_removed_from_current.insert(0, (src, src - 1))
        else:
            if (to != 0): 
                if(self.board[to - 1] == current):
                    elements_to_be_removed_from_current.insert(0, (to - 1, to))
                elif(self.board[to - 1] == opposite):
                    current_copy.append((to, to - 1))
            if(src != len(self.board) - 1 and self.board[src + 1] == opposite): 
                elements_to_be_removed_from_current.insert(0, (src, src + 1))

        # Remove in O(N) and swap.
        current_copy = [(e[1], e[0]) for e in current_copy if e not in elements_to_be_removed_from_current]
        return current_copy
