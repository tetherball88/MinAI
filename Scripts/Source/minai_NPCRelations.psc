Scriptname minai_NPCRelations extends Quest  

AssociationType property ParentChild auto
AssociationType property GrandParentGrandChild auto
AssociationType property GreatGrandParentGreatGrandChild auto
AssociationType property InLawParentChild auto
AssociationType property InLawGrandParentGrandChild auto
AssociationType property Siblings auto
AssociationType property Cousins auto
AssociationType property InLawBrotherSister auto
AssociationType property AuntUncle auto
AssociationType property GrandAuntUncle auto
AssociationType property InLawAuntUncle auto
AssociationType property Courting auto
AssociationType property Spouse auto

; map of npcs in-game relationships. It will compare and store relationships once per game load.
int jRelationsMap

function Maintenance()
    jRelationsMap = JValue.releaseAndRetain(jRelationsMap, JMap.object())
endfunction

string Function getRelations(actor a1, actor a2)
    string a1Name = a1.GetDisplayName()
    string a2Name = a2.GetDisplayName()
    string namePair = a1Name+"-"+a2Name
    string reverseNamePair = a2Name+"-"+a1Name

    if(JMap.hasKey(jRelationsMap, namePair))
        return JMap.getStr(jRelationsMap, namePair)
    elseif(JMap.hasKey(jRelationsMap, reverseNamePair))
        return JMap.getStr(jRelationsMap, reverseNamePair)
    else
        bool isFamily = a1.HasFamilyRelationship(a2)
        ; partner is extended(beside spouse) to courting association type and relationship rank 4(lover)
        if(IsPartner(a1, a2))
            JMap.setStr(jRelationsMap, namePair, "partner")
            return "partner"
        ; family is actually anyone else who can considered family(except spouses)
        elseif(isFamily)
            ; all in law non-blood relatives
            if(IsInLawRelative(a1, a2))
                JMap.setStr(jRelationsMap, namePair, "inlaw")
                return "inlaw"
            ; all non in-law and non spouses relatives
            else
                JMap.setStr(jRelationsMap, namePair, "blood")
                return "blood"
            endif
        ; it doesn't actually matter for purposes of this logic which other relationship is
        else
            JMap.setStr(jRelationsMap, namePair, "other")
            return "other"
        endif
    endif
EndFunction

; if npcs are in romantic relationships: spouse, courting or when there relationship rank is lover
bool Function IsPartner(actor actor1, actor actor2)
    if(actor1.HasAssociation(Courting, actor2) || actor1.HasAssociation(Spouse, actor2) || actor1.GetRelationshipRank(actor2) == 4)
        return true
    else
        return false
    endif
EndFunction


; if npcs are in in-law relationships
bool Function IsInLawRelative(actor actor1, actor actor2)
    if(actor1.HasAssociation(InLawParentChild, actor2) || actor1.HasAssociation(InLawGrandParentGrandChild, actor2) || actor1.HasAssociation(InLawBrotherSister, actor2) || actor1.HasAssociation(InLawAuntUncle, actor2))
        return true
    else
        return false
    endif
EndFunction