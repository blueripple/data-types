{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE DerivingVia     #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE GADTs             #-}
{-# LANGUAGE GeneralizedNewtypeDeriving             #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TupleSections   #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}

module BlueRipple.Data.Types.Modeling
  (
    module BlueRipple.Data.Types.Modeling
  )
where


import qualified Flat
import qualified Frames as F
import qualified Frames.InCore                 as FI
import qualified Frames.Transform              as FT
import qualified Data.Vinyl.Derived                    as V
import qualified Data.Vinyl.TypeLevel                    as V
import qualified Data.Vector.Unboxed           as UVec
import           Data.Vector.Unboxed.Deriving   (derivingUnbox)
import qualified Data.Default as Def

-- Flat for caching
-- FI.VectorFor for frames
-- Grouping for leftJoin
-- FiniteSet for composition of aggregations
data ConfidenceInterval = ConfidenceInterval
                          { ciLower :: !Double
                          , ciMid :: !Double
                          , ciUpper :: !Double
                          } deriving stock (Eq, Ord, Show, Generic)
instance Flat.Flat ConfidenceInterval

type instance FI.VectorFor ConfidenceInterval = UVec.Vector

derivingUnbox "ConfidenceInterval"
  [t|ConfidenceInterval->(Double, Double, Double)|]
  [|\(ConfidenceInterval x y z) -> (x, y, z)|]
  [|\(x, y, z) -> ConfidenceInterval x y z|]

listToCI :: [Double] -> Either Text ConfidenceInterval
listToCI (x : (y : (z : []))) = Right $ ConfidenceInterval x y z
listToCI l = Left $ "listToCI: " <> show l <> "is wrong size list.  Should be exactly 3 elements."

keyedCIsToFrame :: forall t f k ks.
                   (V.KnownField t
                   , V.Snd t ~ ConfidenceInterval
                   , Traversable f
                   , FI.RecVec (ks V.++ '[t]))
                => (k -> F.Record ks)
                -> f (k,[Double])
                -> Either Text (F.FrameRec (ks V.++ '[t]))
keyedCIsToFrame keyToRec kvs =
  let g (k, ds) = (\ci -> keyToRec k F.<+> FT.recordSingleton @t ci) <$> listToCI ds
  in F.toFrame <$> traverse g kvs


type ModelId t = "ModelId" F.:-> t


newtype MaybeData a = MaybeData { unMaybeData :: Maybe a }
  deriving stock (Eq, Ord, Show, Generic)
  deriving newtype (Functor, Applicative, Monad)

instance Flat.Flat a => Flat.Flat (MaybeData a)
derivingUnbox "MaybeData"
  [t|forall a. (Def.Default a, UVec.Unbox a) => MaybeData a -> (Bool, a)|]
  [|\(MaybeData ma) -> maybe (False, Def.def) (True,) ma|]
  [|\(b, a) -> MaybeData $ if b then Just a else Nothing |]
type instance FI.VectorFor (MaybeData a) = UVec.Vector
