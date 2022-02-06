# Cmput 655 sample code
# 1xn Clobber game board, rules, and a random game simulator
# Includes the code() method to compute a "hash code" for 
# use in a transposition table (This is actually a perfect code, 
# not a hash code, since the state space is so small)
# Written by Martin Mueller

import random
from game_basics import EMPTY, BLACK, WHITE, isEmptyBlackWhite, opponent
class Clobber_1d(object):
# Board is stored in 1-d array of EMPTY, BLACK, WHITE

    @classmethod
    def standard_board(cls, size):
        pairs = (size+1) // 2
        board = [BLACK, WHITE] * pairs
        return board[:size]
            
    @classmethod
    def custom_board(cls, start_position): # str of B, W, E or .
        color_map = { 'B': BLACK, 'W': WHITE, 'E': EMPTY, '.': EMPTY }
        board = []
        for c in start_position:
            board.append(color_map[c])
        return board
    
    @classmethod
    def to_string(cls, board):
        char_map = { BLACK: 'B', WHITE: 'W', EMPTY: '.'}
        s = ""
        for p in board:
            s += char_map[p]
        return s
        
    def __init__(self, start_position, first_player = WHITE): 
    # we take either a board size for standard "BWBW...", 
    # or a custom start string such as "BWEEWWB"
        if type(start_position) == int:
            self.init_board = Clobber_1d.standard_board(start_position)
        else:
            assert type(start_position) == str
            self.init_board = Clobber_1d.custom_board(start_position)
        self.resetGame(first_player)

    def resetGame(self, first_player):
        self.board = self.init_board
        self.toPlay = first_player
        self.moves = []

    def resetToMoveNumber(self, moveNr):
        numUndos = self.moveNumber() - moveNr
        assert numUndos >= 0
        for _ in range(numUndos):
            self.undoMove()
        assert self.moveNumber() == moveNr

    def opp_color(self):
        return opponent(self.toPlay)
        
    def switchToPlay(self):
        self.toPlay = self.opp_color()

    def play(self, move):
        src, to = move
        assert self.board[src] == self.toPlay
        assert self.board[to] == self.opp_color()
        self.board[src] = EMPTY
        self.board[to] = self.toPlay
        self.moves.append(move)
        self.switchToPlay()

    def undoMove(self):
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

    def staticallyEvaluateForToPlay(self):
        winColor = self.winner()
        return winColor == self.toPlay
    
    def heuristicEvaluation(self):
        # We should evaluate the board here and return a priority score
        return True
    
    def moveNumber(self):
        return len(self.moves)

    def endOfGame(self):
        return len(self.legalMoves()) == 0

    def legalMoves(self):
        # To do: this is super slow. Should keep track of moves
        moves = []
        opp = self.opp_color()
        last = len(self.board) - 1
        for i, p in enumerate(self.board):
            if p == self.toPlay:
                if i > 0 and self.board[i-1] == opp:
                    moves.append((i, i-1))
                if i < last and self.board[i+1] == opp:
                    moves.append((i, i+1))
        return moves

    def findNeighbors(self, m):
        min_i = min(m)
        max_i = max(m)

        idx = [min_i - 1, min_i, max_i, max_i + 1]
        board = list(map(self.board.__getitem__, idx))
        return board


    def legalMovesO4(self, moves):
        # To do: this is super slow. Should keep track of moves
        # moves = []
        if(len(moves) == 0):
            moves = []
            opp = self.opp_color()
            last = len(self.board) - 1
            for i, p in enumerate(self.board):
                if p == self.toPlay:
                    if i > 0 and self.board[i-1] == opp:
                        moves.append((i, i-1))
                    if i < last and self.board[i+1] == opp:
                        moves.append((i, i+1))
        else:
            m = self.moves[-1]
            board = self.findNeighbors(m)
            opp = self.opp_color()
            last = len(board) - 1
            for i, p in enumerate(board):
                if p == self.toPlay:
                    if i > 0 and board[i-1] == opp:
                        moves.append((i, i-1))
                    if i < last and board[i+1] == opp:
                        moves.append((i, i+1))

            moves.remove(m)
        return moves
    
    def legalMovesForBoth(self):
        moves = []
        opp_moves = []
        opp = self.opp_color()
        last = len(self.board) - 1
        for i, p in enumerate(self.board):
            if p == self.toPlay:
                if i > 0 and self.board[i-1] == opp:
                    moves.append((i, i-1))
                    opp_moves.append((i-1, i))
                if i < last and self.board[i+1] == opp:
                    moves.append((i, i+1))
                    opp_moves.append((i+1, i))
        return moves, opp_moves
        
    def get_opponents_moves(self, current_legal_moves, m, current, opposite):
        current_copy = current_legal_moves.copy()        
        src, to = m
        
        elements_to_be_removed_from_current = [m]

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

    def code(self):
        # To do: this is super slow. Should keep track of code
        c = 0
        for color in self.board:
            c = 3*c + color
        return 2*c + self.toPlay - 1 # BLACK = 1, WHITE = 2

    # simulate one game from the current state until the end
    def simulate(self):
        assert False # todo: this is for Tic Tac Toe, needs fixing for Clobber
        i = 0
        if not self.endOfGame():
            allMoves = self.legalMoves()
            random.shuffle(allMoves)
            while not self.endOfGame():
                self.play(allMoves[i])
                i += 1
        return self.winner(), i

    def print(self):
        print(Clobber_1d.to_string(self.board))