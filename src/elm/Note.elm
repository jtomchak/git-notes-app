module Note exposing (..)

import Json.Decode exposing (..)


noteDecoder : Decoder Note
noteDecoder =
    map3 Note
        (field "content" string)
        (field "createdAt" int)
        (field "noteId" string)


noteListDecoder : Decoder (List Note)
noteListDecoder =
    list noteDecoder


type alias Note =
    { content : String
    , createdAt : Int
    , noteId : String
    }


authDecoder : Decoder Bool
authDecoder =
    (Json.Decode.bool)



-- Decode.map (\auth -> { isAuth = auth })
--     (Decode.at [ "auth" ] Decode.bool)