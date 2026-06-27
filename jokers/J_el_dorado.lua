-- ========================================================================
-- El Dorado  —  Fusion of Golden Ticket + Midas Mask
--   * All played face cards become Gold cards when scored   (Midas Mask)
--   * Played Gold cards earn $5 when scored                 (Golden Ticket)
-- Because the Midas part runs in context.before (turning faces to Gold)
-- and the Golden Ticket part runs in context.individual (paying on Gold
-- cards), the freshly-gilded faces are paid out in the same hand.
-- Self-contained, registered under prefix "kmfuse" -> j_kmfuse_el_dorado.
-- ========================================================================

KMFusionJokers = KMFusionJokers or {}

SMODS.Atlas {
    key = 'el_dorado',
    path = "j_el_dorado.png",
    px = 71,
    py = 95
}

-- Recipe:  Golden Ticket + Midas Mask  ->  El Dorado
FusionJokers.fusions:register_fusion{
    jokers = {
        { name = "j_ticket" },      -- Golden Ticket
        { name = "j_midas_mask" },  -- Midas Mask
    },
    result_joker = "j_kmfuse_el_dorado",
    cost = 10,
}

SMODS.Joker {
    key = "el_dorado",
    atlas = 'el_dorado',
    pos = { x = 0, y = 0 },
    rarity = "fuse_fusion",
    cost = 10,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "El Dorado",
        text = {
            "All played {C:attention}face{} cards become",
            "{C:attention}Gold{} cards and earn {C:money}$#1#{}",
            "when scored",
            "{C:inactive}(#2# + #3#)",
        }
    },
    config = {
        extra = {
            dollars = 5,
            joker1 = "j_ticket",
            joker2 = "j_midas_mask"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.dollars,
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'}
            }
        }
    end,
    calculate = function(self, card, context)
        -- Midas Mask: turn played face cards into Gold cards when scored
        if context.before and context.cardarea == G.jokers and not context.blueprint then
            local faces = {}
            for _, v in ipairs(context.scoring_hand) do
                if v:is_face() then
                    faces[#faces + 1] = v
                    v:set_ability(G.P_CENTERS.m_gold, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v:juice_up()
                            return true
                        end
                    }))
                end
            end
            if #faces > 0 then
                return {
                    message = localize('k_gold'),
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end

        -- Golden Ticket: played Gold cards earn money when scored
        if context.individual and context.cardarea == G.play and context.other_card
           and context.other_card.ability.name == 'Gold Card' then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            G.E_MANAGER:add_event(Event({ func = function() G.GAME.dollar_buffer = 0; return true end }))
            return {
                dollars = card.ability.extra.dollars,
                card = card
            }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = "+$" },
                { ref_table = "card.joker_display_values", ref_value = "dollars", retrigger_type = "mult" },
            },
            text_config = { colour = G.C.MONEY },
            calc_function = function(card)
                -- Count scoring cards that are (or will become) Gold: existing Gold cards + face cards
                local dollars = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card.ability.name == 'Gold Card' or scoring_card:is_face() then
                            dollars = dollars + card.ability.extra.dollars *
                                JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.dollars = dollars
            end
        }
    end
}
