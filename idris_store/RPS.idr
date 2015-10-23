module Transactions

import Effects
import Effect.State
import Effect.StdIO
import Data.HVect
import GeneralStore
import Control.IOExcept
import Ethereum

store : Store 4
store = [EArray 2 EAddress, EArray 2 EInt, EInt, EInt]

Contract : (x : Type) -> (ce : x -> List EFFECT) -> Type
Contract x ce = {m : Type -> Type} -> {b : Nat} -> {v : Nat} -> EffM m x [ETHEREUM (Init v b)] ce

-- runContract : Applicative m => (v : Nat) -> (c : Contract x ce) -> m x
-- runContract v c = runInit [Running 100 100 0 0] c
namespace TestContract
  playerChoice : Int -> {n : Nat} -> (v : Nat) -> Contract Bool
                          (\succ => if succ
                          then [ETHEREUM (Finished n 1)]
                          else [ETHEREUM (Finished v 0)])
  playerChoice c v {n} = do
    if c < 1 -- !(read pc) < 1 
      then do
        send n
        save 1
        finish
        pureM True
      else do
        send v
        finish
        pureM False

    --pc <- read playerCount
            {-
    if pc < 2
       then ( do save 1; send n; return True)
         --write reward $ (!read reward ) + 1
         --write (players pc) !sender
         --write (choices pc) c
         --write playerCount (pc + 1)
         --   save 1
        --    return True
       else (do save (S n); send (S n); return False)
                -}
namespace Main
  main : IO ()
  main = do
    printLn "Running stuff"
    --runPureInit [(), Ethereum (Running 100 100 0 0)] (playerChoice 1 100)
    runInit [()] (playerChoice 1 100)
    --runInit [(), Ethereum (Running 100 100 0 0)] (playerChoice 1 100)
    --runInit [()] (playerChoice 1 100)
    return ()
    --run implicitSave

