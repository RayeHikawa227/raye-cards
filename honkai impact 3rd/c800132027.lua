--Flamescion Final Strike
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x900,0x901,0x902}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.filter(c,cst)
	local oc=c:GetOverlayCount()
	return c:IsFaceup() and c:IsRank(8) and (not cst or oc>=2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local chkcost=e:GetLabel()==1 and true or false
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,chkcost) end
	if chk==0 then
		e:SetLabel(0)
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,chkcost)
	end
	e:SetLabel(0)
	local ct=nil
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,chkcost)
	if chkcost then
		--cost only
		local mg=Group.CreateGroup()
		for tc in aux.Next(g) do
			mg:Merge(tc:GetOverlayGroup())
		end
		ct=Duel.SendtoGrave(mg,REASON_COST)
	end
	e:SetLabel(ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local resolve=false
	local ct=e:GetLabel()
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		resolve=true
	end
	if resolve then
		--cannot activate
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetTargetRange(LOCATION_ALL,0)
		e2:SetLabel(tc:GetFieldID())
		e2:SetTarget(s.actlimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		--cannot attack
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetLabel(tc:GetFieldID())
		e3:SetTarget(s.atklimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.actlimit(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
function s.atklimit(e,c)
	return e:GetLabel()~=c:GetFieldID()
end