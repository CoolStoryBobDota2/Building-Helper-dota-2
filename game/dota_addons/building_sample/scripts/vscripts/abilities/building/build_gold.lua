build_gold = class({})

function build_gold:OnSpellStart()
	Build( {caster = self:GetCaster(), ability = self })
end
