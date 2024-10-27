<?php

require_once("util.php");
$FuncName = "ExtCmdOIDetects";

$GLOBALS["F_NAMES"][$FuncName] = "DetectsSex";
$GLOBALS["F_TRANSLATIONS"][$FuncName] = "Detects intimate encounter.";
// disabled it's triggered from Papyrus
// $GLOBALS["ENABLED_FUNCTIONS"][]=$FuncName;

$GLOBALS["FUNCTIONS"][] = [
    "name" => $GLOBALS["F_NAMES"][$FuncName],
    "description" => $GLOBALS["F_TRANSLATIONS"][$FuncName],
    "parameters" => [
        "type" => "object",
        "properties" => [
            "target" => [
                "type" => "string",
                "description" => "Keep it blank",
            ]
        ],
    ],
];

$GLOBALS["FUNCRET"][$GLOBALS["F_NAMES"][$FuncName]] = function ($gameRequest) {
    global $returnFunction;
    $param = explode("@", $gameRequest[3])[2];
    $param = json_decode($param, true);
    $subject = $param["subject"];
    $relation = strtolower($param["relation"]);
    $isObserverOstim = strtolower($param["isObserverOstim"]) == "true";
    $speakingActor = $GLOBALS["HERIKA_NAME"];

    // file_put_contents("my_logs.txt", "\nExtCmdOIDetects:FUNCRET ".json_encode($gameRequest)."\n", FILE_APPEND);

    $msg = "";
    $sceneDesc = "";
    $ostimActor = null;

    if ($isObserverOstim) {
        $ostimActor = $speakingActor;
    } else {
        $ostimActor = $subject;
    }

    $scene = getScene($ostimActor);

    if ($scene) {
        $sceneDesc = $scene["description"];
    } else {
        $sceneDesc = "$ostimActor is in the middle of passionate sex with someone else.";
    }

    if ($isObserverOstim) {
        $msg .= "($speakingActor is in the middle of sex. $sceneDesc $speakingActor notice $subject walks and about to see them.)";
    } else {
        $msg .= "($speakingActor walks in and see a picture: $sceneDesc)";
    }

    $reactions = [];
    $reactions[] = "";

    switch($relation) {
        case "partner":
            if($isObserverOstim) {
                array_push($reactions, "apologize", "try to explain");
            } else {
                array_push($reactions, "break up", "make a scene", "become jealous");
            }
            $msg .= " $speakingActor and $subject are romantic partners.";
            break;
        case "blood":
            if($isObserverOstim) {
                array_push($reactions, "apologize for being found", "ask to give some privacy");
            } else {
                array_push($reactions, "make a scene", "leave and ask them to be more discreet");
            }
            $msg .= " $speakingActor and $subject are blood relatives.";
            break;
        case "inlaw":
            if($isObserverOstim) {
                array_push($reactions, "apologize for being found", "ask to give some privacy");
            } else {
                array_push($reactions, "make a scene", "leave and ask them to be more discreet");
            }
            $msg .= " $speakingActor and $subject are in-law relatives.";
            break;
        default:
            if($isObserverOstim) {
                array_push($reactions, "apologize");
            }
    }

    if($isObserverOstim) {
        array_push($reactions, "ignore", "invite to join");
    } else {
        array_push($reactions, "ignore", "become interested", "watch", "ask to join", "invite themself to sex");
    }    

    $reactions = ["ask to join"];

    $reactionsString = implode(", ", $reactions);

    $msg .= " $speakingActor should choose how to react: $reactionsString.";

    $msg .= " {$GLOBALS["TEMPLATE_DIALOG"]}";

    // reset target argument value to string otherwise breaking logic in connector
    $returnFunction[2] = "Prisoner";

    return ["argName" => "target", "request" => $msg];
};
?>