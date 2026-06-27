-- ========================================================================
-- Speedrun  —  Fusion of Runner + Shortcut
--   * Lets Straights be built with a gap of 1 rank          (Shortcut)
--   * Gains +Mult every time the played hand contains a     (Runner, but
--     Straight; the bonus is applied to every scored hand     Mult instead
--                                                              of Chips)
-- Self-contained: art atlas, fusion recipe, shortcut patch and the Joker
-- (with inline loc_txt) all live in this one file.
-- Registered under prefix "kmfuse"  ->  full key  j_kmfuse_speedrun
-- ========================================================================

KMFusionJokers = KMFusionJokers or {}

SMODS.Atlas {
    key = 'speedrun',
    path = "j_speedrun.png",
    px = 71,
    py = 95
}

-- Register the fusion recipe through Fusion Jokers' public API:
--   Runner + Shortcut  ->  Speedrun
FusionJokers.fusions:register_fusion{
    jokers = {
        { name = "j_runner" },
        { name = "j_shortcut" },
    },
    result_joker = "j_kmfuse_speedrun",
    cost = 6,
}

-- ------------------------------------------------------------------------
-- Grant the "Shortcut" ability while a Speedrun is owned.
-- SMODS' get_straight() asks SMODS.shortcut() whether straights may be
-- built with a 1-rank gap. We additively wrap it so the vanilla Shortcut
-- joker (and any other mod's wrapper) keeps working too. The guard stops
-- us from stacking the wrapper if the file is ever re-run.
-- ------------------------------------------------------------------------
if not KMFusionJokers.speedrun_shortcut_patched then
    KMFusionJokers.speedrun_shortcut_patched = true
    local smods_shortcut_ref = SMODS.shortcut
    function SMODS.shortcut()
        if next(SMODS.find_card('j_kmfuse_speedrun')) then
            return true
        end
        return smods_shortcut_ref()
    end
end

SMODS.Joker {
    key = "speedrun",
    atlas = 'speedrun',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "fuse_fusion",
    cost = 6,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Speedrun",
        text = {
            "Allows {C:attention}Straights{} to be made",
            "with gaps of {C:attention}1{} rank",
            "Gains {C:mult}+#1#{} Mult if played",
            "hand contains a {C:attention}Straight{}",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)",
            "{C:inactive}(#3# + #4#)",
        }
    },
    config = {
        extra = {
            mult = 0,            -- running Mult bonus (grows as you play Straights)
            mult_mod = 3,        -- Mult gained each time a Straight is played
            joker1 = "j_runner",
            joker2 = "j_shortcut"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult_mod,
                card.ability.extra.mult,
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'}
            }
        }
    end,
    calculate = function(self, card, context)
        -- Scale up: gain Mult whenever the played hand contains a Straight.
        -- context.poker_hands already accounts for the gap from Shortcut.
        if context.before and context.cardarea == G.jokers and not context.blueprint then
            if context.poker_hands and next(context.poker_hands['Straight']) then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        -- Apply the accumulated Mult to every scored hand (like Runner's Chips).
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult
            }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                card.joker_display_values.mult = card.ability.extra.mult
            end
        }
    end
}
