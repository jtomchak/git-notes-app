module Note exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)


type alias Image =
    { content : String
    , name : String
    , fileType : String
    , size : Int
    }


type alias CreateNote =
    { content : String
    , image : Maybe Image
    }


type alias Note =
    { content : String
    , createdAt : Int
    , noteId : String
    }


noteDecoder : Decoder Note
noteDecoder =
    map3 Note
        (field "content" Decode.string)
        (field "createdAt" Decode.int)
        (field "noteId" Decode.string)


noteListDecoder : Decoder (List Note)
noteListDecoder =
    Decode.list noteDecoder


fileImageDecoder : Decoder Image
fileImageDecoder =
    map4 Image
        (field "content" Decode.string)
        (field "name" Decode.string)
        (field "fileType" Decode.string)
        (field "size" Decode.int)


noteEncoder : CreateNote -> Encode.Value
noteEncoder newNote =
    let
        _ =
            Debug.log "newNote" newNote
    in
        case newNote.image of
            Nothing ->
                Encode.object [ ( "content", Encode.string newNote.content ) ]

            Just image ->
                Encode.object
                    [ ( "noteContent", Encode.string newNote.content )
                    , ( "image", imageEncoder image )
                    ]


imageEncoder : Image -> Encode.Value
imageEncoder image =
    Encode.object
        [ ( "content", Encode.string image.content )
        , ( "name", Encode.string image.name )
        , ( "type", Encode.string image.fileType )
        , ( "size", Encode.int image.size )
        ]
