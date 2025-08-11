
-- SMODS.Fonts.hpot_plincoin
SMODS.Font {
  key = "plincoin",
  path = "plincoin2.ttf"
}

-- Properly init perkeocoin stuff to be compatible with existing save files
function init_perkeocoin(game)

  game.plincoins = game.plincoins or 0
  game.balls_dropped = game.balls_dropped or 0
  game.plincoins_per_round = game.plincoins_per_round or PlinkoLogic.s.plincoins_per_round
  game.current_round.plincoins = game.current_round.plincoins or 0

  game.current_round.plinko_roll_cost = game.current_round.plinko_roll_cost or PlinkoLogic.s.default_roll_cost
  game.current_round.plinko_rolls = game.current_round.plinko_rolls or 0
  game.current_round.plinko_cost_reset = game.current_round.plinko_cost_reset or {ante_left = 2, rounds_left = 0}
  game.rolls_to_up_cost = game.rolls_to_up_cost or PlinkoLogic.s.rolls_to_up_cost
  game.current_round.plinko_cost_up_in = game.rolls_to_up_cost

  if not game.plinko_rewards then
    game.plinko_rewards = {}
    for k, v in pairs(PlinkoLogic.rewards.per_rarity) do
      game.plinko_rewards[k] = v
    end
  end

  PlinkoLogic.STATE = PlinkoLogic.STATES.CLOSED
  PlinkoGame.yeet()
end


function add_round_eval_plincoins(config)
    local config = config or {}
    local width = G.round_eval.T.w - 0.51
    local num_dollars = config.plincoins or 1
    local scale = 0.9
    
    if not G.round_eval.divider_added then
    G.E_MANAGER:add_event(Event({
        trigger = 'after',delay = 0.25,
        func = function() 
            local spacer = {n=G.UIT.R, config={align = "cm", minw = width}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = {'......................................'}, colours = {G.C.WHITE},shadow = true, float = true, y_offset = -30, scale = 0.45, spacing = 13.5, font = G.LANGUAGES['en-us'].font, pop_in = 0})}}
            }}
            G.round_eval:add_child(spacer,G.round_eval:get_UIE_by_ID('bonus_round_eval'))
            return true
        end
    }))
  end
    delay(0.6)
    G.round_eval.divider_added = true

    delay(0.2)

        G.E_MANAGER:add_event(Event({
            trigger = 'before',delay = 0.5,
            func = function()
                --Add the far left text and context first:
                local left_text = {}
                if config.name == 'plincoins' then
                  table.insert(left_text, {n=G.UIT.T, config={text = config.plincoins, font = config.font, scale = 0.8*scale, colour = SMODS.Gradients.hpot_plincoin, shadow = true, juice = true}})
                  table.insert(left_text, {n=G.UIT.O, config={object = DynaText({string = {" "..localize{type = 'variable', key = 'hotpot_plincoins_cashout', vars = {G.GAME.plincoins_per_round or 0}}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}})
                end
                local full_row = {n=G.UIT.R, config={align = "cm", minw = 5}, nodes={
                    {n=G.UIT.C, config={padding = 0.05, minw = width*0.55, minh = 0.61, align = "cl"}, nodes=left_text},
                    {n=G.UIT.C, config={padding = 0.05,minw = width*0.45, align = "cr"}, nodes={{n=G.UIT.C, config={align = "cm", id = 'dollar_'..config.name},nodes={}}}}
                }}

                G.round_eval:add_child(full_row,G.round_eval:get_UIE_by_ID('bonus_round_eval'))
                play_sound('cancel', config.pitch or 1)
                play_sound('highlight1',( 1.5*config.pitch) or 1, 0.2)
                if config.card then config.card:juice_up(0.7, 0.46) end
                return true
            end
        }))
        local dollar_row = 0
        if num_dollars > 60 then
            G.E_MANAGER:add_event(Event({
                trigger = 'before',delay = 0.38,
                func = function()
                    G.round_eval:add_child(
                            {n=G.UIT.R, config={align = "cm", id = 'dollar_row_'..(dollar_row+1)..'_'..config.name}, nodes={
                                {n=G.UIT.O, config={object = DynaText({string = {localize('$')..num_dollars}, font = SMODS.Fonts.hpot_plincoin,colours = {G.C.MONEY}, shadow = true, pop_in = 0, scale = 0.65, float = true})}}
                            }},
                            G.round_eval:get_UIE_by_ID('dollar_'..config.name))

                    play_sound('coin3', 0.9+0.2*math.random(), 0.7)
                    play_sound('coin6', 1.3, 0.8)
                    return true
                end
            }))
        else
            for i = 1, num_dollars or 1 do
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',delay = 0.18 - ((num_dollars > 20 and 0.13) or (num_dollars > 9 and 0.1) or 0),
                    func = function()
                        if i%30 == 1 then 
                            G.round_eval:add_child(
                                {n=G.UIT.R, config={align = "cm", id = 'dollar_row_'..(dollar_row+1)..'_'..config.name}, nodes={}},
                                G.round_eval:get_UIE_by_ID('dollar_'..config.name))
                                dollar_row = dollar_row+1
                        end

                        local r = {n=G.UIT.T, config={text = localize('$'), font = SMODS.Fonts.hpot_plincoin, colour = G.C.MONEY, scale = ((num_dollars > 20 and 0.28) or (num_dollars > 9 and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true}}
                        play_sound('coin3', 0.9+0.2*math.random(), 0.7 - (num_dollars > 20 and 0.2 or 0))
                        
                        if config.name == 'blind1' then
                            G.GAME.current_round.dollars_to_be_earned = G.GAME.current_round.dollars_to_be_earned:sub(2)
                        end

                        G.round_eval:add_child(r,G.round_eval:get_UIE_by_ID('dollar_row_'..(dollar_row)..'_'..config.name))
                        G.VIBRATION = G.VIBRATION + 0.4
                        return true
                    end
                }))
            end
        end
      -- might cause issues. Dollars cashout adds up everything and sends "bottom" cashout. Might need similar implementation if more plincoin cashouts are added
      G.GAME.current_round.plincoins = G.GAME.current_round.plincoins + config.plincoins

end

local cuh = create_UIBox_HUD
function create_UIBox_HUD()
  local nodes = cuh()

  local contents_buttons = nodes.nodes[1].nodes[1].nodes[5].nodes[1].nodes[1].nodes

  local scale = 0.4
  local temp_col = G.C.DYN_UI.BOSS_MAIN
  local temp_col2 = G.C.DYN_UI.BOSS_DARK

  -- run_info
  contents_buttons[1].config.minh = 1
  -- options
  contents_buttons[2].config.minh = 1

  -- Literally dollars UI copypasted
  table.insert(contents_buttons, 2, {n=G.UIT.R, config={align = "cm"}, nodes={
      {n=G.UIT.C, config={align = "cm", padding = 0.05, minw = 1.55, minh = 1.15, colour = temp_col, emboss = 0.05, r = 0.1}, nodes={
        {n=G.UIT.R, config={align = "cm"}, nodes={
          {n=G.UIT.C, config={align = "cm", r = 0.1, minw = 1.25, minh = 1, colour = temp_col2}, nodes={
            {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.GAME, ref_value = 'plincoins', prefix = localize('$')}}, maxw = 1.2, colours = {G.C.MONEY}, font = SMODS.Fonts.hpot_plincoin, shadow = true,spacing = 2, bump = true, scale = 2.2*scale}), id = 'plincoin_text_UI'}}
          }},
        }},
      }},
    }})

  return nodes
end


