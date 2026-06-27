-- ========================================================================
-- Treasure Treasury  —  Fusion of Swashbuckler + Gift Card
--   * Adds the sell value of all other Jokers AND all Consumables to Mult
--     when scored                                          (Swashbuckler)
--   * At end of round, adds $1 sell value to every Joker    (Gift Card)
--     and Consumable
-- Self-contained, registered under prefix "kmfuse" -> j_kmfuse_treasure_treasury.
-- ========================================================================

SMODS.Atlas {
    key = 'treasure_treasury',
    path = "j_treasure_treasury.png",
    px = 71,
    py = 95
}

-- Sum of sell values of all OTHER Jokers + all Consumables
local function tt_total(card)
    local sell = 0
    if G.jokers and G.jokers.cards then
        for _, v in ipairs(G.jokers.cards) do
            if v ~= card and v.area == G.jokers then sell = sell + (v.sell_cost or 0) end
        end
    end
    if G.consumeables and G.consumeables.cards then
        for _, v in ipairs(G.consumeables.cards) do
            sell = sell + (v.sell_cost or 0)
        end
    end
    return sell
end

-- Recipe:  Swashbuckler + Gift Card  ->  Treasure Treasury
FusionJokers.fusions:register_fusion{
    jokers = {
        { name = "j_swashbuckler" },
        { name = "j_gift" },
    },
    result_joker = "j_kmfuse_treasure_treasury",
    cost = 9,
}

SMODS.Joker {
    key = "treasure_treasury",
    atlas = 'treasure_treasury',
    pos = { x = 0, y = 0 },
    rarity = "fuse_fusion",
    cost = 9,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Treasure Treasury",
        text = {
            "Adds the {C:money}sell value{} of all {C:attention}Jokers{}",
            "and {C:attention}Consumables{} to {C:mult}Mult{} when scored",
            "Adds {C:money}$#1#{} of sell value to every {C:attention}Joker{}",
            "and {C:attention}Consumable{} at end of round",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)",
            "{C:inactive}(#3# + #4#)",
        }
    },
    config = {
        extra = {
            gift = 1,
            joker1 = "j_swashbuckler",
            joker2 = "j_gift"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.gift,
                tt_total(card),
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'}
            }
        }
    end,
    calculate = function(self, card, context)
        -- Gift Card: at end of round, add sell value to every Joker and Consumable
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            local bumped = false
            for _, v in ipairs(G.jokers.cards) do
                if v.set_cost then
                    v.ability.extra_value = (v.ability.extra_value or 0) + card.ability.extra.gift
                    v:set_cost()
                    bumped = true
                end
            end
            for _, v in ipairs(G.consumeables.cards) do
                if v.set_cost then
                    v.ability.extra_value = (v.ability.extra_value or 0) + card.ability.extra.gift
                    v:set_cost()
                    bumped = true
                end
            end
            if bumped then
                return { message = localize('k_val_up'), colour = G.C.MONEY, card = card }
            end
        end

        -- Swashbuckler: add the total sell value to Mult when scored
        if context.cardarea == G.jokers and context.joker_main then
            local sell = tt_total(card)
            if sell > 0 then
                return {
                    message = localize{type = 'variable', key = 'a_mult', vars = {sell}},
                    mult_mod = sell
                }
            end
        end
    end,
}
