-- KM Fusion Jokers
-- An add-on for the "Fusion Jokers" mod. Adds the Speedrun fusion.
-- (Manifest lives in KMFusionJokers.json)

KMFusionJokers = KMFusionJokers or {}

-- Bail out gracefully if the Fusion Jokers engine isn't present.
if not (FusionJokers and FusionJokers.fusions and FusionJokers.fusions.register_fusion) then
	sendWarnMessage("Fusion Jokers is not loaded — Speedrun will not be registered.", "KMFusionJokers")
	return
end

SMODS.load_file('jokers/J_speedrun.lua')()
