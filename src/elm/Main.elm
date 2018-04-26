module Main exposing (..)

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
    , route : Route
    }


type alias Flags =
    { route : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { notes = []
            , isAuthenticated = False
            , route = urlToRoute flags.route
            }
    in
        model ! [ sendData (FetchNotes "/notes") ]


type Route
    = Home
    | NewNote
    | NotFound


urlToRoute : String -> Route
urlToRoute url =
    case url of
        "/" ->
            Home

        "/notes/new" ->
            NewNote

        _ ->
            NotFound



---- UPDATE ----


type Msg
    = OutSide IncomingData
    | JSRedirectTo String
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
                    UpdateAuth isAuth ->
                        case isAuth of
                            Ok isAuth ->
                                ( { model | isAuthenticated = isAuth }, Cmd.none )

                            Err fail ->
                                ( model, Cmd.none )

                    NotesLoaded notes ->
                        case notes of
                            Ok notes ->
                                ( { model | notes = notes }, Cmd.none )

                            Err fail ->
                                ( model, Cmd.none )

            JSRedirectTo route ->
                model ! [ sendData <| RedirectTo route ]

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
    case model.route of
        Home ->
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

        NewNote ->
            div []
                [ h1 [] [ text "Here is where Elm note is going!" ] ]

        NotFound ->
            div []
                [ h1 [] [ text "Nothing here meow" ] ]


renderNotes : List Note -> Html Msg
renderNotes notes =
    let
        noteItems =
            List.map
                (\n ->
                    Listgroup.button
                        [ Listgroup.attrs <| [ onClick <| JSRedirectTo ("notes/" ++ n.noteId) ]
                        ]
                        [ text (noteTitle n.content) ]
                )
                ({ content = "Create a New Note", createdAt = 0, noteId = "new" } :: notes)
    in
        Listgroup.custom noteItems


noteTitle : String -> String
noteTitle content =
    content |> String.lines |> List.head |> Maybe.withDefault "Note Title"



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
