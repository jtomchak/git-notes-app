module Note exposing (..)

import Json.Decode exposing (..)


type alias CreateNote =
    { content : String
    , imageFile : Maybe Image
    }


type alias Note =
    { content : String
    , createdAt : Int
    , noteId : String
    }


noteDecoder : Decoder Note
noteDecoder =
    map3 Note
        (field "content" string)
        (field "createdAt" int)
        (field "noteId" string)


noteListDecoder : Decoder (List Note)
noteListDecoder =
    list noteDecoder


fileImageDecoder : Decoder Image
fileImageDecoder =
    map2 Image
        (field "content" string)
        (field "fileName" string)


type alias Image =
    { content : String
    , fileName : String
    }
