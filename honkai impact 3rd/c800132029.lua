--Pinnacle of Lightning
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
function s.filter(c,tp,cst)
	local oc=c:GetOverlayCount()
	return c:IsFaceup() and c:IsRank(8) and (not cst or oc>=2)
		and Duel.GetDecktopGroup(1-tp,oc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local chkcost=e:GetLabel()==1 and true or false
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp,chkcost) end
	if chk==0 then
		e:SetLabel(0)
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp,chkcost)
	end
	e:SetLabel(0)
	local ct=nil
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp,chkcost)
	if chkcost then
		--cost only
		local mg=Group.CreateGroup()
		for tc in aux.Next(g) do
			mg:Merge(tc:GetOverlayGroup())
		end
		ct=Duel.SendtoGrave(mg,REASON_COST)
	end
	e:SetLabel(ct)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct1=e:GetLabel()
	local tg=Duel.GetDecktopGroup(1-tp,ct1)
	Duel.DisableShuffleCheck()
	local ct2=Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)
	local rg=Duel.GetOperatedGroup()
	local ct3=rg:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	if ct3==ct2 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ct3*800,REASON_EFFECT)
	end
end