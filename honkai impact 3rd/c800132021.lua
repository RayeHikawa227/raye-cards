--The Valkyrja Crossover
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--apply effect
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.cost)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_series={0x900,0x901}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id+3)==0 end
	Duel.RegisterFlagEffect(tp,id+3,RESET_CHAIN,0,1)
end
function s.cfilter(c)
	return c:IsType(TYPE_XYZ) and c:GetSummonLocation()==LOCATION_EXTRA
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.thfilter1(c)
	return c:IsCode(800132009) and c:IsAbleToHand()
end
function s.thfilter2(c,tp)
	return c:IsSetCard(0x901) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id+1)==0
	local b3=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.GetFlagEffect(tp,id+2)==0
	if chk==0 then return b1 or b2 or b3 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)==0 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id+1)==0 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.GetFlagEffect(tp,id+2)==0 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	elseif opval[op]==2 then
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
		end
	elseif opval[op]==3 then 
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil,tp)
		if #g>0 then
			if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
				Duel.ConfirmCards(1-tp,g)
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,g:GetFirst())
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
			end
			Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
		end
	end
end