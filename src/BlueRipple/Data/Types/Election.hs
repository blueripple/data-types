{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module BlueRipple.Data.Types.Election
  (
    module BlueRipple.Data.Types.Election
  )
  where

import qualified Data.Default as Def
import Data.Discrimination (Grouping)
import qualified Data.Text as T
import qualified Data.Vector.Unboxed as UVec
import Data.Vector.Unboxed.Deriving (derivingUnbox)
import qualified Data.Vinyl as V
import qualified Flat
import qualified Frames as F
import qualified Frames.Streamly.InCore as FI
import qualified Frames.Streamly.TH as FS
import qualified Frames.ShowCSV as FCSV
import qualified Frames.Visualization.VegaLite.Data as FV
import qualified Graphics.Vega.VegaLite as GV

-- Serialize for caching
-- FI.VectorFor for frames
-- Grouping for leftJoin

data MajorPartyParticipation
  = Neither
  | JustR
  | JustD
  | Both
  deriving stock (Show, Enum, Eq, Ord, Bounded, Generic)

instance Flat.Flat MajorPartyParticipation
instance FCSV.ShowCSV MajorPartyParticipation
instance Grouping MajorPartyParticipation

{-basicUnsafeThaw :: Control.Monad.Primitive.PrimMonad m =>
FS.Vector MajorPartyParticipation
-> m (Data.Vector.Generic.Base.Mutable
        FS.Vector
        (Control.Monad.Primitive.PrimState m)
        MajorPartyParticipation)
-}
derivingUnbox
  "MajorPartyParticipation"
  [t|MajorPartyParticipation -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor MajorPartyParticipation = UVec.Vector

updateMajorPartyParticipation ::
  MajorPartyParticipation -> T.Text -> MajorPartyParticipation
updateMajorPartyParticipation Neither "republican" = JustR
updateMajorPartyParticipation Neither "democrat" = JustD
updateMajorPartyParticipation JustR "democrat" = Both
updateMajorPartyParticipation JustD "republican" = Both
updateMajorPartyParticipation x _ = x

FS.declareColumn "MajorPartyParticipationC" ''MajorPartyParticipation

data PartyT = Democratic | Republican | Other deriving stock (Show, Enum, Bounded, Eq, Ord, Generic)

instance Flat.Flat PartyT
instance Grouping PartyT
instance Def.Default PartyT where
  def = Other

instance FCSV.ShowCSV PartyT

derivingUnbox
  "PartyT"
  [t|PartyT -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor PartyT = UVec.Vector

FS.declareColumn "Party" ''PartyT

instance FV.ToVLDataValue (F.ElField Party) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Str $ show $ V.getField x)

data OfficeT = House | Senate | President deriving stock (Show, Enum, Bounded, Eq, Ord, Generic)

instance Flat.Flat OfficeT
instance Grouping OfficeT

instance FCSV.ShowCSV OfficeT

derivingUnbox
  "OfficeT"
  [t|OfficeT -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor OfficeT = UVec.Vector

FS.declareColumn "Office" ''OfficeT

instance FV.ToVLDataValue (F.ElField Office) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Str $ show $ V.getField x)


FS.declareColumn "Votes" ''Int

instance FV.ToVLDataValue (F.ElField Votes) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Number $ realToFrac $ V.getField x)

FS.declareColumn "TotalVotes" ''Int

instance FV.ToVLDataValue (F.ElField TotalVotes) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Number $ realToFrac $ V.getField x)

data PrefTypeT = VoteShare | Inferred | PSByVoted | PSByVAP deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)

FS.declareColumn "PrefType" ''PrefTypeT

instance Grouping PrefTypeT

instance Flat.Flat PrefTypeT

instance FCSV.ShowCSV PrefTypeT

derivingUnbox
  "PrefTypeT"
  [t|PrefTypeT -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor PrefTypeT = UVec.Vector

instance FV.ToVLDataValue (F.ElField PrefType) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Str $ show $ V.getField x)

data VoteShareType = TwoPartyShare | FullShare deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)
FS.declareColumn "VoteShareTypeC" ''VoteShareType

instance Grouping VoteShareType
instance Flat.Flat VoteShareType
instance FCSV.ShowCSV VoteShareType
derivingUnbox
  "VoteShareType"
  [t|VoteShareType -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

FS.declareColumn "ElectoralWeight" ''Double

instance FV.ToVLDataValue (F.ElField ElectoralWeight) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Number $ V.getField x)

data ElectoralWeightSourceT = EW_Census | EW_CCES | EW_Other deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)

FS.declareColumn "ElectoralWeightSource" ''ElectoralWeightSourceT

instance Grouping ElectoralWeightSourceT

instance Flat.Flat ElectoralWeightSourceT

instance FCSV.ShowCSV ElectoralWeightSourceT

derivingUnbox
  "ElectoralWeightSourceT"
  [t|ElectoralWeightSourceT -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor ElectoralWeightSourceT = UVec.Vector

instance FV.ToVLDataValue (F.ElField ElectoralWeightSource) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Str $ show $ V.getField x)

data ElectoralWeightOfT
  = -- | Voting Eligible Population
    EW_Eligible
  | -- | Voting Age Population (citizens only)
    EW_Citizen
  | -- | Voting Age Population (all)
    EW_All
  deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)

FS.declareColumn "ElectoralWeightOf" ''ElectoralWeightOfT

instance Grouping ElectoralWeightOfT

instance Flat.Flat ElectoralWeightOfT

instance FCSV.ShowCSV ElectoralWeightOfT

derivingUnbox
  "ElectoralWeightOfT"
  [t|ElectoralWeightOfT -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor ElectoralWeightOfT = UVec.Vector

type EWCols = [ElectoralWeightSource, ElectoralWeightOf, ElectoralWeight]

ewRec :: ElectoralWeightSourceT -> ElectoralWeightOfT -> Double -> F.Record EWCols
ewRec ws wo w = ws F.&: wo F.&: w F.&: V.RNil

FS.declareColumn "CVAP" ''Int
FS.declareColumn "VAP" ''Int
FS.declareColumn "VEP" ''Int

instance FV.ToVLDataValue (F.ElField CVAP) where
  toVLDataValue x = (toText $ V.getLabel x, GV.Number $ realToFrac $ V.getField x)

data VoteWhyNot
  = VWN_PhysicallyUnable
  | VWN_Away
  | VWN_Forgot
  | VWN_NotInterested
  | VWN_Busy
  | VWN_Transport
  | VWN_DislikeChoices
  | VWN_RegIssue
  | VWN_Weather
  | VWN_BadPollingPlace
  | VWN_Other
  deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)

FS.declareColumn "VoteWhyNotC" ''VoteWhyNot

instance Grouping VoteWhyNot

instance Flat.Flat VoteWhyNot

instance FCSV.ShowCSV VoteWhyNot

derivingUnbox
  "VoteWhyNot"
  [t|VoteWhyNot -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor VoteWhyNot = UVec.Vector

data RegWhyNot
  = RWN_MissedDeadline
  | RWN_DidntKnowHow
  | RWN_Residency
  | RWN_PhysicallyUnable
  | RWN_Language
  | RWN_NotInterested
  | RWN_MyVoteIrrelevant
  | RWN_Other
  deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)


FS.declareColumn "RegWhyNotC" ''RegWhyNot

instance Grouping RegWhyNot

instance Flat.Flat RegWhyNot

derivingUnbox
  "RegWhyNot"
  [t|RegWhyNot -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor RegWhyNot = UVec.Vector

data VoteHow
  = VH_InPerson
  | VH_ByMail
  | VH_Other
  deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)

FS.declareColumn "VoteHowC" ''VoteHow

instance Grouping VoteHow

instance Flat.Flat VoteHow

instance FCSV.ShowCSV VoteHow

derivingUnbox
  "VoteHow"
  [t|VoteHow -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor VoteHow = UVec.Vector

data VoteWhen
  = VW_ElectionDay
  | VW_BeforeElectionDay
  | VW_Other
  deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)


FS.declareColumn "VoteWhenC" ''VoteWhen

instance Grouping VoteWhen

instance Flat.Flat VoteWhen

derivingUnbox
  "VoteWhen"
  [t|VoteWhen -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor VoteWhen = UVec.Vector

data VotedYN
  = VYN_DidNotVote
  | VYN_Voted
  | VYN_Refused
  | VYN_DontKnow
  | VYN_NoResponse
  | VYN_NotInUniverse
  deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)

FS.declareColumn "VotedYNC" ''VotedYN

instance Grouping VotedYN

instance Flat.Flat VotedYN

instance FCSV.ShowCSV VotedYN

derivingUnbox
  "VotedYN"
  [t|VotedYN -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor VotedYN = UVec.Vector

data RegisteredYN
  = RYN_NotRegistered
  | RYN_Registered
  | RYN_Other
  deriving stock (Enum, Bounded, Eq, Ord, Show, Generic)

FS.declareColumn "RegisteredYNC" ''RegisteredYN

instance Grouping RegisteredYN

instance Flat.Flat RegisteredYN

instance FCSV.ShowCSV RegisteredYN

derivingUnbox
  "RegisteredYN"
  [t|RegisteredYN -> Word8|]
  [|toEnum . fromEnum|]
  [|toEnum . fromEnum|]

type instance FI.VectorFor RegisteredYN = UVec.Vector

FS.declareColumn "DemPref" ''Double
FS.declareColumn "DemPct" ''Double
FS.declareColumn "RepPct" ''Double
FS.declareColumn "DemShare" ''Double
FS.declareColumn "RepShare" ''Double
FS.declareColumn "SharePVI" ''Double
FS.declareColumn "RawPVI" ''Double
FS.declareColumn "DemVPV" ''Double
FS.declareColumn "Incumbent" ''Bool
FS.declareColumn "Unopposed" ''Bool
