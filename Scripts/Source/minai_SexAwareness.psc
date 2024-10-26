Scriptname minai_SexAwareness extends Quest  

Actor property PlayerRef auto

minai_Config config
minai_Sex sex
minai_MainQuestController main

SexLabFramework slf = None

minai_NPCRelations npcRelations

; delay between dected interactions. Low number will be firing to often when somebody sees someone else having ostim scene or somebody who is having ostim scene will always focus on somebody who is found them.
float property detectedInteractionsCooldown = 30.0 auto
; Delay before pair of actors who already interacted on detection before they can interact again(if both actors are still present at scene)
float property pairDetectedInteractionCooldown = 30.0 auto
; When was last detected interaction
float prevDetectedInteractionTime = 0.0

; When somebody interacts on detection we want to put them on cooldown, otherwise they most likely will always interact
int jDetectedInteractionsCooldownMap

function Maintenance(minai_Sex _sex, SexLabFramework _slf)
    config = Game.GetFormFromFile(0x0912, "MinAI.esp") as minai_Config
    sex = _sex
    main = (_sex as Quest) as minai_MainQuestController
    slf = _slf
    npcRelations = (_sex as Quest) as minai_NPCRelations

    jDetectedInteractionsCooldownMap = JValue.releaseAndRetain(jDetectedInteractionsCooldownMap, JMap.object())
endfunction

Function scanDetections()
    MiscUtil.PrintConsole("scanDetections")
    float scanDetectionsTs = Utility.GetCurrentRealTime()
    actor[] actors = OActorUtil.GetActorsInRange(PlayerRef, 1500, true)
    int i = 0
    ; Maps npcs between each other who detected whom. Shape: {partner: [{observer: Actor, subject: Actor}], blood: [{observer: Actor, subject: Actor}], inlaw: [{observer: Actor, subject: Actor}], other: [{observer: Actor, subject: Actor}]}
    int jDetectedPairsMap = JValue.releaseAndRetain(jDetectedPairsMap, JMap.object())
    ; JArray of Actors which are participating in sex scenes.
    int jOstimActorsNearby = JValue.releaseAndRetain(jOstimActorsNearby, JArray.object())
    ; JArray of Actors who aren't in sex scenes
    int jNonOstimActorsNearby = JValue.releaseAndRetain(jNonOstimActorsNearby, JArray.object())

    while(i < actors.Length)
        actor currActor = actors[i]
        if(currActor.IsChild())
            ; make child run away
        elseif(!currActor.Is3DLoaded())
            ; skip disabled/hidden actor and don't add to either array
        elseif(OActor.IsInOStim(currActor))
            JArray.addForm(jOstimActorsNearby, currActor)
        else
            JArray.addForm(jNonOstimActorsNearby, currActor)
        endif

        i += 1
    endwhile

    int ostimActorsLength = JArray.count(jOstimActorsNearby)
    int nonOstimActorsLength = JArray.count(jNonOstimActorsNearby)
    i = 0

    while(i < ostimActorsLength)
        actor ostimActor = JArray.getForm(jOstimActorsNearby, i) as actor
        int j = 0

        while(j < nonOstimActorsLength)
            actor nonOstimActor = JArray.getForm(jNonOstimActorsNearby, i) as actor
            actor observer = none
            actor subject = none
            ; first check if non-ostim actor noticed any ostim actor, excluding player from potential observer. Player can react however they want
            if(nonOstimActor != PlayerRef && Noticed(nonOstimActor, ostimActor))
                observer = nonOstimActor
                subject = ostimActor
            ; second check if ostim actor noticed any non-ostim actor, excluding player from potential observer. Player can react however they want
            elseif(ostimActor != PlayerRef && Noticed(ostimActor, nonOstimActor))
                observer = ostimActor
                subject = nonOstimActor
            endif

            if(observer && subject)
                string relations = npcRelations.getRelations(observer, subject)
                float pairTimestamp = getPairTimestamp(jDetectedInteractionsCooldownMap, observer, subject)
                if(pairTimestamp == -1.0 || Utility.GetCurrentRealTime() - pairTimestamp > pairDetectedInteractionCooldown)
                    addPair(jDetectedPairsMap, relations, observer, subject)
                endif
            endif
            j += 1
        endwhile
        i += 1
    endwhile
    int pair = getPair(jDetectedPairsMap)

    if(pair > 0)
        actor observer = JMap.getForm(pair, "observer") as actor
        actor subject = JMap.getForm(pair, "subject") as actor
        interactionOnDetect(npcRelations.getRelations(observer, subject), observer, subject)
    endif
EndFunction

function interactionOnDetect(string type, actor observer, actor subject)
    if(Utility.GetCurrentRealTime() - prevDetectedInteractionTime <= detectedInteractionsCooldown)
        prevDetectedInteractionTime = Utility.GetCurrentRealTime()
        return
    endif

    MiscUtil.PrintConsole("Started interaction. observer: "+observer.GetDisplayName()+"; subject: "+subject.GetDisplayName())

    addPairTimestamp(jDetectedInteractionsCooldownMap, observer, subject)

    string isObserverOstim = "false"

    if(OActor.IsInOStim(observer))
        isObserverOstim = "true"
    endif

    AIAgentFunctions.requestMessageForActor("command@ExtCmdOIDetects@{\"subject\": \""+subject.GetDisplayName()+"\", \"isObserverOstim\": \""+isObserverOstim+"\", \"relation\": \""+type+"\"}@", "funcret", observer.GetDisplayName())
    
endfunction

bool Function Noticed(actor searchingActor, actor targetActor) global
    ; For an actor that isn't hostile (ie wouldn't attack the other), the first time you "poke" an actor asking about his detection, 
    ; it essentially "wakes up" detection running on that actor but doesn't actually check until the next time you poke him for detection. 
    ; If you don't poke him fast enough the second time, you'll just "wake him up" again.
    if (targetActor.HasLOS(searchingActor))
        MiscUtil.PrintConsole(searchingActor.GetDisplayName()+" detects "+targetActor.GetDisplayName())
		return true
	endif
    return false
EndFunction

; jDetectedMap - JMap to store calculated values
; type - relations type: partner, blood, inlaw, other
; observer - actor who detected
; subject - actor who was detected
; Function to add 2 actors in detected by relationships actors with differentiating who noticed whom
function addPair(int jDetectedMap, string type, actor observer, actor subject) global
    int typeArr = JMap.getObj(jDetectedMap, type)
    if(!typeArr)
        typeArr = JArray.object()
        JMap.setObj(jDetectedMap, type, typeArr)
    endif
    int pair = JMap.object()
    JMap.setForm(pair, "observer", observer)
    JMap.setForm(pair, "subject", subject)
    JArray.addObj(typeArr, pair)
endfunction

; jDetectedMap - JMap to store calculated values
; get first pair of actors sorted by relations
; first it checks partner relations, if there are no partner pairs
; second it checks blood relatives, if there are no blood pairs
; third it checks inlaw relatives, if there are no inlaw pairs
; finally it will pick a pair from other relation
int function getPair(int jDetectedMap) global
    int pair = getPairByRelation(jDetectedMap, "partner")
    if(pair > 0)
        return pair
    endif
    
    pair = getPairByRelation(jDetectedMap, "blood")
    if(pair > 0)
        return pair
    endif
    
    pair = getPairByRelation(jDetectedMap, "inlaw")
    if(pair > 0)
        return pair
    endif
    
    return getPairByRelation(jDetectedMap, "other")
endfunction

; jDetectedMap - JMap to store calculated values
; type - relations type: partner, blood, inlaw, other
; Just shortcut function to get array of pairs by particular relation
int function getPairByRelation(int jDetectedMap, string type) global
    int typeArr = JMap.getObj(jDetectedMap, type)
    if(typeArr > 0 && JArray.count(typeArr) > 0)
        return JArray.getObj(typeArr, 0)
    endif

    return 0
endfunction

; jCooldown - JMap of timestamps when pair of actors already had detection reaction
; observer - actor who detected
; subject - actor who was detected
; Record when pair of actors reacted in this detection system
function addPairTimestamp(int jCooldown, actor observer, actor subject) global
    string key1 = observer.GetDisplayName()+":"+subject.GetDisplayName()
    string key2 = subject.GetDisplayName()+":"+observer.GetDisplayName()
    float time = Utility.GetCurrentRealTime()
    JMap.setFlt(jCooldown, key1, time)
    JMap.setFlt(jCooldown, key2, time)
endfunction

; jCooldown - JMap of when pair of actors already had detection reaction to use it to throttle next time detection system wants to pick pair of actors
; observer - actor who detected
; subject - actor who was detected
; Get last time pair of actors had reacted on detection
float function getPairTimestamp(int jCooldown, actor observer, actor subject) global
    string key1 = observer.GetDisplayName()+":"+subject.GetDisplayName()
    string key2 = subject.GetDisplayName()+":"+observer.GetDisplayName()
    if(JMap.getFlt(jCooldown, key1))
        return JMap.getFlt(jCooldown, key1)
    elseif(JMap.getFlt(jCooldown, key2))
        return JMap.getFlt(jCooldown, key2)
    endif
    return -1.0
endfunction