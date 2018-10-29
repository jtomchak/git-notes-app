module Main exposing (..)

import Http
import Date exposing (..)
import UrlParser as Url exposing (parsePath, Parser, (</>), (<?>), s, int, stringParam, top, oneOf, map)
import Navigation exposing (Location, modifyUrl, newUrl)
import Note exposing (Note, Image, CreateNote)
import Html exposing (Html, Attribute, text, div, h1, img, li, ul, p, label, input)
import Html.Events exposing (onClick, onWithOptions, on)
import Html.Attributes exposing (src, class, for, type_, id, title, attribute)
import Bootstrap.ListGroup as Listgroup
import Bootstrap.Form as Form
import Bootstrap.Button as Button
import Json.Decode exposing (..)
import Json.Encode exposing (string)
import JSInterop exposing (..)


---- MODEL ----


type alias LoginData =
    { user : UserData, route : LoggedInRoute }


type alias UserData =
    { notes : List Note
    , createNote : CreateNote
    }


type Authenticated
    = Login ( UserData, LoggedInRoute )
    | Anonymous AnonymousRoute


type alias Model =
    { authenticated : Authenticated
    , route : Route
    }


type alias Flags =
    { location : Location
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        model =
            { authenticated = Anonymous LandingPage
            , route = extractRoute location
            }
    in
        model ! [ sendData (FetchNotes "/notes") ]


type AnonymousRoute
    = LoginPage
    | SigninPage
    | LandingPage


type LoggedInRoute
    = NotesPage
    | NewNotePage
    | NotePage
    | NotFoundPage


type Route
    = Home
    | NewNote
    | Note String
    | NotFound



-- parser instructions


extractRoute : Location -> Route
extractRoute location =
    case (Url.parsePath matchRoute location) of
        Just route ->
            route

        Nothing ->
            NotFound



-- like writing a decoder
-- path portion of a url
-- prodecural set of rules to consume a section of the path
-- run until something is produced
-- we are building the parser here
-- </> both sides of the slash have to succeed
-- get it down to a 1 param function
-- map takes a function from one place and upgrades it to another world


matchRoute : Parser (Route -> a) a
matchRoute =
    Url.oneOf
        [ Url.map Home Url.top
        , Url.map NewNote (s "notes" </> s "new")
        , Url.map Note (s "notes" </> Url.string)
        ]


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
    | SelectImageFile String
    | UpdateNoteContent String
    | PostNote
    | UrlChange Location



-- case isAuth of ok true, ok false, error
-- default user data record


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
                            Ok False ->
                                ( { model | authenticated = Anonymous LandingPage }, Cmd.none )

                            Ok True ->
                                ( { model | authenticated = Login ( { notes = [], createNote = { content = "", image = Nothing } }, NotesPage ) }, Cmd.none )

                            Err fail ->
                                ( model, Cmd.none )

                    NotesLoaded notes ->
                        case notes of
                            Ok notes ->
                                case model.authenticated of
                                    Anonymous _ ->
                                        ( model, Cmd.none )

                                    Login ( userData, _ ) ->
                                        ( { model | authenticated = Login ( { userData | notes = notes }, NotesPage ) }, Cmd.none )

                            Err fail ->
                                ( model, Cmd.none )

                    NotePayload note ->
                        case note of
                            Ok note ->
                                case model.authenticated of
                                    Anonymous _ ->
                                        ( model, Cmd.none )

                                    Login ( userData, _ ) ->
                                        ( { model | authenticated = Login ( { userData | createNote = { content = note.content, image = Nothing } }, NotePage ) }, Cmd.none )

                            Err fail ->
                                ( model, Cmd.none )

                    FileReadImage file ->
                        case file of
                            Ok newImageFile ->
                                case model.authenticated of
                                    Anonymous _ ->
                                        ( model, Cmd.none )

                                    Login ( userData, _ ) ->
                                        let
                                            newCreateNote =
                                                updateCreateNoteImage newImageFile userData.createNote
                                        in
                                            ( { model | authenticated = Login ( { userData | createNote = newCreateNote }, NewNotePage ) }, Cmd.none )

                            Err fail ->
                                ( model, Cmd.none )

            JSRedirectTo route ->
                model ! [ newUrl route ]

            LogErr err ->
                model ! [ sendData (LogError err) ]

            SelectImageFile id ->
                model ! [ sendData (FileSelected id) ]

            UpdateNoteContent content ->
                case model.authenticated of
                    Anonymous _ ->
                        ( model, Cmd.none )

                    Login ( userData, _ ) ->
                        let
                            updateNewNote =
                                updateCreateNoteContent content userData.createNote
                        in
                            ( { model | authenticated = Login ( { userData | createNote = updateNewNote }, NewNotePage ) }, Cmd.none )

            PostNote ->
                case model.authenticated of
                    Anonymous _ ->
                        ( model, Cmd.none )

                    Login ( userData, _ ) ->
                        model ! [ sendData (PostCreateNote userData.createNote) ]

            UrlChange location ->
                case (extractRoute location) of
                    Note noteId ->
                        ( { model | route = extractRoute location }, sendData (FetchNoteById noteId) )

                    _ ->
                        ( { model | route = extractRoute location }, Cmd.none )


updateCreateNoteImage : Image -> CreateNote -> CreateNote
updateCreateNoteImage newImage newNote =
    { newNote | image = Just newImage }


updateCreateNoteContent : String -> CreateNote -> CreateNote
updateCreateNoteContent content note =
    { note | content = content }



-- Commands --


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receiveData OutSide LogErr
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        _ =
            Debug.log "view" model
    in
        case model.route of
            -- case is model authenticated forcing pattern match
            Home ->
                case model.authenticated of
                    Login ( userData, _ ) ->
                        div []
                            [ h1 [] [ text "Our Elm App is working!" ]
                            , Button.button [ Button.primary, Button.attrs [ onClick (JSRedirectTo "notes/new") ] ] [ text "New Note" ]
                            , Listgroup.custom (renderNotes userData.notes)
                            ]

                    Anonymous _ ->
                        renderLanding "Welcome"

            NewNote ->
                case model.authenticated of
                    Login ( userData, _ ) ->
                        div []
                            [ h1 [] [ text "Here is where Elm note is going!" ]
                            , Form.form []
                                [ Form.group []
                                    [ label [ for "content" ] []
                                    , Html.node "markdown-text"
                                        [ Html.Attributes.property "markdownValue" <| Json.Encode.string userData.createNote.content
                                        , Html.Events.on "markdownTextChange" <| Json.Decode.map UpdateNoteContent <| Json.Decode.at [ "target", "markdownValue" ] <| Json.Decode.string
                                        ]
                                        []
                                    ]
                                , Form.group []
                                    [ Form.label [ for "file" ] [ text "Attachment" ]
                                    , input [ type_ "file", id "imageFileInput", on "change" (Json.Decode.succeed (SelectImageFile "imageFileInput")) ] []
                                    ]
                                , Button.button [ Button.primary, Button.attrs [ onWithOptions "click" { stopPropagation = True, preventDefault = True } (Json.Decode.succeed (PostNote)) ] ] [ text "Create" ]
                                ]
                            , viewImagePreview userData.createNote.image
                            ]

                    Anonymous _ ->
                        renderLanding "Login to create a new note!"

            Note noteId ->
                case model.authenticated of
                    Login ( userData, _ ) ->
                        div []
                            [ h1 [] [ text "Here is where Elm note is going!" ]
                            , Form.form []
                                [ Form.group []
                                    [ label [ for "content" ] []
                                    , Html.node "markdown-text"
                                        [ Html.Attributes.property "markdownValue" <| Json.Encode.string userData.createNote.content
                                        , Html.Events.on "markdownTextChange" <| Json.Decode.map UpdateNoteContent <| Json.Decode.at [ "target", "markdownValue" ] <| Json.Decode.string
                                        ]
                                        []
                                    ]
                                , Form.group []
                                    [ Form.label [ for "file" ] [ text "Attachment" ]
                                    , input [ type_ "file", id "imageFileInput", on "change" (Json.Decode.succeed (SelectImageFile "imageFileInput")) ] []
                                    ]
                                , Button.button [ Button.primary, Button.attrs [ onWithOptions "click" { stopPropagation = True, preventDefault = True } (Json.Decode.succeed (PostNote)) ] ] [ text "Create" ]
                                ]
                            , viewImagePreview userData.createNote.image
                            ]

                    Anonymous _ ->
                        renderLanding "Login to create a new note!"

            NotFound ->
                div []
                    [ h1 [] [ text "Nothing here meow" ] ]



-- annoynous function w/o name
-- functions with name in a let block
-- copy body outside of the function
-- WOW really clean and simple
-- how many things does this thing need to know?
-- UNIX predate composition?
-- functur


renderNote : Note -> Listgroup.CustomItem Msg
renderNote note =
    Listgroup.button
        [ Listgroup.attrs <| [ onClick <| JSRedirectTo ("notes/" ++ note.noteId) ]
        ]
        [ text (noteTitle note.content) ]



-- ({ content = "Create a New Note", createdAt = 0, noteId = "new" } :: notes)
-- pullout and make separate note


renderNotes : List Note -> List (Listgroup.CustomItem Msg)
renderNotes notes =
    List.map renderNote notes


renderLanding : String -> Html Msg
renderLanding input =
    div [ class "lander" ]
        [ h1 [] [ text "Meow Notes" ]
        , p [] [ text "A simple meow taking app... elm" ]
        , p [] [ text input ]
        ]


mdTextPlaceholder : String -> Attribute msg
mdTextPlaceholder txt =
    attribute "placeholder" txt


squareLength : Int -> Attribute msg
squareLength n =
    attribute "l" (toString n)


squareColor : String -> Attribute msg
squareColor c =
    attribute "c" c


noteTitle : String -> String
noteTitle content =
    content |> String.lines |> List.head |> Maybe.withDefault "Note Title"


viewImagePreview : Maybe Image -> Html Msg
viewImagePreview image =
    case image of
        Just i ->
            img [ src i.content, title i.name ] []

        Nothing ->
            text ""



---- PROGRAM ----


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
