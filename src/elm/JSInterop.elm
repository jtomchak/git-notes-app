port module JSInterop exposing (..)

import Note exposing (Note, noteDecoder, noteListDecoder)
import Json.Decode exposing (Decoder, decodeValue, decodeString, bool)
import Json.Encode


sendData : OutgoingData -> Cmd msg
sendData info =
    case info of
        FetchNotes path ->
            outgoingData { tag = "FETCH_NOTES", data = Json.Encode.string path }

        RedirectTo route ->
            outgoingData { tag = "REDIRECT_TO", data = Json.Encode.string route }

        LogError err ->
            outgoingData { tag = "ERROR_LOG_REQUESTED", data = Json.Encode.string err }


receiveData : (IncomingData -> msg) -> (String -> msg) -> Sub msg
receiveData tagger onError =
    incomingData
        (\info ->
            case info.tag of
                "NotesLoaded" ->
                    tagger <| NotesLoaded <| decodeValue noteListDecoder info.data

                "IsAuthenticated" ->
                    tagger <| UpdateAuth <| decodeValue Json.Decode.bool info.data

                _ ->
                    onError <| "Unexpected info from outside: " ++ toString info
        )


type OutgoingData
    = FetchNotes String
    | RedirectTo String
    | LogError String


type IncomingData
    = NotesLoaded (Result String (List Note))
    | UpdateAuth (Result String Bool)


type alias GenericData =
    { tag : String, data : Json.Encode.Value }


port outgoingData : GenericData -> Cmd msg


port incomingData : (GenericData -> msg) -> Sub msg
