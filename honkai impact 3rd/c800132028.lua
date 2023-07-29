--Cyberangel Giga Burst
--scripted by Raye Hikawa
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
		and Duel.IsPlayerCanDraw(1-tp,oc)
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
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	if ct>0 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
		if not g then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=g:Select(1-tp,ct,ct,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			for tc in g:Iter() do
				if tc:IsLocation(LOCATION_REMOVED) then
					--cannot be added
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetCode(EFFECT_CANNOT_TO_HAND)
					e1:SetTargetRange(0,LOCATION_DECK)
					e1:SetLabel(tc:GetCode())
					e1:SetTarget(s.tglimit)
					e1:SetReset(RESET_PHASE+PHASE_END)
					Duel.RegisterEffect(e1,tp)
				end
			end
		end
	end
end
function s.tglimit(e,c)
	return c:IsCode(e:GetLabel())
end