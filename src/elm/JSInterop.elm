port module JSInterop exposing (..)

import Note exposing (Note, noteDecoder, noteListDecoder)
import Json.Decode exposing (..)
import Json.Encode


sendData : OutgoingData -> Cmd msg
sendData info =
    case info of
        FetchNotes path ->
            outgoingData { tag = "FetchNotes", data = Json.Encode.string path }

        LogError err ->
            outgoingData { tag = "LogError", data = Json.Encode.string err }


receiveData : (IncomingData -> msg) -> (String -> msg) -> Sub msg
receiveData tagger onError =
    incomingData
        (\info ->
            case info.tag of
                "NotesLoaded" ->
                    tagger <| NotesLoaded <| decodeValue noteListDecoder info.data

                _ ->
                    onError <| "Unexpected info from outside: " ++ toString info
        )


type OutgoingData
    = FetchNotes String
    | LogError String


type IncomingData
    = NotesLoaded (Result String (List Note))
    | UpdateAuth Bool


type alias GenericData =
    { tag : String, data : Json.Encode.Value }


port outgoingData : GenericData -> Cmd msg


port incomingData : (GenericData -> msg) -> Sub msg
