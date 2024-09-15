scriptname minai_DeviousStuff extends Quest

zadLibs libs
SLAppPCSexQuestScript slapp
_DFtools dftools
_DFDealUberController dfDealController

bool bHasDeviousFollowers = False
bool bHasDD = False
bool bHasSTA = False
bool bHasSLHH = False
bool bHasSLApp = False

Keyword SLHHScriptEventKeyword
GlobalVariable Debt
GlobalVariable EnslaveDebt
GlobalVariable ContractRemaining
string targetRule = ""

minai_MainQuestController main
minai_Arousal arousal
minai_Sex sex
minai_AIFF aiff

actor playerRef

function Maintenance(minai_MainQuestController _main)
  Debug.Trace("[minai] Initializing Devious Module")
  playerRef = game.GetPlayer()
  main = _main
  
  arousal = (Self as Quest) as minai_Arousal
  sex = (Self as Quest) as minai_Sex
  aiff = (Self as Quest) as minai_AIFF
  
  RegisterForModEvent("DeviceActorOrgasm", "OnOrgasm")
  RegisterForModEvent("DeviceActorEdged", "OnEdged")
  RegisterForModEvent("DeviceVibrateEffectSta", "OnVibrateStart")

  RegisterForModEvent("DDI_DeviceEquipped", "OnDeviceEquipped")
  RegisterForModEvent("DDI_DeviceRemoved", "OnDeviceRemoved")
  RegisterForModEvent("DDI_KeyBreak", "OnKeyBreak")
  RegisterForModEvent("DDI_JamLock", "OnJamLock")
  RegisterForModEvent("DDI_DeviceEscapeAttempt", "OnDeviceEscapeAttempt")
  
  
  libs = Game.GetFormFromFile(0x00F624, "Devious Devices - Integration.esm") as zadlibs
    if libs
    bHasDD = True
    Debug.Trace("[minai] Found Devious Devices")    
  EndIf
  
  if Game.GetModByName("DeviousFollowers.esp") != 255
    Debug.Trace("[minai] Found Devious Followers")
    bHasDeviousFollowers = True
    Debt = Game.GetFormFromFile(0xC54F, "DeviousFollowers.esp") as GlobalVariable
    ContractRemaining = Game.GetFormFromFile(0x218C7C, "DeviousFollowers.esp") as GlobalVariable
    dftools = Game.GetFormFromFile(0x01210D, "DeviousFollowers.esp") as _DFtools
    dfDealController = Game.GetFormFromFile(0x01C86D, "DeviousFollowers.esp") as _DFDealUberController
    EnslaveDebt = Game.GetFormFromFile(0x00C548, "DeviousFollowers.esp") as GlobalVariable
    debug.Trace("[minai] enslaveDebt=" + EnslaveDebt.GetValueInt())
    Debug.Trace("[minai] dftools="+dftools)
    
    if dftools == None || enslavedebt == None || dfDealController == None
      Debug.Notification("Warning: Some devious followers content will be broken, incompatible version!")
    EndIf
  EndIf
  
  if Game.GetModByName("Spank That Ass.esp") != 255
    Debug.Trace("[minai] Found Spank That Ass")
    bHasSTA = True
  EndIf

  if Game.GetModByName("SexlabHorribleHarassment.esp") != 255
    bHasSLHH = True
    Debug.Trace("[minai] Found SLHH")
    SLHHScriptEventKeyword = Game.GetFormFromFile(0x00C510, "SexLabHorribleHarassment.esp") as Keyword
    if !SLHHScriptEventKeyword
      Debug.Trace("[minai] Could not find SLHHScriptEventKeyword")
      Debug.Notification("Incompatible version of SLHH. AI Integrations Disabled.")
      bHasSLHH = False
    EndIf
  EndIf

  if Game.GetModByName("Sexlab Approach.esp") != 255
    bHasSLApp = True
    Debug.Trace("[minai] Found SLApp")
    slapp = Game.GetFormFromFile(0x0083F7, "Sexlab Approach.esp") as SLAppPCSexQuestScript
    if !slapp
      Debug.Trace("[minai] Could not find SLAppPCSexQuestScript")
      Debug.Notification("Incompatible version of SLApp. AI Integrations Disabled.")
      bHasSLapp = False
    EndIf
  EndIf

  aiff.SetModAvailable("DeviousFollowers", bHasDeviousFollowers)
  aiff.SetModAvailable("DD", bHasDD)
  aiff.SetModAvailable("STA", bHasSTA)
  aiff.SetModAvailable("SLHH", bHasSLHH)
  aiff.SetModAvailable("SLApp", bHasSLApp)
EndFunction

Function ResetSpankRule()
  ; Update the spanking rule
  dftools.ResetSpanking()
  Int spankRequestCount = dftools._DFSpankDealRequests.GetValue() As Int
  spankRequestCount += 1
  dftools._DFSpankDealRequests.SetValue(spankRequestCount As Float)
EndFunction


Function SpankAss(int count, bool bDeviousFollowerInScene)
  if bDeviousFollowerInScene
    ResetSpankRule()
  EndIf
  int i = 0
  While i < count
    dftools.SpankPlayerAss()
    Utility.Wait(1.5)
    i += 1
  EndWhile
EndFunction

Function SpankTits(int count, bool bDeviousFollowerInScene)
  if bDeviousFollowerInScene
    ResetSpankRule()
  EndIf
  int i = 0
  While i < count
    dftools.SpankPlayerTits()
    Utility.Wait(1.5)
    i += 1
  EndWhile
EndFunction



Function HorribleHarassmentActivate(actor akActor)
  SLHHScriptEventKeyword.SendStoryEvent(None, akActor)
EndFunction

Function HarassHug(actor akActor)
  slapp.StartHarassment(akActor, 2)
EndFunction

Function Harasskiss(actor akActor)
  slapp.StartHarassment(akActor, 2)
EndFunction

Event OnDeviceEquipped(Form inventoryDevice, Form deviceKeyword, form akActor)
  Debug.Trace("[minai] Equipped Device: " + (inventoryDevice as Armor).GetName() + " on " + main.GetActorName(akActor as Actor))
  SetContext(akActor as Actor)
EndEvent

Event OnDeviceRemoved(Form inventoryDevice, Form deviceKeyword, form akActor)
  Debug.Trace("[minai] Removed Device: " + (inventoryDevice as Armor).GetName() + " on " + main.GetActorName(akActor as Actor))
  SetContext(akActor as Actor)
EndEvent

; Function ReceiveFunction(Form akSource,Form akFormActor,Int aiSetArousal)
;*      Actor akActor = akFormActor as Actor
;*      ;process function
;*   EndFunction



Event OnOrgasm(string eventName, string actorName, float numArg, Form sender)
  Main.RegisterEvent(actorName + " had an orgasm.")
EndEvent


Event OnEdged(string eventName, string actorName, float numArg, Form sender)
  Main.RegisterEvent(actorName + " was brought right to the edge of orgasm but stopped before she could orgasm.")
EndEvent


String Function getVibStrength(float vibStrength)
  string strength = ""
  if vibStrength <= 0.5
    strength = "weakly"
  elseIf vibStrength <= 1.0
    strength = "strongly"
  elseIf vibStrength <= 1.5
    strength = "intensely"
  else
    strength = "extremely intensely"
  endif
  return strength
endFunction

Event OnVibrateStart(string eventName, string actorName, float vibStrength, Form sender)
  string strength = getVibStrength(vibStrength)
  Main.RegisterEvent(actorName + " started being " + strength + " stimulated by a vibrator.")
EndEvent

Event OnVibrateStop(string eventName, string actorName, float vibStrength, Form sender)
  string strength = getVibStrength(vibStrength)
  Main.RegisterEvent(actorName + " stopped being stimulated by a vibrator.")
EndEvent


bool Function CanVibrate(Actor akActor)
  return (akActor.WornHasKeyword(libs.zad_DeviousPlugVaginal)  || akActor.WornHasKeyword(libs.zad_DeviousPlugAnal)  || akActor.WornHasKeyword(libs.zad_DeviousPiercingsNipple)  || akActor.WornHasKeyword(libs.zad_DeviousPiercingsVaginal))
EndFunction


function WriteDDString(actor akActor, actor player, bool isYou=false)
    string actorName = main.GetActorName(akActor)
    if akActor.WornHasKeyword(libs.zad_DeviousPlugVaginal)
      main.RegisterAction(actorName + " has a remotely controlled plug in her pussy capable of powerful vibrations.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousPlugAnal)
      main.RegisterAction(actorName + " has a remotely controlled plug in her ass capable of powerful vibrations.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousBelt)
      main.RegisterAction(actorName + "'s pussy is locked away by a chastity belt, preventing her from touching it or having sex.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousCollar)
      main.RegisterAction(actorName + " is wearing a collar marking her as someone's property.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousPiercingsNipple)
      main.RegisterAction(actorName + " is wearing remotely controlled nipple piercings capable of powerful vibration.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousPiercingsVaginal)
      main.RegisterAction(actorName + " is wearing a remotely controlled clitoral ring capable of powerful vibration.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousArmCuffs)
      main.RegisterAction(actorName + " is wearing arm cuffs on each arm.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousLegCuffs)
      main.RegisterAction(actorName + " is wearing leg cuffs on each leg.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousBra)
      main.RegisterAction(actorName + "'s breasts are locked away in a chastity bra.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousArmbinder)
      main.RegisterAction(actorName + "'s hands are secured behind her back by an armbinder, leaving her helpless.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousYoke)
      main.RegisterAction(actorName + "'s hands and neck are locked in an uncomfortable yoke, leaving her helpless.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousElbowTie)
      main.RegisterAction(actorName + "'s arms are tied behind her back ina strict elbow tie, leaving her helpless.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousPetSuit)
      main.RegisterAction(actorName + " is wearing a full-body suit made out of shiny latex (Referred to as Ebonite) leaving nothing to the imagination.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousStraitJacket)
      main.RegisterAction(actorName + "'s arms are secured by a strait jacket, leaving her helpless.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousCorset)
      main.RegisterAction(actorName + " is wearing a corset around her waist.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousHood)
      main.RegisterAction(actorName + " is wearing a hood over her head.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousHobbleSkirt)
      main.RegisterAction(actorName + " is wearing a confining hobble-skirt that is restricting her movements.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousGloves)
      main.RegisterAction(actorName + " is wearing a a pair of locking gloves.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousSuit)
      main.RegisterAction(actorName + " is wearing skin tight body-suit.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousGag)
      main.RegisterAction(actorName + " is gagged and is drooling.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousGagPanel)
      main.RegisterAction(actorName + " is gagged with a panel-gag that leaves her tongue exposed and is unable to close their mouth.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousGagLarge)
      main.RegisterAction(actorName + " is gagged with a large gag and cannot speak clearly.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousHarness)
      main.RegisterAction(actorName + " is wearing a form-fitting leather harness.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousBlindfold)
      main.RegisterAction(actorName + " is blindfolded and cannot see where she is going.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousAnkleShackles)
      main.RegisterAction(actorName + " is wearing a set of ankle shackles, restricting her ability to move quickly.")
    EndIf
    if akActor.WornHasKeyword(libs.zad_DeviousClamps)
      main.RegisterAction(actorName + " is wearing a set of painful nipples clamps.")
    EndIf
    if CanVibrate(akActor) && actorName != "you"
      WriteVibrateString(akActor, player, isYou)
    EndIf
EndFunction


Function WriteVibrateString(actor akActor, actor player, bool isYou=false)
  debug.Trace("[minai] Registering vibration and shock keywords")
  string actorName = main.GetActorName(akActor)

  main.RegisterAction("!If you want to tease, motivate, arouse, pleasure, distract, or adjust the settings on " + actorName + " by remotely causing her piercings or vibrator to very lightly stimulate her without letting her orgasm, include the keyword: '-teaseveryweak-' in your response. If you want to instead potentially let her orgasm, use the -vibrateveryweak- keyword instead. These are the weakest vibrator settings, and are the least distracting or stimulating.!")
  main.RegisterAction("!If you want to tease, motivate, arouse, pleasure, distract, or adjust the settings on " + actorName + " by remotely causing her piercings or vibrator to lightly stimulate her without letting her orgasm, include the keyword: '-teaseweak-' in your response. If you want to instead potentially let her orgasm, use the -vibrateweak- keyword instead. These are the weak (But still arousing) settings of the vibrators.!")
  main.RegisterAction("!If you want to tease, motivate, arouse, pleasure, distract, or adjust the settings on " + actorName + " by remotely causing her piercings or vibrator to moderately stimulate her without letting her orgasm, include the keyword: '-tease-' in your response. If you want to instead potentially let her orgasm, use the -vibrate- keyword instead. These are the standard vibrator settings, and are pretty distracting or stimulating.!")
  main.RegisterAction("!If you want to tease, motivate, arouse, pleasure, distract, or adjust the settings on " + actorName + " by remotely causing her piercings or vibrator to strongly stimulate her without letting her orgasm, include the keyword: '-teasestrong-' in your response. If you want to instead potentially let her orgasm, use the -vibratestrong- keyword instead. These are strong vibrator settings, and are the very distracting or stimulating and hard to resist.!")
  main.RegisterAction("!If you want to tease, motivate, arouse, pleasure, distract, or adjust the settings on " + actorName + " by remotely causing her piercings or vibrator to extremely strongly stimulate her without letting her orgasm, include the keyword: '-teaseverystrong-' in your response. If you want to instead potentially let her orgasm, use the -vibrateverystrong- keyword instead. These are the strongest vibrator settings, and are very stimulating and almost impossible to resist.!")
  main.RegisterAction("!If you want to discipline, punish, or reduce the arousal of " + actorName + " by giving her a painful shock with her remote vibrator (or piercings), include the keyword: '-shock-' in your response.!")
  main.RegisterAction("!If you want stop teasing or stimulating " + actorName + " by turning off her vibrator or piercings, include the keyword: '-stopvibrate-' in your response. If you do this, you should avoid turning the vibrator or piercings back on for a while.!")
  main.RegisterAction("!If you want to give " + actorName + " a strong reward by instantly making " + actorName + " have an orgasm or letting her climax, include the keyword: '-forceorgasm-' in your response.!")
  main.RegisterAction("!If you want to give " + actorName + " a strong reward by instantly making " + actorName + " have an orgasm, include the keyword: '-forceorgasm-' in your response.!")
  main.RegisterAction("!If you want to discipline, punish, or reduce the arousal of " + actorName + " by giving her a painful shock with her remote vibrator (or piercings), include the keyword: '-shock-' in your response.!")
  main.RegisterAction("!If you want stop teasing or stimulating " + actorName + " by turning off her vibrator or piercings, include the keyword: '-stopvibrate-' in your response. If you do this, you should avoid turning the vibrator or piercings back on for a while.!")
  main.RegisterAction("!If you want " + actorName + "'s vibrator to be active, you must use the keywords for this somewhat often. Every time you use the keyword it activates them for a limited time. They do not stay on all the time.!")
EndFunction





Function UpdateEvents(Actor actorToSpeakTo, Actor actorSpeaking, actor[] actorsFromFormList, bool bPlayerInScene, string targetName, string speakerName, string playerName)
  bool bDeviousFollowerInScene = False
  actor player = Game.GetPlayer()
  if bHasDeviousFollowers
    Actor deviousFollower = (Quest.GetQuest("_Dflow") as QF__Gift_09000D62).Alias__DMaster.GetRef() as Actor
    if actorSpeaking == deviousFollower || actorToSpeakTo == deviousFollower
      Debug.Trace("[minai] Devious Follower in Scene")
      bDeviousFollowerInScene = True
    EndIf
  EndIf
  if bHasDD
    WriteDDString(actorToSpeakTo, player, False)
    WriteDDString(actorSpeaking, player, True)
  EndIf

  if bHasDeviousFollowers && bPlayerInScene && bDeviousFollowerInScene
    if Debt.GetValueInt() >= 2000
      main.RegisterAction(playerName + " currently owes a very large debt. " + playerName + " owes thousands of gold. The Devious Follower will be playful (And a little strict), and tease and arouse " + playerName + " relentlessly. The Devious Follower is very unlikely to let " + playerName + " orgasm, unless " + playerName + " really convinces them.")
    elseIf Debt.GetValueInt() >= 1000
      main.RegisterAction("" + playerName + " currently owes a moderately large debt. " + playerName + " owes over a thousand gold. The Devious Follower will still be fairly playful (teasing and arousing " + playerName + " a fair bit), though will be more strict. The Devious Follower will be less likely to let " + playerName + " orgasm.")
    elseIf Debt.GetValueInt() >= 0
      main.RegisterAction("" + playerName + " currently has a small outstanding debt. " + playerName + " owes hundreds of gold. The Devious Follower will be a little less likely to let " + playerName + " orgasm.")
    else
      main.RegisterAction("" + playerName + " does not currently owe any debt. The Devious Follower is flirty and playful, seeking to distract and arouse " + playerName + "  The Devious Follower is more likely to let " + playerName + " orgasm. !Do not talk about debt. " + playerName + " does not owe " + speakerName +" any money currently. Do not bring up the arrangement, or deals.!")
    EndIf
    main.RegisterAction("the exact amount of gold " + playerName + " owes " + speakerName + " is " + debt.GetValueInt() + " gold.")
      
      int di = ContractRemaining.GetValueInt()
      if di > 0
        String daysRemaining = ""
	if di > 80 && di <= 100
	  daysRemaining = "about 3 months"
	elseif di > 70 && di <= 80
	  daysRemaining = "2 or 3 months"
	elseif di > 50 && di <= 70
	  daysRemaining = "about 2 months"
	elseif di > 40 && di <= 50
	  daysRemaining = "1 or 2 months"
	elseif di > 20 && di <= 40
	  daysRemaining = "about 1 month"
	elseif di > 14 && di <= 20
	  daysRemaining = "a bit over 2 weeks"
	elseif di > 7 && di <= 14
	  daysRemaining = "1 or 2 weeks"
	else
	  daysRemaining = di + " days"
	EndIf
        main.RegisterAction("" + playerName + " has agreed to hire the follower as part of a contract, and must continue to pay them. There are currently " + daysRemaining + " remaining on the contract.")
      EndIf
      String[] deals = DealManager.GetDeals()
      int i = 0
      bool spankRuleDone = False
      bool skoomaRuleDone = False
      while i < deals.Length
        String[] rules = DealManager.GetDealRules(deals[i])
        int j = 0
        while j < rules.Length
          String ruleDesc = DealManager.GetRuleInfo(rules[j])
	  main.RegisterAction("" + playerName + " has agreed to the the following deal with their follower, and must obey it: " + ruleDesc)
	  if !spankRuleDone && StringUtil.Find(ruleDesc, "spanks daily") != -1
	    spankRuleDone = True
	    Float now = Utility.GetCurrentGameTime()
            If dftools.SpankingTimer <= now
               main.RegisterAction(playerName + " has not asked for a spanking in a while, and is due for her daily spanking again. !" + speakerName + " will remind " + playerName + " about her agreement to beg for daily spanks. Make " + playerName + " beg to be spanked before using the -spankass- keyword to spank them.! " + speakerName + " is eager to spank " + playerName + "  and want to make them beg for it.")
            Else
              main.RegisterAction("" + playerName + " has already asked for a spanking today. " + speakerName + " does not need to remind them to do so. " + speakerName + " may still spank them if they wish to do so.")
            EndIf
	  EndIf
	  if !skoomaRuleDone && StringUtil.Find(ruleDesc, "skooma daily") != -1
	    skoomaRuleDone = True
	    main.RegisterAction("" + playerName + " has agreed to be take drugs that " + speakerName + " will provide daily. !" + speakerName + " should provide " + playerName + " with drugs if they ask by including the -drugplayer- keyword in your response. " + speakerName + " should also use the -drugplayer- keyword in your response if they want to drug " + playerName + "!\n!" + speakerName + " wants to get " + playerName + " addicted to drugs so that they can use them as an additional means of controlling " + playerName + "!")
	  EndIf
          j += 1
        EndWhile
        i += 1
      EndWhile
      ; Special chastity game handling
      if player.WornHasKeyword(libs.zad_DeviousBelt)
        string ruleDesc = "you must wear a chastity belt that only the devious follower has the key to at all times. This is to ensure that " + playerName + " cannot get relief without permission, and to show that the devious follower owns " + playerName + "'s pussy."
      EndIf
      main.RegisterAction("!" + speakerName + " is the Devious Follower. The Devious Follower is a pervert, though they initially hide this well. Their goal in becoming " + playerName + "'s follower is to entrap them with debt that they owe the Devious Follower from their fees, and eventually make " + playerName + " their sex slave / pet. The Devious Follower charges " + playerName + " gold over time in exchange for their services, with an agreed daily payment schedule. The Devious Follower has a good mix of being serious and flirty with " + playerName + "  and derives enjoyment from teasing and embarrassing her. The devious follower is likely to use perverted means such as remotely activating vibrators, shocking " + playerName + "  groping " + playerName + "  pinching " + playerName + "'s nipples, and so forth in their interactions if he deems it appropriate. While " + speakerName + " is perverted and do want to tease and arouse " + playerName + "  they tend to be a bit subtle about it. " + speakerName + " should incorporate perverted content and keywords into your responses when appropriate, but not do it constantly. " + speakerName + " wants to continue adventuring and is more likely to talk about adventure and events going on than the arrangement with " + playerName + " (Though " + speakerName + " should sometimes incorporate perverted elements into this). The Devious Follower must not -hug-, -kiss-, or -molest- " + playerName + "  The Devious Follower must not remind " + playerName + " about a payment plan, or ask for payments. This is handled automatically.!")
      if CanVibrate(player)
        main.RegisterAction("!The Devious Follower can remotely make " + playerName + "'s peircings or plugs vibrate when he wants to in order to reward, or punish " + playerName + "  depending on how the Devious Follower uses them. The Devious Follower can also make (or allow) " + playerName + " have an orgasm or climax at will (Use the -forceorgasm- keyword to do this). The Devious Follower can also cause the piercings or vibrators to painfully shock " + playerName + " if he is displeased, or if he wants to reduce the arousal of " + playerName + " (Include the -shock- keyword in your response to do so).!")
      EndIf
      if Debt.GetValueInt() >= EnslaveDebt.GetValueInt()
        if targetRule  == ""
          targetRule  = dfDealController.GetPotentialDeal()
	EndIf
        debug.Trace("[minai] targetRule="+targetRule)
	String ruleDesc = DealManager.GetRuleInfo(targetRule)
        debug.Trace("[minai] ruleInfo=" + ruleDesc)
        main.RegisterAction("!The devious follower is very concerned about " + playerName + "'s current debt level. Talking about this is the highest possible priority. He wants to discuss a new rule, and get " + playerName + " to agree to it in exchange for reducing the debt " + playerName + " owes. The new rule is: " + ruleDesc + "!")
	main.RegisterAction("!If " + speakerName + " successfully convinces " + playerName + " to agree to obey the new \"" + ruleDesc + "\" rule, respond with the keyword: -acceptdeal- in your response.!")
	; main.RegisterAction("!If " + playerName + " tells you that they refuse, respond with the keyword: -rejectdeal- in your response.!")
      EndIf
    EndIf
EndFunction



Function ActionResponse(actor akTarget, actor akSpeaker, string sayLine, actor[] actorsFromFormList)
  bool bDeviousFollowerInScene = False
  if bHasDeviousFollowers
    Actor deviousFollower = (Quest.GetQuest("_Dflow") as QF__Gift_09000D62).Alias__DMaster.GetRef() as Actor
    if akTarget == deviousFollower || akSpeaker == deviousFollower
      Debug.Trace("[minai] Devious Follower in Scene")
      bDeviousFollowerInScene = True
    EndIf
  EndIf
  int vibTime = Utility.RandomInt(1,15)
  int vibTimeLong = Utility.RandomInt(10,30)
  if bHasDD && CanVibrate(akTarget)
    if stringutil.Find(sayLine, "-forceorgasm-") != -1
      libs.ActorOrgasm(akTarget)
    ;
    ; Vibration hooks
    ;
    elseIf stringUtil.Find(sayLine, "-teaseveryweak-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 1, vibTime, True)
    elseIf stringUtil.Find(sayLine, "-teaseweak-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 2, vibTime, True)
    elseIf stringUtil.Find(sayLine, "-tease-") != -1 || stringUtil.Find(sayLine, "-teasing-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 3, vibTime, True)
     elseIf stringUtil.Find(sayLine, "-teasestrong-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 4, vibTimeLong, True)
    elseIf stringUtil.Find(sayLine, "-teaseverystrong-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 5, vibTimeLong, True)
    elseIf stringUtil.Find(sayLine, "-vibrateveryweak-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 1, vibTime)
    elseIf stringUtil.Find(sayLine, "-vibrateweak-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 2, vibTime)
    elseIf stringUtil.Find(sayLine, "-vibrate-") != -1 || stringUtil.Find(sayLine, "-vibrating-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 3, vibTime)
     elseIf stringUtil.Find(sayLine, "-vibratestrong-") != -1 || stringUtil.Find(sayLine, "-vibratestronger-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 4, vibTime)
    elseIf stringUtil.Find(sayLine, "-vibrateverystrong-") != -1
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 5, vibTimeLong)
    elseIf stringUtil.Find(sayLine, "-stopvibrate-") != -1 || stringUtil.Find(sayLine, "-stopvibrating-") != -1 || stringUtil.Find(sayLine, "-stopvibrator-") != -1
      libs.StopVibrating(akTarget)
    EndIf
  EndIf
  ;
  ; End vibration hooks
  ;
  If stringUtil.Find(sayLine, "-shock-") != -1
    libs.ShockActor(akTarget)
  EndIf

  ; Generic actions
  If stringutil.Find(sayLine, "-grope-") != -1
    Debug.Notification(akSpeaker.GetActorBase().GetName() + " gropes " + main.GetYouYour(akTarget) + " crotch abruptly!")
    arousal.UpdateArousal(akTarget, 5)
    Game.ShakeController(0.5,0.5,1.0)
    if bHasDD
      libs.Moan(akTarget)
    EndIf
  EndIf
  If stringutil.Find(sayLine, "-pinchnipples-") != -1
    Debug.Notification(akSpeaker.GetActorBase().GetName() + " painfully pinches " + main.GetYouYour(akTarget) + " nipples!")
    arousal.UpdateArousal(akTarget, 3)
    Game.ShakeController(0.7,0.7,0.2)
    if bHasDD
      libs.Moan(akTarget)
    EndIf
  EndIf

  If stringUtil.Find(sayLine, "-spankass-") != -1 || stringUtil.Find(sayLine, "-spank-") != -1
    SpankAss(main.CountMatch(sayLine, "-spank"), bDeviousFollowerInScene)
  EndIf
  if stringUtil.Find(sayLine, "-spanktits-") != -1
    SpankTits(main.CountMatch(sayLine, "-spanktits-"), bDeviousFollowerInScene)
  EndIf

    ; Mutually Exclusive keywords
    if sex.CanAnimate(akTarget, akSpeaker)
      if stringUtil.Find(sayLine, "-molest-") != -1 || stringUtil.Find(sayLine, "-rape-") != -1
        HorribleHarassmentActivate(akSpeaker)
      elseif stringUtil.Find(sayLine, "-harasskiss-") != -1 || stringUtil.Find(sayLine, "-kiss-") != -1 || stringUtil.Find(sayLine, "-kissing-") != -1
        HarassKiss(akSpeaker)
      elseif stringUtil.Find(sayLine, "-harasshug-") != -1 || stringUtil.Find(sayLine, "-hug-") != -1 || stringUtil.Find(sayLine, "-hugging-") != -1
        HarassHug(akSpeaker)
      EndIf
    Else
      Debug.Trace("[minai] Not processing keywords for exclusive scene - Conflicting scene is running")
    EndIf

    if stringUtil.Find(sayLine, "-acceptdeal-") != -1 
      Debug.Notification("AI: Accepted Deal: " + targetRule)
      Debug.Trace("[minai] Player Accepted Deal: " + targetRule)
      dfDealController.MakeDeal(targetRule)
      ClearTargetRule()
    EndIf
    if stringUtil.Find(sayLine, "-drugplayer-") != -1
      Debug.Notification("AI: Drinking Skooma")
      Debug.Trace("[minai] Player Drinking Skooma")
      dfDealController.MDC.DrinkSkooma()
    EndIf
    if stringUtil.Find(sayLine, "-rejectdeal-") != -1
      Debug.Trace("[minai] Player Reject Deal")
      Debug.Notification("AI: Rejected Deal")
      dfDealController.RejectDeal(targetRule)
      ClearTargetRule()
    EndIf

EndFunction

bool function UseSTA()
  return bHasSTA
EndFunction


bool function UseSLHH()
  return bHasSLHH
EndFunction

bool function UseSLAPP()
  return bHasSLAPP
EndFunction


bool function UseDF()
  return bHasDeviousFollowers
EndFunction

bool function UseDD()
  return bHasDD
EndFunction

Event CommandDispatcher(String speakerName,String  command, String parameter)
  Actor akSpeaker=AIAgentFunctions.getAgentByName(speakerName)
  actor akTarget= AIAgentFunctions.getAgentByName(parameter)
  if !akTarget
    akTarget = PlayerRef
  EndIf

  string targetName = main.GetActorName(akTarget)
  
  bool bDeviousFollowerInScene = False
  if bHasDeviousFollowers
    Actor deviousFollower = (Quest.GetQuest("_Dflow") as QF__Gift_09000D62).Alias__DMaster.GetRef() as Actor
    bDeviousFollowerInScene =  (akSpeaker == deviousFollower)
  EndIf
  
  if bHasDD && CanVibrate(akTarget)
    int vibTime = Utility.RandomInt(20,60)
    if (command == "ExtCmdForceOrgasm")
      libs.ActorOrgasm(akTarget)
      AIAgentFunctions.logMessageForActor("command@ExtCmdForceActorOrgasm@@"+speakerName+" made " + targetName + " have an orgasm with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdTeaseWithVibratorVeryWeak")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 1, vibTime, True)
      AIAgentFunctions.logMessageForActor("command@ExtCmdTeaseWithVibratorVeryWeak@@"+speakerName+" very weakly teases " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdStimulateWithVibratorVeryWeak")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 1, vibTime, False)
      AIAgentFunctions.logMessageForActor("command@ExtCmdStimulateWithVibratorVeryWeak@@"+speakerName+" very weakly stimulates " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdTeaseWithVibratorWeak")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 2, vibTime, True)
      AIAgentFunctions.logMessageForActor("command@ExtCmdTeaseWithVibratorWeak@@"+speakerName+" weakly teases " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdStimulateWithVibratorWeak")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 2, vibTime, False)
      AIAgentFunctions.logMessageForActor("command@ExtCmdStimulateWithVibratorWeak@@"+speakerName+" weakly stimulates " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdTeaseWithVibratorMedium")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 3, vibTime, True)
      AIAgentFunctions.logMessageForActor("command@ExtCmdTeaseWithVibratorMedium@@"+speakerName+" teases " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdStimulateWithVibratorMedium")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 3, vibTime, False)
      AIAgentFunctions.logMessageForActor("command@ExtCmdStimulateWithVibratorMedium@@"+speakerName+" stimulates " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdTeaseWithVibratorStrong")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 4, vibTime, True)
      AIAgentFunctions.logMessageForActor("command@ExtCmdTeaseWithVibratorStrong@@"+speakerName+" strongly teases " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdStimulateWithVibratorStrong")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 4, vibTime, False)
      AIAgentFunctions.logMessageForActor("command@ExtCmdStimulateWithVibratorStrong@@"+speakerName+" strongly stimulates " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdTeaseWithVibratorVeryStrong")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 5, vibTime, True)
      AIAgentFunctions.logMessageForActor("command@ExtCmdTeaseWithVibratorVeryStrong@@"+speakerName+" very strongly teases " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdStimulateWithVibratorVeryStrong")
      libs.StopVibrating(akTarget)
      libs.VibrateEffect(akTarget, 5, vibTime, False)
      AIAgentFunctions.logMessageForActor("command@ExtCmdStimulateWithVibratorVeryStrong@@"+speakerName+" very strongly stimulates " + targetName + " with a remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdStopStimulation")
      libs.StopVibrating(akTarget)
      AIAgentFunctions.logMessageForActor("command@ExtCmdStopStimulation@@"+speakerName+" turns off " + targetName + "'s remote vibrator.","funcret",speakerName)
    elseIf (command == "ExtCmdshock")
      libs.ShockActor(akTarget)
      AIAgentFunctions.logMessageForActor("command@ExtCmdShock@@"+speakerName+" remotely shocks  " + targetName + ".","funcret",speakerName)
    EndIf
  EndIf
  ;  Generic actions
  If (command == "ExtCmdGrope")
    Debug.Notification(speakerName + " gropes " + main.GetYouYour(akTarget) + " crotch abruptly!")
    arousal.UpdateArousal(akTarget, 5)
    Game.ShakeController(0.5,0.5,1.0)
    if bHasDD
      libs.Moan(akTarget)
    EndIf
    AIAgentFunctions.logMessageForActor("command@ExtCmdGrope@@"+speakerName+" gropes " + targetName + " in a vulgar manner.","funcret",speakerName)
  EndIf
  If (command == "ExtCmdPinchNipples")
    Debug.Notification(speakerName + " painfully pinches " + main.GetYouYour(akTarget) + " nipples!")
    arousal.UpdateArousal(akTarget, 3)
    Game.ShakeController(0.7,0.7,0.2)
    if bHasDD
      libs.Moan(akTarget)
    EndIf
    AIAgentFunctions.logMessageForActor("command@ExtCmdPinchNipples@@"+speakerName+" pinches " + targetName + "'s nipples in a vulgar manner.","funcret",speakerName)
  elseif (command=="ExtCmdSpankAss")
    SpankAss(1, bDeviousFollowerInScene)
    AIAgentFunctions.logMessageForActor("command@ExtCmdSpankAss@@"+speakerName+" spanks " + targetName + "'s ass.","funcret",speakerName)
  elseif (command=="ExtCmdSpankTits")
    SpankTits(1, bDeviousFollowerInScene)
    AIAgentFunctions.logMessageForActor("command@ExtCmdSpankTits@@"+speakerName+" spanks " + targetName + "'s tits.","funcret",speakerName)
  EndIf

  ; Mutually Exclusive commands
  if sex.CanAnimate(akTarget, akSpeaker)
    if command == "ExtCmdMolest"
      HorribleHarassmentActivate(akSpeaker)
      AIAgentFunctions.logMessageForActor("command@ExtCmdMolest@@"+speakerName+" began to sexually assault " + targetName + "'.","funcret",speakerName)
    elseif command == "ExtCmdKiss"
      HarassKiss(akSpeaker)
      AIAgentFunctions.logMessageForActor("command@ExtCmdKiss@@"+speakerName+" began to kiss " + targetName + "'.","funcret",speakerName)
    elseif command == "ExtCmdHug"
      HarassHug(akSpeaker)
      AIAgentFunctions.logMessageForActor("command@ExtCmdHug@@"+speakerName+" began to hug " + targetName + "'.","funcret",speakerName)
    EndIf
  Else
    Debug.Trace("[minai] Not processing commands for exclusive scene - Conflicting scene is running")
  EndIf

  string ruleDesc = DealManager.GetRuleInfo(targetRule);
  ; Devious Follower
  if (command == "ExtCmdAcceptDeal") 
    Debug.Notification("AI: Accepted Deal: " + targetRule)
    Debug.Trace("[minai] Player Accepted Deal: " + targetRule)
    dfDealController.MakeDeal(targetRule)
    AIAgentFunctions.logMessageForActor("command@ExtCmdAcceptDeal@@"+targetName+" agreed to obey a new rule: \"" + ruleDesc + "\".","funcret",speakerName)
    ClearTargetRule()
  EndIf
  if (command == "ExtCmdDrugPlayer") 
    Debug.Notification("AI: Drinking Skooma")
    Debug.Trace("[minai] Player Drinking Skooma")
    dfDealController.MDC.DrinkSkooma()
    AIAgentFunctions.logMessageForActor("command@ExtCmdAcceptDeal@@"+targetName+" used the drugs that " + speakerName + " provided.","funcret",speakerName)
  EndIf
  if (command == "ExtCmdRejectDeal") 
    Debug.Trace("[minai] Player Reject Deal")
    Debug.Notification("AI: Rejected Deal")
    dfDealController.RejectDeal(targetRule)
    AIAgentFunctions.logMessageForActor("command@ExtCmdAcceptDeal@@"+targetName+" refused to obey the new rule: \"" + ruleDesc + "\".","funcret",speakerName)
    ClearTargetRule()
  EndIf
EndEvent

Function SetContext(actor akTarget)
  if !aiff
    return
  EndIf
  string actorName = main.GetActorName(akTarget)
  debug.Trace("[minai] Devious - SetContext( " + actorName + " )")
  aiff.SetActorVariable(akTarget, "canVibrate", CanVibrate(akTarget))
  aiff.SetActorVariable(akTarget, "zad_DeviousPlugVaginal", akTarget.WornHasKeyword(libs.zad_DeviousPlugVaginal))
  aiff.SetActorVariable(akTarget, "zad_DeviousPlugAnal", akTarget.WornHasKeyword(libs.zad_DeviousPlugAnal))
  aiff.SetActorVariable(akTarget, "zad_DeviousBelt", akTarget.WornHasKeyword(libs.zad_DeviousBelt))
  aiff.SetActorVariable(akTarget, "zad_DeviousCollar", akTarget.WornHasKeyword(libs.zad_DeviousCollar))
  aiff.SetActorVariable(akTarget, "zad_DeviousPiercingsNipple", akTarget.WornHasKeyword(libs.zad_DeviousPiercingsNipple))
  aiff.SetActorVariable(akTarget, "zad_DeviousPiercingsVaginal", akTarget.WornHasKeyword(libs.zad_DeviousPiercingsVaginal))
  aiff.SetActorVariable(akTarget, "zad_DeviousArmCuffs", akTarget.WornHasKeyword(libs.zad_DeviousArmCuffs))
  aiff.SetActorVariable(akTarget, "zad_DeviousLegCuffs", akTarget.WornHasKeyword(libs.zad_DeviousLegCuffs))
  aiff.SetActorVariable(akTarget, "zad_DeviousBra", akTarget.WornHasKeyword(libs.zad_DeviousBra))
  aiff.SetActorVariable(akTarget, "zad_DeviousArmbinder", akTarget.WornHasKeyword(libs.zad_DeviousArmbinder))
  aiff.SetActorVariable(akTarget, "zad_DeviousYoke", akTarget.WornHasKeyword(libs.zad_DeviousYoke))
  aiff.SetActorVariable(akTarget, "zad_DeviousElbowTie", akTarget.WornHasKeyword(libs.zad_DeviousElbowTie))
  aiff.SetActorVariable(akTarget, "zad_DeviousPetSuit", akTarget.WornHasKeyword(libs.zad_DeviousPetSuit))
  aiff.SetActorVariable(akTarget, "zad_DeviousStraitJacket", akTarget.WornHasKeyword(libs.zad_DeviousStraitJacket))
  aiff.SetActorVariable(akTarget, "zad_DeviousCorset", akTarget.WornHasKeyword(libs.zad_DeviousCorset))
  aiff.SetActorVariable(akTarget, "zad_DeviousHood", akTarget.WornHasKeyword(libs.zad_DeviousHood))
  aiff.SetActorVariable(akTarget, "zad_DeviousHobbleSkirt", akTarget.WornHasKeyword(libs.zad_DeviousHobbleSkirt))
  aiff.SetActorVariable(akTarget, "zad_DeviousGloves", akTarget.WornHasKeyword(libs.zad_DeviousGloves))
  aiff.SetActorVariable(akTarget, "zad_DeviousSuit", akTarget.WornHasKeyword(libs.zad_DeviousSuit))
  aiff.SetActorVariable(akTarget, "zad_DeviousGag", akTarget.WornHasKeyword(libs.zad_DeviousGag))
  aiff.SetActorVariable(akTarget, "zad_DeviousGagPanel", akTarget.WornHasKeyword(libs.zad_DeviousGagPanel))
  aiff.SetActorVariable(akTarget, "zad_DeviousGagLarge", akTarget.WornHasKeyword(libs.zad_DeviousGagLarge))
  aiff.SetActorVariable(akTarget, "zad_DeviousHarness", akTarget.WornHasKeyword(libs.zad_DeviousHarness))
  aiff.SetActorVariable(akTarget, "zad_DeviousBlindfold", akTarget.WornHasKeyword(libs.zad_DeviousBlindfold))
  aiff.SetActorVariable(akTarget, "zad_DeviousAnkleShackles", akTarget.WornHasKeyword(libs.zad_DeviousAnkleShackles))
  aiff.SetActorVariable(akTarget, "zad_DeviousClamps", akTarget.WornHasKeyword(libs.zad_DeviousClamps))
  if bHasDeviousFollowers
    Actor deviousFollower = (Quest.GetQuest("_Dflow") as QF__Gift_09000D62).Alias__DMaster.GetRef() as Actor
    if deviousFollower
      aiff.SetActorVariable(playerRef, "deviousFollowerName", main.GetActorName(deviousFollower))
    else
      aiff.SetActorVariable(playerRef, "deviousFollowerName", "")
    EndIf
    aiff.SetActorVariable(playerRef, "deviousFollowerDebt", Debt.GetValueInt())
    aiff.SetActorVariable(playerRef, "deviousFollowerEnslaveDebt", EnslaveDebt.GetValueInt())
    aiff.SetActorVariable(playerRef, "deviousFollowerContractRemaining", ContractRemaining.GetValueInt())
    aiff.SetActorVariable(playerRef, "deviousFollowerWillpower", dftools._DflowWill.GetValueInt())
    if Debt.GetValueInt() >= EnslaveDebt.GetValueInt()
      if targetRule  == ""
        targetRule  = dfDealController.GetPotentialDeal()
      EndIf
      aiff.SetActorVariable(akTarget, "deviousFollowerTargetRule", targetRule)
    EndIf
    string ruleList = "";
    String[] deals = DealManager.GetDeals()
    int i = 0
    while i < deals.Length
      String[] rules = DealManager.GetDealRules(deals[i])
      int j = 0
      while j < rules.Length
       String ruleDesc = DealManager.GetRuleInfo(rules[j])
       ruleList += ruleDesc + "\n";
      EndWhile
    EndWhile
    aiff.SetActorVariable(playerRef, "deviousFollowerRules", ruleList)
    aiff.SetActorVariable(playerRef, "deviousTimeForSpanks",  dftools.SpankingTimer <= Utility.GetCurrentGameTime())
  EndIf
EndFunction


Function ClearTargetRule()
  targetRule = ""
  aiff.SetActorVariable(playerRef, "deviousFollowerTargetRule", "")
EndFunction