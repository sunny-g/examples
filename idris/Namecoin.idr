module Namecoin

import Ethereum

db : MapField
db = EMIntInt "db"

register : Int -> Int -> Eff () [STORE]
register k v = write db k v

get : Int -> Eff Int [STORE]
get k = read db k
