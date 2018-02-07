port module Lander exposing (main)

import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (class)


main : Html msg
main =
    div [ class "lander" ]
        [ h1 [] [ text "Meow Notes" ]
        , p [] [ text "A simple meow taking app... elm" ]
        ]
