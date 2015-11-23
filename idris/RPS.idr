module Transactions

import Effects
import Effect.State
import Effect.StdIO
import Ethereum
import Data.Vect
import Data.HVect
import Types
import GeneralStore

playerCount : Field
playerCount = EInt 0

reward : Field
reward = EInt (index playerCount + size playerCount)

players : Nat -> Field
players i = EAddress (index reward + size reward + i)

moves : Nat -> Field
moves i = EInt (index (players 2) + size (players 2) + i)

winner : Integer -> Integer -> Integer
winner 0 0 = 2
winner 1 1 = 2
winner 2 2 = 2

winner 2 1 = 0
winner 1 2 = 1

winner 0 2 = 0
winner 2 0 = 1

winner 1 0 = 0
winner 0 1 = 1

namespace TestContract
  init : Eff () [STORE]
  init = do
    write playerCount 0

  playerChoice : Integer -> {v : Nat} -> { auto p : LTE 10 v } ->
                 Eff Bool [ETH_IN v, STORE] (\succ => if succ then [ETH_OUT (v-10) 10, STORE] else [ETH_OUT v 0, STORE])
  playerChoice {v} c = do
    pc <- read playerCount
    if pc < 2
     then do
        save 10
        write reward (!(read reward)+10)
        write (players (toNat pc)) !sender
        write (moves (toNat pc)) c
        write playerCount (pc+1)
        send (v-10) !sender
        finish
        pureM True
      else do
        s <- sender
        send v s
        finish
        pureM False

  --0 : player 1
  --1 : player 2
  --2 : draw
  --3 : not enough players joined
  check : Eff Integer [ETH_IN 0, STORE] (\winner => if winner == 3 then [ETH_OUT 0 0, STORE] else [ETH_OUT 20 0, STORE])
  check = do
    if !(read playerCount) == 2
       then do
         let w = winner !(read (moves 0)) !(read (moves 1))
         case w of
              2 => do
                send 10 !(read (players 0))
                send 10 !(read (players 1))
                finish
                pureM 2
              otherwise => do
                send 20 !(read (players (toNat w)))
                finish
                pureM 0
      else do
        finish
        pureM 3


  --saveMoney : Int -> Eff Bool [ETH_IN v] (resultEffect [ETH_OUT 0 v] [ETH_OUT v 0])
  {-
  saveMoney : Int -> resultEffect [ETH_IN v] [ETH_OUT 0 v] [ETH_OUT v 0]
  saveMoney {v} input =
    if input == 1
      then do
        save v
        finish
        pureM True
      else do
        send v !sender
        finish 
        pureM False
        -}

--runContract : Eff t 
namespace Main
  main : IO ()
  main = do
    res <- runInit [MkS 10 0 0, ()] (playerChoice 0)
    putStrLn . show $ res

