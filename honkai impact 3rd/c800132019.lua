--Hikate's Sombre
--scripted by Raye
Duel.LoadScript("Honkai Utility.lua")
local s,id=GetID()
function s.initial_effect(c)
	Honkai.WeaponEquip(c,tp,id)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetCountLimit(1,{id,1})
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
end
s.listed_series={0x900,0x901}
function s.repval(e,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end