port module ElmHome exposing (..)

import Http
import Date exposing (..)
import Html exposing (Html, text, div, h1, img, li, ul)
import Html.Attributes exposing (src, class)
import Bootstrap.ListGroup as Listgroup
import Json.Decode exposing (..)


---- MODEL ----


type alias Notes =
    List Note


type alias Note =
    { content : String
    , createdAt : Int
    , noteId : String
    }


type alias Model =
    { notes : Notes
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
    = NotesLoaded (Result String Notes)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NotesLoaded (Ok notes) ->
            ( { model | notes = notes }, Cmd.none )

        NotesLoaded (Err fail) ->
            ( model, Cmd.none )



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



---- VIEW ----
-- (map (\l -> li [] [ text l ]) lst)


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Your Elm App is working!" ]
        , renderNotes model.notes
        ]


renderNotes : Notes -> Html Msg
renderNotes notes =
    let
        noteItems =
            List.map (\n -> Listgroup.li [] [ text n.content ]) notes
    in
        Listgroup.ul noteItems



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
