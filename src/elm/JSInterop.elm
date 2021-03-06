port module JSInterop exposing (..)

import Note exposing (Note, noteDecoder, noteListDecoder, Image, fileImageDecoder, CreateNote, noteEncoder)
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

        FileSelected id ->
            outgoingData { tag = "File_SELECTED", data = Json.Encode.string id }

        PostCreateNote newNote ->
            outgoingData { tag = "CREATE_NEW_NOTE", data = noteEncoder newNote }

        FetchNoteById noteId ->
            outgoingData { tag = "FETCH_NOTE_BY_ID", data = Json.Encode.string ("/notes/" ++ noteId) }


receiveData : (IncomingData -> msg) -> (String -> msg) -> Sub msg
receiveData tagger onError =
    incomingData
        (\info ->
            case info.tag of
                "NOTES_LOADED" ->
                    tagger <| NotesLoaded <| decodeValue noteListDecoder info.data

                "IS_AUTHENTICATED" ->
                    tagger <| UpdateAuth <| decodeValue Json.Decode.bool info.data

                "FILE_CONTENT_READ" ->
                    tagger <| FileReadImage <| decodeValue fileImageDecoder info.data

                "NOTE_RECIEVED_SUCCESS" ->
                    tagger <| NotePayload <| decodeValue noteDecoder info.data

                _ ->
                    onError <| "Unexpected info from outside: " ++ toString info
        )


type OutgoingData
    = FetchNotes String
    | RedirectTo String
    | LogError String
    | FileSelected String
    | PostCreateNote CreateNote
    | FetchNoteById String


type IncomingData
    = NotesLoaded (Result String (List Note))
    | UpdateAuth (Result String Bool)
    | FileReadImage (Result String Image)
    | NotePayload (Result String Note)


type alias GenericData =
    { tag : String, data : Json.Encode.Value }


port outgoingData : GenericData -> Cmd msg


port incomingData : (GenericData -> msg) -> Sub msg
