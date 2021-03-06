module Basic exposing (main)

import Browser
import DnDList
import Html
import Html.Attributes



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- DATA


data : List String
data =
    [ "Apples", "Bananas", "Cherries", "Dates" ]



-- SYSTEM


system : DnDList.System Msg
system =
    DnDList.create DnDMsg



-- MODEL


type alias Model =
    { draggable : DnDList.Draggable
    , items : List String
    }


initialModel : Model
initialModel =
    { draggable = system.draggable
    , items = data
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    system.subscriptions model.draggable



-- UPDATE


type Msg
    = NoOp
    | DnDMsg DnDList.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DnDMsg message ->
            let
                ( draggable, items ) =
                    DnDList.update message model.draggable model.items
            in
            ( { model | draggable = draggable, items = items }
            , system.commands model.draggable
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    let
        maybeDragIndex : Maybe Int
        maybeDragIndex =
            DnDList.getDragIndex model.draggable
    in
    Html.section
        [ Html.Attributes.style "margin" "6em 0"
        , Html.Attributes.style "text-align" "center"
        ]
        [ model.items
            |> List.indexedMap (itemView maybeDragIndex)
            |> Html.div []
        , draggedItemView model.draggable model.items
        ]


itemView : Maybe Int -> Int -> String -> Html.Html Msg
itemView maybeDragIndex index item =
    case maybeDragIndex of
        Just dragIndex ->
            if dragIndex /= index then
                Html.p
                    (system.dropEvents index)
                    [ Html.text item ]

            else
                Html.p [] [ Html.text "[---------]" ]

        Nothing ->
            let
                itemId : String
                itemId =
                    "id-" ++ String.replace " " "-" item
            in
            Html.p
                (Html.Attributes.id itemId :: system.dragEvents index itemId)
                [ Html.text item ]


draggedItemView : DnDList.Draggable -> List String -> Html.Html Msg
draggedItemView draggable items =
    let
        maybeItem : Maybe String
        maybeItem =
            DnDList.getDragIndex draggable
                |> Maybe.andThen (\index -> items |> List.drop index |> List.head)
    in
    case maybeItem of
        Just item ->
            Html.div
                (system.draggedStyles draggable DnDList.Free)
                [ Html.text item ]

        Nothing ->
            Html.text ""
