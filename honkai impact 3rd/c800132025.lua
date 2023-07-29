--Sirin, The Ascendant Second Herrscher
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--select effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(Honkai.XyzCost(1,1))
	e1:SetTarget(s.target)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	Honkai.EnableKallenEffect(c)
end
s.listed_series={0x900,0x901}
s.listed_names={800132009}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local turn=Duel.GetTurnPlayer()
	if chk==0 then
		if turn~=tp then
			return s.copytg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
	if turn~=tp then
		s.copytg(e,tp,eg,ep,ev,re,r,rp,0)
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetOperation(s.copyop)
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
	else
		s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e:SetOperation(s.thop)
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
	end
end
function s.cpfilter(c)
	return c:IsCode(800132009) and c:IsAbleToGrave() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
		if not te then return end
		local tg=te:GetTarget()
		local op=te:GetOperation()
		if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
		Duel.BreakEffect()
		tc:CreateEffectRelation(te)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for etc in aux.Next(g) do
			etc:CreateEffectRelation(te)
		end
		if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
		tc:ReleaseEffectRelation(te)
		for etc in aux.Next(g) do
			etc:ReleaseEffectRelation(te)
		end
	end
end
function s.thfilter(c)
	return c:IsCode(800132009) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end