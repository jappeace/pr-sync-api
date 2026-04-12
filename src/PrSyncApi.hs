module PrSyncApi
  ( ServerApi
  , SyncEndpoint
  , RecordsEndpoint
  , HealthEndpoint
  , CurrentRecord(..)
  , HistoryEntry(..)
  , SyncRequest(..)
  , SyncResponse(..)
  , FullState(..)
  )
where

import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.Time (UTCTime)
import GHC.Generics (Generic)
import Servant.API

data CurrentRecord = CurrentRecord
  { recordExercise :: Text
  , recordWeightKg :: Double
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (FromJSON, ToJSON)

data HistoryEntry = HistoryEntry
  { historyExercise   :: Text
  , historyWeightKg   :: Double
  , historyRecordedAt :: UTCTime
  , historyNotes      :: Maybe Text
  }
  deriving stock (Show, Eq, Ord, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | Client sends only new records since last sync.
data SyncRequest = SyncRequest
  { syncLastSyncTime   :: UTCTime
  , syncCurrentRecords :: [CurrentRecord]
  , syncHistory        :: [HistoryEntry]
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | Server returns delta history (new since lastSyncTime),
-- all current records, and the sync timestamp for next call.
data SyncResponse = SyncResponse
  { syncedCurrentRecords :: [CurrentRecord]
  , syncedHistory        :: [HistoryEntry]
  , syncTime             :: UTCTime
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | Full state dump for first boot / initial sync.
data FullState = FullState
  { fullCurrentRecords :: [CurrentRecord]
  , fullHistory        :: [HistoryEntry]
  , fullSyncTime       :: UTCTime
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (FromJSON, ToJSON)

type HealthEndpoint =
  "health" :> Get '[PlainText] Text

type SyncEndpoint =
  "api" :> "sync"
    :> Header' '[Required, Strict] "X-Api-Key" Text
    :> ReqBody '[JSON] SyncRequest
    :> Post '[JSON] SyncResponse

type RecordsEndpoint =
  "api" :> "records"
    :> Header' '[Required, Strict] "X-Api-Key" Text
    :> Get '[JSON] FullState

type ServerApi = HealthEndpoint :<|> SyncEndpoint :<|> RecordsEndpoint
