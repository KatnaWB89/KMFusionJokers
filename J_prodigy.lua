-- ========================================================================
-- Prodigy  —  Fusion of Fibonacci + Hack
-- Retriggers each played Ace, 2, 3, 5, or 8, and gives +13 Mult when each
-- of those cards is scored. (Fibonacci's ranks for both the Mult and the
-- Hack-style retrigger.)
-- Self-contained, registered under prefix "kmfuse" -> j_kmfuse_prodigy.
-- ========================================================================

SMODS.Atlas {
    key = 'prodigy',
    path = "j_prodigy.png",
    px = 71,
    py = 95
}

-- Fibonacci ranks: Ace (14), 2, 3, 5, 8
local function is_fib(c)
    if not c then return false end
    local id = c:get_id()
    return id == 14 or id == 2 or id == 3 or id == 5 or id == 8
end

-- Recipe:  Fibonacci + Hack  ->  Prodigy
FusionJokers.fusions:register_fusion{
    jokers = {
        { name = "j_fibonacci" },
        { name = "j_hack" },
    },
    result_joker = "j_kmfuse_prodigy",
    cost = 8,
}

SMODS.Joker {
    key = "prodigy",
    atlas = 'prodigy',
    pos = { x = 0, y = 0 },
    rarity = "fuse_fusion",
    cost = 8,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Prodigy",
        text = {
            "Retrigger each played {C:attention}Ace{}, {C:attention}2{}, {C:attention}3{}, {C:attention}5{}, {C:attention}8{}",
            "and gives {C:mult}+#1#{} Mult when scored",
            "{C:inactive}(#2# + #3#)",
        }
    },
    config = {
        extra = {
            mult = 13,
            retriggers = 1,
            joker1 = "j_fibonacci",
            joker2 = "j_hack"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult,
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'}
            }
        }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and is_fib(context.other_card) then
            -- Hack: retrigger the card
            if context.repetition then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.retriggers,
                    card = card
                }
            end
            -- Fibonacci: +Mult when scored
            if context.individual then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end,
}
