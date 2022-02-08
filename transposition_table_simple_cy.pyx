# Cmput 455 sample code
# Simple transposition table for TicTacToe solver
# This is much slower than an array-based table
# which is used in competitive programs
# Written by Martin Mueller

import random


COLOR_MAPPING = {
    ".": 0,
    "B": 1,
    "W": 2
}
cdef class TranspositionTable():
# Table is stored in a dictionary, with board code as key, 
# and minimax score as the value
    # Empty dictionary

    cdef dict table

    def __init__(self):
        self.table = {}

    # Used to print the whole table with print(tt)
    def __repr__(self):
        return self.table.__repr__()
        
    cpdef void store(self, unsigned long int code, score):
        self.table[code] = score
    
    # Python dictionary returns 'None' if key not found by get()
    def lookup(self, unsigned long int code):
        return self.table.get(code)