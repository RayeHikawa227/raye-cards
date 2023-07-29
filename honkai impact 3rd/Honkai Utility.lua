CARD_KIANA_KASLANA = 800132001
CARD_RAIDEN_MEI = 800132002
CARD_BRONYA_ZAYCHIK = 800132003
CARD_THERESA = 800132004
CARD_HIMEKO = 800132005
HONKAI_KALLEN_ENTIRE_MATERIAL = 800132030

Honkai = {}
--functions
function Honkai.Level4XyzMonsterFilter(c)
	return c:IsLevel(4) or c:IsType(TYPE_XYZ)
end
function Honkai.Rank4Filter(c)
	return c:IsRank(4) and c:IsType(TYPE_XYZ)
end
function Honkai.XyzCost(minc,maxc)
	local min=minc
	local max=maxc
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
			local c=e:GetHandler()
			if chk==0 then
				return c:CheckRemoveOverlayCard(tp,min,REASON_COST)
			end
			c:RemoveOverlayCard(tp,min,max,REASON_COST)
		end
end

function Honkai.UnleashWeapon(c,id,eff,matcode,wepcode)
	--search
	local eff=Effect.CreateEffect(c)
	eff:SetDescription(aux.Stringid(id,0))
	eff:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	eff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	eff:SetCode(EVENT_SPSUMMON_SUCCESS)
	eff:SetProperty(EFFECT_FLAG_DELAY)
	eff:SetLabel(0)
	eff:SetCondition(Honkai.SearchCondition)
	eff:SetTarget(Honkai.SearchTarget(wepcode))
	eff:SetOperation(Honkai.SearchOperation(wepcode))
	c:RegisterEffect(eff)
	local mat_eff=Effect.CreateEffect(c)
	mat_eff:SetType(EFFECT_TYPE_SINGLE)
	mat_eff:SetCode(EFFECT_MATERIAL_CHECK)
	mat_eff:SetValue(Honkai.MaterialCheck(matcode))
	mat_eff:SetLabelObject(eff)
	c:RegisterEffect(mat_eff)
end
function Honkai.MaterialCheck(matcode)
	local code=matcode
	return function(e,c)
			if c:GetMaterial():IsExists(Card.IsCode,1,nil,code) then
				e:GetLabelObject():SetLabel(1)
			end
		end
end
function Honkai.SearchCondition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
function Honkai.SearchFilter(c,code)
	return c:IsAbleToHand() and c:IsCode(code)
end
function Honkai.SearchTarget(wepcode)
	local code=wepcode
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then
				return Duel.IsExistingMatchingCard(Honkai.SearchFilter,tp,LOCATION_DECK,0,1,nil,code)
			end
			Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		end
end
function Honkai.SearchOperation(wepcode)
	local code=wepcode
	return function(e,tp,eg,ep,ev,re,r,rp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,Honkai.SearchFilter,tp,LOCATION_DECK,0,1,1,nil,code)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
end
function Honkai.Rank4or8Filter(c)
	return c:IsType(TYPE_XYZ) and (c:IsRank(4) or c:IsRank(8))
end
function Honkai.WeaponEquip(c,tp,id)
	aux.AddEquipProcedure(c,tp,Honkai.Rank4or8Filter)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(Honkai.SpecialSummonCondition)
	e1:SetTarget(Honkai.SpecialSummonTarget)
	e1:SetOperation(Honkai.SpecialSummonOperation(id))
	c:RegisterEffect(e1)
	--gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
end
function Honkai.SpecialSummonCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	if not c then return false end
	return c:GetOverlayCount()==0
end
function Honkai.SpecialSummonFilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function Honkai.SpecialSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and Honkai.SpecialSummonFilter(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsDestructable() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(Honkai.SpecialSummonFilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local g=Duel.SelectTarget(tp,Honkai.SpecialSummonFilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function Honkai.SpecialSummonOperation(id)
	local string_id=id
	return function(e,tp,eg,ep,ev,re,r,rp)
			local c=e:GetHandler()
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) then
				if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
					Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(string_id,3))
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
				e1:SetTargetRange(1,0)
				e1:SetTarget(Honkai.SpecialSummonLimit)
				e1:SetLabel(tc:GetCode())
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
end
function Honkai.SpecialSummonLimit(e,c)
	return c:IsCode(e:GetLabel())
end
function Honkai.EnableKallenEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(9000)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetCondition(Honkai.XyzCondition)
	e1:SetTarget(Honkai.XyzTarget)
	e1:SetOperation(Honkai.XyzOperation)
	c:RegisterEffect(e1)
end
function Honkai.XyzMaterialFilter(c,tp)
	return c:IsHasEffect(800132030,tp) and c:IsLocation(LOCATION_MZONE)
end
function Honkai.XyzCondition(e,c)
	if c==nil then return true end
	local g=Duel.GetMatchingGroup(Honkai.XyzMaterialFilter,c:GetControler(),LOCATION_MZONE,0,nil,c:GetControler())
	return #g>0
end
function Honkai.XyzTarget(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(Honkai.XyzMaterialFilter,tp,LOCATION_MZONE,0,nil,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=g:Select(tp,1,1,nil)
		e:SetLabelObject(sg)
		sg:KeepAlive()
		return true
	end
	return false
end
function Honkai.XyzOperation(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,0,800132030)
	local mg=e:GetLabelObject()
	local tc=mg:GetFirst()
	local te=tc:IsHasEffect(800132030,tp)
	if te then te:UseCountLimit(tp) end
	c:SetMaterial(mg)
	Duel.Overlay(c,mg)
end