module Singletons.Operators where

import Data.Singletons.TH
import Singletons.Nat

$(singletons [d|
  data Foo where
    FLeaf :: Foo
    (:+:) :: Foo -> Foo -> Foo

  child :: Foo -> Foo
  child FLeaf = FLeaf
  child (a :+: _) = a

  (+) :: Nat -> Nat -> Nat
  Zero + m = m
  (Succ n) + m = Succ (n + m)
 |])
