{-# LANGUAGE TemplateHaskell, DataKinds, PolyKinds, TypeFamilies, TypeOperators,
             GADTs, CPP, ScopedTypeVariables, DeriveDataTypeable #-}

#if __GLASGOW_HASKELL__ < 707
{-# OPTIONS_GHC -fno-warn-name-shadowing #-}
#endif

-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Singletons.Prelude.Bool
-- Copyright   :  (C) 2013-2014 Richard Eisenberg, Jan Stolarek
-- License     :  BSD-style (see LICENSE)
-- Maintainer  :  Richard Eisenberg (eir@cis.upenn.edu)
-- Stability   :  experimental
-- Portability :  non-portable
--
-- Defines functions and datatypes relating to the singleton for 'Bool',
-- including a singletons version of all the definitions in @Data.Bool@.
--
-- Because many of these definitions are produced by Template Haskell,
-- it is not possible to create proper Haddock documentation. Please look
-- up the corresponding operation in @Data.Bool@. Also, please excuse
-- the apparent repeated variable names. This is due to an interaction
-- between Template Haskell and Haddock.
--
----------------------------------------------------------------------------

module Data.Singletons.Prelude.Bool (
  -- * The 'Bool' singleton

  Sing(SFalse, STrue),
  -- | Though Haddock doesn't show it, the 'Sing' instance above declares
  -- constructors
  --
  -- > SFalse :: Sing False
  -- > STrue  :: Sing True

  SBool,
  -- | 'SBool' is a kind-restricted synonym for 'Sing': @type SBool (a :: Bool) = Sing a@

  -- * Conditionals
  If, sIf,

  -- * Singletons from @Data.Bool@
  Not, sNot, (:&&), (:||), (%:&&), (%:||),

  -- | The following are derived from the function 'bool' in @Data.Bool@. The extra
  -- underscore is to avoid name clashes with the type 'Bool'.
  Bool_, sBool_, Otherwise, sOtherwise,

  -- * Defunctionalization symbols
  TrueSym0, FalseSym0,

  NotSym0, NotSym1,
  (:&&$), (:&&$$), (:&&$$$),
  (:||$), (:||$$), (:||$$$),
  Bool_Sym0, Bool_Sym1, Bool_Sym2, Bool_Sym3,
  OtherwiseSym0
  ) where

import Data.Singletons
import Data.Singletons.Prelude.Instances
import Data.Singletons.Single
import Data.Singletons.Types
import Data.Singletons.SuppressUnusedWarnings

#if __GLASGOW_HASKELL__ >= 707
import Data.Type.Bool

type a :&& b = a && b
type a :|| b = a || b

(%:&&) :: SBool a -> SBool b -> SBool (a :&& b)
SFalse %:&& _ = SFalse
STrue  %:&& a = a

type (:&&$$$) a b = a :&& b

data (:&&$$) (a :: Bool) (b :: TyFun Bool Bool) where
     (:&&$$###) :: Apply ((:&&$$) a) arg ~ (:&&$$$) a arg
                => Proxy arg
                -> (:&&$$) a b
type instance Apply ((:&&$$) a) b = (:&&$$$) a b

instance SuppressUnusedWarnings (:&&$$) where
    suppressUnusedWarnings _ = snd ((:&&$$###),())

data (:&&$) (a :: TyFun Bool (TyFun Bool Bool -> *)) where
     (:&&$###) :: Apply (:&&$) arg ~ (:&&$$) arg
               => Proxy arg
               -> (:&&$) a
type instance Apply (:&&$) a = (:&&$$) a

instance SuppressUnusedWarnings (:&&$) where
    suppressUnusedWarnings _ = snd ((:&&$###),())

(%:||) :: SBool a -> SBool b -> SBool (a :|| b)
SFalse %:|| a = a
STrue  %:|| _ = STrue

type (:||$$$) a b = a :|| b

data (:||$$) (a :: Bool) (b :: TyFun Bool Bool) where
     (:||$$###) :: Apply ((:||$$) a) arg ~ (:||$$$) a arg
                => Proxy arg
                -> (:||$$) a b
type instance Apply ((:||$$) a) b = (:||$$$) a b

instance SuppressUnusedWarnings (:||$$) where
    suppressUnusedWarnings _ = snd ((:||$$###),())

data (:||$) (a :: TyFun Bool (TyFun Bool Bool -> *)) where
     (:||$###) :: Apply (:||$) arg ~ (:||$$) arg
               => Proxy arg
               -> (:||$) a
type instance Apply (:||$) a = (:||$$) a

instance SuppressUnusedWarnings (:||$) where
    suppressUnusedWarnings _ = snd ((:||$###),())

#else

$(singletonsOnly [d|
  (&&) :: Bool -> Bool -> Bool
  False && _ = False
  True  && x = x

  (||) :: Bool -> Bool -> Bool
  False || x = x
  True  || _ = True
  |])

#endif

sNot :: SBool a -> SBool (Not a)
sNot SFalse = STrue
sNot STrue  = SFalse

type NotSym1 a = Not a
data NotSym0 (t :: TyFun Bool Bool) where
     NotSym0KindInference :: Apply NotSym0 arg ~ NotSym1 arg
                          => Proxy arg
                          -> NotSym0 a
type instance Apply NotSym0 a = Not a

instance SuppressUnusedWarnings NotSym0 where
    suppressUnusedWarnings _ = snd (NotSym0KindInference,())

-- | Conditional over singletons
sIf :: Sing a -> Sing b -> Sing c -> Sing (If a b c)
sIf STrue b _ = b
sIf SFalse _ c = c

-- ... with some functions over Booleans
$(singletonsOnly [d|
  bool_ :: a -> a -> Bool -> a
  bool_ fls _tru False = fls
  bool_ _fls tru True  = tru

  otherwise               :: Bool
  otherwise               =  True
  |])
