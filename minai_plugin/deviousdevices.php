<?php

require_once("util.php");

$target = GetTargetActor();
$canVibrate = CanVibrate($target);

  
$GLOBALS["F_NAMES"]["ExtCmdShock"]="Shock";
$GLOBALS["F_NAMES"]["ExtCmdForceOrgasm"]="ForceOrgasm";
$GLOBALS["F_NAMES"]["ExtCmdTurnOffVibrator"]="TurnOffVibrator";

$GLOBALS["F_TRANSLATIONS"]["ExtCmdShock"]="Shock the target in order to punish them or reduce their arousal";
$GLOBALS["F_TRANSLATIONS"]["ExtCmdForceOrgasm"]="Make the target immediately have an orgasm";
$GLOBALS["F_TRANSLATIONS"]["ExtCmdTurnOffVibrator"]="Turn off the targets vibrator";



$GLOBALS["FUNCTIONS"][] = [
        "name" => $GLOBALS["F_NAMES"]["ExtCmdShock"],
        "description" => $GLOBALS["F_TRANSLATIONS"]["ExtCmdShock"],
        "parameters" => [
            "type" => "object",
            "properties" => [
                "target" => [
                    "type" => "string",
                    "description" => "Target NPC, Actor, or being",
                    "enum" => $GLOBALS["nearby"]
                ]
            ],
            "required" => ["target"],
        ],
    ];



$GLOBALS["FUNCTIONS"][] = [
        "name" => $GLOBALS["F_NAMES"]["ExtCmdForceOrgasm"],
        "description" => $GLOBALS["F_TRANSLATIONS"]["ExtCmdForceOrgasm"],
        "parameters" => [
            "type" => "object",
            "properties" => [
                "target" => [
                    "type" => "string",
                    "description" => "Target NPC, Actor, or being",
                    "enum" => $GLOBALS["nearby"]
                ]
            ],
            "required" => ["target"],
        ],
    ];

$GLOBALS["FUNCTIONS"][] = [
        "name" => $GLOBALS["F_NAMES"]["ExtCmdTurnOffVibrator"],
        "description" => $GLOBALS["F_TRANSLATIONS"]["ExtCmdTurnOffVibrator"],
        "parameters" => [
            "type" => "object",
            "properties" => [
                "target" => [
                    "type" => "string",
                    "description" => "Target NPC, Actor, or being",
                    "enum" => $GLOBALS["nearby"]
                ]
            ],
            "required" => ["target"],
        ],
    ];






if ($canVibrate) {
    RegisterAction("ExtCmdShock");
    RegisterAction("ExtCmdForceOrgasm");
    RegisterAction("ExtCmdTurnOffVibrator");
 }


$GLOBALS["PROMPTS"]["afterfunc"]["cue"]["ExtCmdShock"]="{$GLOBALS["HERIKA_NAME"]} comments on remotely shocking {$target}. {$GLOBALS["TEMPLATE_DIALOG"]}";
$GLOBALS["PROMPTS"]["afterfunc"]["cue"]["ExtCmdForceOrgasm"]="{$GLOBALS["HERIKA_NAME"]} comments on remotely forcing {$target} to have an orgasm. {$GLOBALS["TEMPLATE_DIALOG"]}";
$GLOBALS["PROMPTS"]["afterfunc"]["cue"]["ExtCmdTurnOffVibrator"]="{$GLOBALS["HERIKA_NAME"]} comments on turning off {$target}'s vibrator. {$GLOBALS["TEMPLATE_DIALOG"]}";



$GLOBALS["FUNCRET"]["ExtCmdShock"]=$GLOBALS["GenericFuncRet"];
$GLOBALS["FUNCRET"]["ExtCmdForceOrgasm"]=$GLOBALS["GenericFuncRet"];
$GLOBALS["FUNCRET"]["ExtCmdTurnOffVibrator"]=$GLOBALS["GenericFuncRet"];




$vibSettings = Array ("Very Weak", "Weak", "Medium", "Strong", "Very Strong");

// Temporary ugly hack until I can figure out why parameters aren't working. Mantella feature parity
foreach ($vibSettings as $strength) {
  $keyword = "ExtCmdTeaseWithVibrator" . str_replace(' ', '', $strength);
  $name = "TeaseWithVibrator" . str_replace(' ', '', $strength);
  
  $GLOBALS["F_NAMES"][$keyword]=$name;
  $GLOBALS["F_TRANSLATIONS"][$keyword]="Remotely stimulate the target with a vibrator ($strength intensity) without letting them climax";

  $GLOBALS["FUNCTIONS"][] = [
			     "name" => $GLOBALS["F_NAMES"]["$keyword"],
			     "description" => $GLOBALS["F_TRANSLATIONS"]["$keyword"],
			     "parameters" => [
					      "type" => "object",
					      "properties" => [
                              "target" => [
                                  "type" => "string",
                                  "description" => "Target NPC, Actor, or being",
                                  "enum" => $GLOBALS["nearby"]
                              ]
                          ],
					      "required" => ["target"],
					      ],
			     ];
  if ($canVibrate) {
      $GLOBALS["ENABLED_FUNCTIONS"][]=$keyword;
  }
  $GLOBALS["PROMPTS"]["afterfunc"]["cue"]["$keyword"]="{$GLOBALS["HERIKA_NAME"]} comments on remotely teasing {$target} with a $strength vibration. {$GLOBALS["TEMPLATE_DIALOG"]}";
}

foreach ($vibSettings as $strength) {
  $keyword = "ExtCmdStimulateWithVibrator" . str_replace(' ', '', $strength);
  $name = "StimulateWithVibrator" . str_replace(' ', '', $strength);
  
  $GLOBALS["F_NAMES"][$keyword]=$name;
  $GLOBALS["F_TRANSLATIONS"][$keyword]="Remotely stimulate the target with a vibrator ($strength intensity)";

  $GLOBALS["FUNCTIONS"][] = [
      "name" => $GLOBALS["F_NAMES"]["$keyword"],
      "description" => $GLOBALS["F_TRANSLATIONS"]["$keyword"],
      "parameters" => [
          "type" => "object",
          "properties" => [
              "target" => [
                  "type" => "string",
                  "description" => "Target NPC, Actor, or being",
                  "enum" => $GLOBALS["nearby"]
              ],
              "required" => ["target"],
          ],
      ]
  ];
  if ($canVibrate) {
      $GLOBALS["ENABLED_FUNCTIONS"][]=$keyword;
  }
  $GLOBALS["PROMPTS"]["afterfunc"]["cue"]["$keyword"]="{$GLOBALS["HERIKA_NAME"]} comments on remotely stimulating {$target} with a $strength vibration. {$GLOBALS["TEMPLATE_DIALOG"]}";
}





$GLOBALS["F_NAMES"]["ExtCmdEquipCollar"]="EquipCollar";
$GLOBALS["F_TRANSLATIONS"]["ExtCmdEquipCollar"]="Lock a collar on the target";
$GLOBALS["FUNCTIONS"][] = [
    "name" => $GLOBALS["F_NAMES"]["ExtCmdEquipCollar"],
    "description" => $GLOBALS["F_TRANSLATIONS"]["ExtCmdEquipCollar"],
    "parameters" => [
        "type" => "object",
        "properties" => [
            "target" => [
                "type" => "string",
                "description" => "Target NPC, Actor, or being",
                "enum" => $GLOBALS["nearby"]
            ]
        ],
        "required" => ["target"],
    ],
];

$GLOBALS["F_NAMES"]["ExtCmdUnequipCollar"]="UnequipCollar";
$GLOBALS["F_TRANSLATIONS"]["ExtCmdUnequipCollar"]="Remove a collar from the target";
$GLOBALS["FUNCTIONS"][] = [
    "name" => $GLOBALS["F_NAMES"]["ExtCmdUnequipCollar"],
    "description" => $GLOBALS["F_TRANSLATIONS"]["ExtCmdUnequipCollar"],
    "parameters" => [
        "type" => "object",
        "properties" => [
            "target" => [
                "type" => "string",
                "description" => "Target NPC, Actor, or being",
                "enum" => $GLOBALS["nearby"]
            ]
        ],
        "required" => ["target"],
    ],
];

if (IsConfigEnabled("allowDeviceLock")) {
    RegisterAction("ExtCmdEquipCollar");
}

if (IsConfigEnabled("allowDeviceUnlock")) {
    RegisterAction("ExtCmdUnequipCollar");
}

?>
