module Data.Filter

import Data.DList
import Data.List.Predicates.Interleaving

%default total
%access public export

data Filter : (holdsFor : type -> Type)
           -> (input : List type)
           -> Type where
  MkFilter : (kept : List type)
          -> (prfOrdering : Interleaving kept thrown input)
          -> (prfKept     : DList type holdsFor kept)
          -> (prfThrown   : DList type (Not . holdsFor) thrown)
          -> Filter holdsFor input

filter : (test   : (value : type) -> Dec (holds value))
      -> (input  : List type)
      -> Filter holds input
filter test [] = MkFilter [] Empty [] []
filter test (x :: xs) with (filter test xs)
  filter test (x :: xs) | (MkFilter kept prfOrdering prfKept prfThrown) with (test x)
    filter test (x :: xs) | (MkFilter kept prfOrdering prfKept prfThrown) | (Yes prf) =
      MkFilter (x::kept) (LeftAdd x prfOrdering) (prf :: prfKept) prfThrown
    filter test (x :: xs) | (MkFilter kept prfOrdering prfKept prfThrown) | (No contra) =
      MkFilter kept (RightAdd x prfOrdering) prfKept (contra :: prfThrown)
