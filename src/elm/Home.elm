port module ElmHome exposing (..)

import Http
import Date exposing (..)
import Note exposing (Note)
import Html exposing (Html, text, div, h1, img, li, ul, p)
import Html.Events exposing (onClick)
import Html.Attributes exposing (src, class)
import Bootstrap.ListGroup as Listgroup
import Json.Decode exposing (..)
import JSInterop exposing (..)


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
        model ! [ sendData (FetchNotes "/notes") ]



---- UPDATE ----


type Msg
    = OutSide IncomingData
    | LogErr String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "msg" msg
    in
        case msg of
            OutSide incomingData ->
                case incomingData of
                    UpdateAuth bool ->
                        ( { model | isAuthenticated = bool }, Cmd.none )

                    NotesLoaded notes ->
                        case notes of
                            Ok notes ->
                                ( { model | notes = notes }, Cmd.none )

                            Err fail ->
                                ( model, Cmd.none )

            LogErr err ->
                model ! [ sendData (LogError err) ]



-- Commands --


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receiveData OutSide LogErr
        ]



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
                        [ Listgroup.attrs <| []
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
