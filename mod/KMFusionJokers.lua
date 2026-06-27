-- KM Fusion Jokers
-- Fusion jokers for the "Fusion Jokers" engine. The fusion UI/system lives in
-- the "NeoCore Fusion" library (a dependency).
-- (Manifest lives in KMFusionJokers.json)

KMFusionJokers = KMFusionJokers or {}

-- Bail out gracefully if the Fusion Jokers engine isn't present.
if not (FusionJokers and FusionJokers.fusions and FusionJokers.fusions.register_fusion) then
	sendWarnMessage("Fusion Jokers is not loaded — Speedrun will not be registered.", "KMFusionJokers")
	return
end

SMODS.load_file('jokers/J_speedrun.lua')()
SMODS.load_file('jokers/J_el_dorado.lua')()
SMODS.load_file('jokers/J_treasure_treasury.lua')()
SMODS.load_file('jokers/J_prodigy.lua')()
