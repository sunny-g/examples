module Bank

import Effects
import Ethereum
import Types

namespace Bank
  deposit : {v : Nat} -> Eff () [ETHEREUM (Init v)] [ETHEREUM (Finished 0 v)]
  deposit {v} = do
    save v
    finish

namespace Main
  main : IO ()
  main = runInit [MkS 10 0 0] deposit
