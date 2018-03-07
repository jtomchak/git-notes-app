port module ElmHome exposing (..)

import Http
import Date exposing (..)
import Html exposing (Html, text, div, h1, img, li, ul)
import Html.Events exposing (onClick)
import Html.Attributes exposing (src, class)
import Bootstrap.ListGroup as Listgroup
import Json.Decode exposing (..)


---- MODEL ----


type alias Note =
    { content : String
    , createdAt : Int
    , noteId : String
    }


type alias Model =
    { notes : List Note
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { notes = []
            }
    in
        model ! [ fetchNotes "/notes" ]



---- UPDATE ----


type Msg
    = NotesLoaded (Result String (List Note))
    | SetRoute String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NotesLoaded (Ok notes) ->
            ( { model | notes = notes }, Cmd.none )

        NotesLoaded (Err fail) ->
            ( model, Cmd.none )

        SetRoute url ->
            ( model, routeTo url )



-- Commands --
-- Ports --
-- IN --


port notesLoaded : (Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    notesLoaded ((decodeValue noteListDecoder >> NotesLoaded))


noteDecoder : Decoder Note
noteDecoder =
    map3 Note
        (field "content" string)
        (field "createdAt" int)
        (field "noteId" string)


noteListDecoder : Decoder (List Note)
noteListDecoder =
    list noteDecoder



-- OUT --


port fetchNotes : String -> Cmd msg


port routeTo : String -> Cmd msg



---- VIEW ----
-- (map (\l -> li [] [ text l ]) lst)


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Our Elm App is working!" ]
        , renderNotes model.notes
        ]


renderNotes : List Note -> Html Msg
renderNotes notes =
    let
        noteItems =
            List.map
                (\n ->
                    Listgroup.button
                        [ Listgroup.attrs <| [ onClick (SetRoute ("/notes/" ++ n.noteId)) ]
                        ]
                        [ text (noteTitle n.content) ]
                )
                (List.append [ { content = "Create a New Note", createdAt = 0, noteId = "new" } ] notes)
    in
        Listgroup.custom noteItems


noteTitle : String -> String
noteTitle content =
    Maybe.withDefault "Note Title" (List.head (String.lines content))



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
