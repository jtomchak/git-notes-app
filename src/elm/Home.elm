port module ElmHome exposing (..)

import Http
import Date exposing (..)
import Html exposing (Html, text, div, h1, img, li, ul, p)
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
    , isAuthenticated : Bool
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { notes = []
            , isAuthenticated = False
            }
    in
        model ! [ fetchNotes "/notes" ]



---- UPDATE ----


type Msg
    = NotesLoaded (Result String (List Note))
    | SetRoute String
    | UpdateAuth Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "msg" msg
    in
        case msg of
            NotesLoaded (Ok notes) ->
                ( { model | notes = notes }, Cmd.none )

            NotesLoaded (Err fail) ->
                ( model, Cmd.none )

            SetRoute url ->
                ( model, routeTo url )

            UpdateAuth bool ->
                ( { model | isAuthenticated = bool }, Cmd.none )



-- Commands --
-- Ports --
-- IN --


port notesLoaded : (Value -> msg) -> Sub msg


port isAuthenticated : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ notesLoaded ((decodeValue noteListDecoder >> NotesLoaded))
        , isAuthenticated UpdateAuth
        ]


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


view : Model -> Html Msg
view model =
    if model.isAuthenticated then
        div []
            [ h1 [] [ text "Our Elm App is working!" ]
            , renderNotes model.notes
            ]
    else
        div [ class "lander" ]
            [ h1 [] [ text "Meow Notes" ]
            , p [] [ text "A simple meow taking app... elm" ]
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
                ({ content = "Create a New Note", createdAt = 0, noteId = "new" } :: notes)
    in
        Listgroup.custom noteItems


noteTitle : String -> String
noteTitle content =
    Maybe.withDefault "Note Title" (content |> String.lines |> List.head)



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
