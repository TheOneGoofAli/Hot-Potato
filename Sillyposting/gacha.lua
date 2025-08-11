SMODS.Atlas({key = 'GachaMachines', px = 142, py = 190, path = 'Sillyposting/Gacha_Machines.png', atlas_table = "ASSET_ATLAS"}):register()

-- change this when new gacha machine to add the items
hpot_gamble = function()
    SMODS.add_card({key = "j_joker"})
end

-- Do you have the space to gamble?
hpot_can_gamble = function()
    return not next(SMODS.find_card("j_cavendish"))
end

G.UIDEF.gacha_button = function()
    local t = UIBox{definition = {n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR, minw = G.deck.T.w, minh = 1.2 }, nodes = {
		{ n = G.UIT.R, nodes = {{n = G.UIT.C, config = {align = "tm", minw = 2, minh = 1.2, padding = 0.1, r = 0.1, hover = true, colour = G.C.UI.BACKGROUND_DARK, shadow = true, button = "hpot_open_gacha", func = "hpot_can_gacha"}, nodes = {
			{n = G.UIT.R, config = { align = "bm", padding = 0, colour = G.C.CLEAR}, nodes = {
				{n = G.UIT.T, config = { text = "Gamble\n1 Key", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}
			    }
			}},
		}}}}}},
	config = {major = G.deck, align = 'tm', offset = { x = 0.15, y = -0.35 }, bond = 'Weak', colour = G.C.CLEAR}}
    return t
end

G.UIDEF.gacha_machine = function(pos)
    local t = UIBox{definition = {n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR, minw = G.deck.T.w, minh = 1.2 }, nodes = {
		{ n = G.UIT.O, config = {object = Sprite(0,0,2.84,3.8,G.ASSET_ATLAS["hpot_GachaMachines"], pos)}}}},
	config = {major = G.deck, align = 'tm', offset = { x = 0.15, y = -1.85 }, bond = 'Weak', colour = G.C.CLEAR}}
    return t
end

G.FUNCS.hpot_open_gacha = function(args)
    ease_keys(-1)
    hpot_gamble()
end

G.FUNCS.hpot_can_gacha = function(e)
	if G.GAME.current_round.keys >= 1 and hpot_can_gamble() then
		e.config.button = nil
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
	else
		e.config.button = "hpot_open_gacha"
		e.config.colour = G.C.GREEN
	end
end

-- Call this whenever the condition for having space to gamble would change. Already is called on keys.
update_gacha_button = function()
    if G.gacha_button then
        G.gacha_button:remove()
        G.gacha_button = UIBox({
            definition = G.UIDEF.gacha_button(),
            config = {type = "cm"}
        })
        G.gacha_button:recalculate()
    end
end
-- table of all gacha machines
hpot_gacha_machines = {
    [1] = {result = function() SMODS.add_card({key = "j_caino"}) end,
    condition = function() return false end,
    weight = 1,
    image_pos = { x = 0, y = 0}}
}
hpot_pick_machine = function()
    local total_weight = 0
    for _, v in ipairs(hpot_gacha_machines) do
        total_weight = total_weight + v.weight
    end
    local chosen_machine_weight = pseudorandom('hpot_gacha_machine_choice', 0, total_weight)
    local weight_bonus = 0
    for _, v in ipairs(hpot_gacha_machines) do
        if v.weight + weight_bonus >= chosen_machine_weight then
            return v
        else
            weight_bonus = weight_bonus + v.weight
        end
    end
end
hpot_create_gacha = function()
    local machine = hpot_pick_machine()
    hpot_gamble = machine.result
    hpot_can_gamble = machine.condition
    G.gacha_machine = UIBox({
        definition = G.UIDEF.gacha_machine(machine.image_pos),
        config = {type = "cm"}
    })
end