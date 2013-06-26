--[[
	代码速查手册（Q区）
	技能索引：
		七星、奇才、奇才、奇策、奇袭、谦逊、潜袭、潜袭、强袭、巧变、巧说、琴音、青釭、青囊、倾城、倾国、倾国、求援、驱虎、权计、权计、劝谏
]]--
--[[
	技能名：七星
	相关武将：神·诸葛亮
	描述：分发起始手牌时，共发你十一张牌，你选四张作为手牌，其余的面朝下置于一旁，称为“星”；摸牌阶段结束时，你可以用任意数量的手牌等量替换这些“星”。
	引用：LuaQixing、LuaQixingStart、LuaQixingAsk、LuaQixingClear
	状态：验证通过
]]--
Exchange = function(shenzhuge)
	local stars = shenzhuge:getPile("stars")
	if stars:length() > 0 then
		local room = shenzhuge:getRoom()
		local n = 0
		while stars:length() > 0 do
			room:fillAG(stars, shenzhuge)
			local card_id = room:askForAG(shenzhuge, stars, true, "LuaQixing")
			shenzhuge:invoke("clearAG")
			if card_id == -1 then
				break
			end
			stars:removeOne(card_id)
			n = n + 1
			local card = sgs.Sanguosha:getCard(card_id)
			room:obtainCard(shenzhuge, card, false)
		end
		if n > 0 then
			local exchange_card = room:askForExchange(shenzhuge, "LuaQixing", n)
			local subcards = exchange_card:getSubcards()
			for _,id in sgs.qlist(subcards) do
				shenzhuge:addToPile("stars", id, false)
			end
		end
	end
end
DiscardStar = function(shenzhuge, n, skillName)
	local room = shenzhuge:getRoom();
	local stars = shenzhuge:getPile("stars")
	for i = 1, n, 1 do
		room:fillAG(stars, shenzhuge)
		local card_id = room:askForAG(shenzhuge, stars, false, "qixing-discard")
		shenzhuge:invoke("clearAG")
		stars:removeOne(card_id)
		local card = sgs.Sanguosha:getCard(card_id)
		room:throwCard(card, nil, nil)
	end
end
LuaQixing = sgs.CreateTriggerSkill{
	name = "LuaQixing",  
	frequency = sgs.Skill_Frequent, 
	events = {sgs.EventPhaseEnd, sgs.EventLoseSkill}, 
	on_trigger = function(self, event, player, data) 
		if event == sgs.EventPhaseEnd then
			if player:hasSkill(self:objectName()) then
				local stars = player:getPile("stars")
				if stars:length() > 0 then
					if player:getPhase() == sgs.Player_Draw then
						Exchange(player)
					end
				end
			end
		elseif event == EventLoseSkill then
			local name = data:toString()
			if name == self:objectName() then
				player:removePileByName("stars")
			end
		end
		return false
	end, 
	can_trigger = function(self, target)
		return (target ~= nil)
	end
}
LuaQixingStart = sgs.CreateTriggerSkill{
	name = "#LuaQixingStart", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:setPlayerMark(player, "qixingOwner", 1)
		for i = 1, 7, 1 do
			local id = room:drawCard()
			player:addToPile("stars", id, false)
		end
		Exchange(player)
	end,
	priority = -1
}
LuaQixingAsk = sgs.CreateTriggerSkill{
	name = "#LuaQixingAsk",  
	frequency = sgs.Skill_Frequent, 
	events = {sgs.EventPhaseStart},  
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			local stars = player:getPile("stars")
			if stars:length() > 0 then
				if player:hasSkill("kuangfeng") then
					room:askForUseCard(player, "@@kuangfeng", "@kuangfeng-card")
				end
			end
			stars = player:getPile("stars")
			if stars:length() > 0 then
				if player:hasSkill("dawu") then
					room:askForUseCard(player, "@@dawu", "@dawu-card")
				end
			end
		end
		return false
	end
}
LuaQixingClear = sgs.CreateTriggerSkill{
	name = "#LuaQixingClear", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.Death, sgs.EventPhaseStart}, 
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Death then
			local players = room:getAllPlayers()
			for _,dest in sgs.qlist(players) do
				dest:loseAllMarks("@gale")
				dest:loseAllMarks("@fog")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				local players = room:getAllPlayers()
				for _,dest in sgs.qlist(players) do
					if dest:getMark("@gale") > 0 then
						dest:loseMark("@gale")
					end
					if dest:getMark("@fog") > 0 then
						dest:loseMark("@fog")
					end
				end
			end
		end
		return false
	end, 
	can_trigger = function(self, target)
		if target then
			return target:getMark("qixingOwner") > 0
		end
		return false
	end, 
	priority = 3
}
--[[
	技能名：奇才（锁定技）
	相关武将：标准·黄月英
	描述：你使用锦囊牌无距离限制。你装备区里除坐骑牌外的牌不能被其他角色弃置。 
]]--
--[[
	技能名：奇才（锁定技）
	相关武将：怀旧-标准·黄月英-旧、SP·台版黄月英
	描述：你使用锦囊牌时无距离限制。
	引用：LuaQicai
	状态：验证通过
]]--
LuaQicai = sgs.CreateTargetModSkill{
	name = "LuaQicai",
	pattern = "TrickCard",
	distance_limit_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 1000
		end
	end,
}
--[[
	技能名：奇策
	相关武将：二将成名·荀攸
	描述：出牌阶段限一次，你可以将你的所有手牌（至少一张）当任意一张非延时锦囊牌使用。
]]--
--[[
	技能名：奇袭
	相关武将：标准·甘宁、SP·台版甘宁
	描述：你可以将一张黑色牌当【过河拆桥】使用。
	引用：LuaQixi
	状态：验证通过
]]--
LuaQixi = sgs.CreateViewAsSkill{
	name = "LuaQixi",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack()
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return nil
		end
		if #cards == 1 then
			local card = cards[1]
			local acard = sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber())
			acard:addSubcard(card:getId())
			acard:setSkillName(self:objectName())
			return acard
		end
	end
}
--[[
	技能名：谦逊（锁定技）
	相关武将：标准·陆逊、国战·陆逊、SP·台版陆逊
	描述：你不能被选择为【顺手牵羊】和【乐不思蜀】的目标。
	引用：LuaQianxun
	状态：0224验证通过
]]--
LuaQianxun = sgs.CreateProhibitSkill{
	name = "LuaQianxun", 
	is_prohibited = function(self, from, to, card)
		return card:isKindOf("Snatch") or card:isKindOf("Indulgence")
	end
}
--[[
	技能名：潜袭
	相关武将：一将成名2012·马岱
	描述：准备阶段开始时，你可以进行一次判定，然后令一名距离为1的角色不能使用或打出与判定结果颜色相同的手牌，直到回合结束。
]]--
--[[
	技能名：潜袭
	相关武将：怀旧-一将2·马岱-旧
	描述：每当你使用【杀】对距离为1的目标角色造成伤害时，你可以进行一次判定，若判定结果不为红桃，你防止此伤害，改为令其减1点体力上限。
	引用：LuaQianxi
	状态：验证通过
]]--
LuaQianxi = sgs.CreateTriggerSkill{
	name = "LuaQianxi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local victim = damage.to
		local card = damage.card
		if card then
			if card:isKindOf("Slash") then
				if player:distanceTo(victim) <= 1 then
					if room:askForSkillInvoke(player, "LuaQianxi", data) then
						local judge=sgs.JudgeStruct()
						judge.pattern=sgs.QRegExp("(.*):(heart):(.*)")
						judge.good=false
						judge.reason=self:objectName()
						judge.who=player
						room:judge(judge)
						if judge:isGood() then
							room:loseMaxHp(victim)
							return true
						end
					end
				end
			end
		end
	end
}
--[[
	技能名：强袭
	相关武将：火·典韦
	描述：出牌阶段限一次，你可以失去1点体力或弃置一张武器牌，并选择你攻击范围内的一名角色，对其造成1点伤害。
	引用：LuaQiangxi
	状态：0610验证通过
]]--
LuaQiangxiCard = sgs.CreateSkillCard{
	name = "LuaQiangxiCard", 
	target_fixed = false, 
	will_throw = true,
	filter = function(self, targets, to_select) 
		if #targets ~= 0 then return false end
		local rangefix = 0
		if (not self:getSubcards():isEmpty()) and sgs.Self:getWeapon() and (sgs.Self:getWeapon():getId() == self:getSubcards():first()) then
			local card = sgs.Self:getWeapon():getRealCard():toWeapon()
			rangefix = rangefix + card:getRange() - 1
		end
		return sgs.Self:distanceTo(to_select, rangefix) <= sgs.Self:getAttackRange()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		if self:getSubcards():isEmpty() then room:loseHp(effect.from) end
		room:damage(sgs.DamageStruct("LuaQiangxi", effect.from, effect.to))
	end
}
LuaQiangxi = sgs.CreateViewAsSkill{
	name = "LuaQiangxi", 
	n = 1, 
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return to_select:isKindOf("Weapon")
		end
		return false
	end, 
	view_as = function(self, cards) 
		if #cards == 0 then
			return LuaQiangxiCard:clone()
		elseif #cards == 1 then
			local card = LuaQiangxiCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaQiangxiCard")
	end
}

--[[
	技能名：巧变
	相关武将：山·张郃
	描述：你可以弃置一张手牌，跳过你的一个阶段（回合开始和回合结束阶段除外），若以此法跳过摸牌阶段，你获得其他至多两名角色各一张手牌；若以此法跳过出牌阶段，你可以将一名角色装备区或判定区里的一张牌移动到另一名角色区域里的相应位置。
	引用：LuaQiaobian
	状态：验证通过
]]--
LuaQiaobianCard = sgs.CreateSkillCard{
	name = "LuaQiaobianCard", 
	target_fixed = false, 
	will_throw = false, 
	filter = function(self, targets, to_select)
		local phase = sgs.Self:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			if to_select:objectName() ~= sgs.Self:objectName() then
				if not to_select:isKongcheng() then
					return #targets < 2
				end
			end
		elseif phase == sgs.Player_Play then
			if #targets == 0 then
				if to_select:getJudgingArea():length() >0 then
					return true
				end
				return to_select:getEquips():length() > 0
			end
		end
		return false
	end,
	feasible = function(self, targets)
		local phase = sgs.Self:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			if #targets > 0 then
				return #targets <= 2
			end
		elseif phase == sgs.Player_Play then
			return #targets == 1
		end
		return false
	end,
	on_use = function(self, room, source, targets) 
		local phase = source:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			if #targets > 0 then
				local move1 = sgs.CardsMoveStruct()
				local id1 = room:askForCardChosen(source, targets[1], "h", self:objectName())
				move1.card_ids:append(id1)
				move1.to = source
				move1.to_place = sgs.Player_PlaceHand
				if #targets == 2 then
					local move2 = sgs.CardsMoveStruct()
					local id2 = room:askForCardChosen(source, targets[2], "h", self:objectName())
					move2.card_ids:append() 
					move2.to = source
					move2.to_place = Player_PlaceHand
					room:moveCardsAtomic(move2, false)
				end
				room:moveCardsAtomic(move1, false)
			end
		elseif phase == sgs.Player_Play then
			if #targets > 0 then
				local from = targets[1]
				if from:hasEquip() or from:getJudgingArea():length() > 0 then
					local card_id = room:askForCardChosen(source, from, "ej", self:objectName())
					local card = sgs.Sanguosha:getCard(card_id)
					local place = room:getCardPlace(card_id)
					local equip_index = -1
					if place == sgs.Player_PlaceEquip then
						local equip = card:getRealCard()
						equip_index = equip:location()
					end
					local tos = sgs.SPlayerList()
					local list = room:getAlivePlayers()
					for _,p in sgs.qlist(list) do
						if equip_index ~= -1 then
							if p:getEquip(equip_index) then
								tos:append(p)
							end
						else
							if not source:isProhibited(p, card) and not p:containsTrick(card:objectName()) then
								tos:append(p)
							end
						end
					end
					local tag = sgs.QVariant()
					tag.setValue(from)
					room:setTag("QiaobianTarget", tag)
					local to = room:askForPlayerChosen(source, tos, "qiaobian")
					if to then
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), self:objectName(), "")
						room:moveCardTo(card, from, to, place, reason)
					end
					room:removeTag("QiaobianTarget")
				end
			end
		end
	end
}
LuaQiaobianVS = sgs.CreateViewAsSkill{
	name = "LuaQiaobian", 
	n = 0, 
	view_as = function(self, cards) 
		return LuaQiaobianCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@qiaobian"
	end
}
LuaQiaobian = sgs.CreateTriggerSkill{
	name = "LuaQiaobian", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.EventPhaseChanging}, 
	view_as_skill = LuaQiaobianVS, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		local change = data:toPhaseChange()
		local nextphase = change.to
		room:setPlayerMark(player, "qiaobianPhase", nextphase)
		local index = 0
		if nextphase == sgs.Player_Judge then
			index = 1
		elseif nextphase == sgs.Player_Draw then
			index = 2
		elseif nextphase == sgs.Player_Play then
			index = 3
		elseif nextphase == sgs.Player_Discard then
			index = 4
		end
		local discard_prompt = string.format("#qiaobian-%d", index)
		local use_prompt = string.format("@qiaobian-%d", index)
		if index > 0 then
			if room:askForDiscard(player, self:objectName(), 1, 1, true, false, discard_prompt) then
				if not player:isSkipped(nextphase) then
					if index == 2 or index == 3 then
						room:askForUseCard(player, "@qiaobian", use_prompt, index)
					end
				end
				player:skip(nextphase)
			end
		end
		return false
	end, 
	can_trigger = function(self, target)
		if target then
			if target:hasSkill(self:objectName()) and target:isAlive() then
				return not target:isKongcheng()
			end
		end
		return false
	end
}
--[[
	技能名：巧说
	相关武将：一将成名2013·简雍
	描述：出牌阶段开始时，你可以与一名角色拼点：若你赢，本回合你使用的下一张基本牌或非延时类锦囊牌可以增加一个额外目标（无距离限制）或减少一个目标（若原有多余一个目标）；若你没赢，你不能使用锦囊牌，直到回合结束。
]]--
--[[
	技能名：琴音
	相关武将：神·周瑜
	描述：当你于弃牌阶段内弃置了两张或更多的手牌后，你可以令所有角色各回复1点体力或各失去1点体力。每阶段限一次。
	引用：LuaQinyin
	状态：验证通过
]]--
perform = function(player, skill_name)
	local room = player:getRoom()
	local result = room:askForChoice(player, skill_name, "up+down")
	local all_players = room:getAllPlayers()
	if result == "up" then
		for _,p in sgs.qlist(all_players) do
			local recover = sgs.RecoverStruct()
			recover.who = player
			room:recover(p, recover)
		end
	elseif result == "down" then
		for _,p in sgs.qlist(all_players) do
			room:loseHp(p)
		end
	end
end
LuaQinyin = sgs.CreateTriggerSkill{
	name = "LuaQinyin", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseStart}, 
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Discard then
			if event == sgs.CardsMoveOneTime then
				local move = data:toMoveOneTime()
				local source = move.from
				if source:objectName() == player:objectName() then
					if move.to_place == sgs.Player_DiscardPile then
						local count = player:getMark("qinyin")
						count = count + move.card_ids:length()
						player:setMark("qinyin", count)
					end
					if not player:hasFlag("qinyin_used") then
						if player:getMark("qinyin") >= 2 then
							if player:askForSkillInvoke(self:objectName()) then
								local room = player:getRoom()
								room:setPlayerFlag(player, "qinyin_used")
								perform(player, self:objectName())
							end
						end
					end
				end
			elseif event == sgs.EventPhaseStart then
				player:setMark("qinyin", 0)
			end
		end
		return false
	end
}
--[[
	技能名：青釭
	相关武将：长坂坡·神赵云
	描述：你每造成1点伤害，你可以让目标选择弃掉一张手牌或者让你从其装备区获得一张牌。 
]]--
--[[
	技能名：青囊
	相关武将：标准·华佗
	描述： 出牌阶段限一次，你可以弃置一张手牌并选择一名已受伤的角色，令该角色回复1点体力。 
	引用：LuaQingnang
	状态：0610验证通过
]]--
LuaQingnangCard = sgs.CreateSkillCard{
	name = "LuaQingnangCard",
	target_fixed = false, 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return (#targets == 0) and (to_select:isWounded())
	end,
	feasible = function(self, targets)
		if #targets == 1 then
			return targets[1]:isWounded()
		end
		return false
	end,
	on_use = function(self, room, source, targets) 
		local target = targets[1]
		local effect = sgs.CardEffectStruct()
		effect.card = self
		effect.from = source
		effect.to = target
		room:cardEffect(effect)
	end,
	on_effect = function(self, effect) 
		local dest = effect.to
		local room = dest:getRoom()
		local recover = sgs.RecoverStruct()
		recover.card = self
		recover.who = effect.from
		room:recover(dest, recover)
	end
}
LuaQingnang = sgs.CreateViewAsSkill{
	name = "LuaQingnang", 
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end, 
	view_as = function(self, cards)
		if #cards ==1 then
			local card = cards[1]
			local qn_card = LuaQingnangCard:clone()
			qn_card:addSubcard(card)
			return qn_card
		end
	end, 
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "h") and (not player:hasUsed("#LuaQingnangCard"))
	end
}

--[[
	技能名：倾城
	相关武将：国战·邹氏
	描述：出牌阶段，你可以弃置一张装备牌，令一名其他角色的一项武将技能无效，直到其下回合开始。
	状态：尚未完成
]]--
LuaXQingchengCard = sgs.CreateSkillCard{--倾城
	name = "LuaXQingchengCard", 
	will_throw = false, 
	handling_method = sgs.Card_MethodDiscard, 
	filter = function(self, targets, to_select) 
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_effect = function(self, effect) 
		local room = effect.from:getRoom()
		local skill_list = {}
		local skills = effect.to:getVisibleSkillList()
		for _,skill in sgs.qlist(skills) do
			if not table.contains(skill_list, skill:objectName()) then
				if not skill:inherits("SPConvertSkill") then
					if not skill:isAttachedLordSkill() then
						table.insert(skill_list, skill:objectName())
					end
				end
			end
		end
		local skill_qc
		if #skill_list > 0 then
			local ai_data = sgs.QVariant()
			ai_data:setValue(effect.to)
			local choices = table.concat(skill_list, "+")
			skill_qc = room:askForChoice(effect.from, "LuaXQingcheng", choices, ai_data)
		end
		room:throwCard(self, effect.from)
		if skill_qc ~= "" then
			local card_ids = {}--用了“Table”的办法，应该没什么Bug...
			table.insert(card_ids, skill_qc) 	
			local card_id = table.concat(card_ids, "+")
			effect.to:setTag("QingchengList", sgs.QVariant(card_id))
			local mark = "Qingcheng"..skill_qc
			room:setPlayerMark(effect.to, mark, 1)
			local cards = effect.to:getCards("he")
			room:filterCards(effect.to, cards, true)
		end
	end
}
LuaXQingchengVS = sgs.CreateViewAsSkill{
	name = "LuaXQingcheng", 
	n = 1, 
	view_filter = function(self, selected, to_select)
		if to_select:isKindOf("EquipCard") then
			return not sgs.Self:isJilei(to_select)
		end
		return false
	end, 
	view_as = function(self, cards) 
		if #cards == 1 then
			local first = LuaXQingchengCard:clone()
			first:addSubcard(cards[1])
			first:setSkillName(self:objectName())
			return first
		end
	end, 
	enabled_at_play = function(self, player)
		return not player:isNude()
	end
}
LuaXQingcheng = sgs.CreateTriggerSkill{
	name = "LuaXQingcheng",  
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.EventPhaseStart},  
	view_as_skill = LuaXQingchengVS, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			local guzhu_list = player:getTag("QingchengList"):toString()
			guzhu_list = guzhu_list:split("+")
			for _,id in ipairs(guzhu_list) do
				local mark = "Qingcheng"..id
				room:setPlayerMark(player, mark, 0)
			end  
			player:setTag("QingchengList", sgs.QVariant())   
			local cards = player:getCards("he")
			room:filterCards(player, cards, false)
		end
		return false
	end, 
	can_trigger = function(self, target)
		return target 
	end, 
	priority = 4
}
--[[
	技能名：倾国
	相关武将：标准·甄姬、SP·甄姬、SP·台版甄姬
	描述：你可以将一张黑色手牌当【闪】使用或打出。
	引用：LuaQingguo
	状态：验证通过
]]--
LuaQingguo = sgs.CreateViewAsSkill{
	name = "LuaQingguo", 
	n = 1, 
	view_filter = function(self, selected, to_select)
		if to_select:isBlack() then
			return not to_select:isEquipped()
		end
		return false
	end, 
	view_as = function(self, cards) 
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local jink = sgs.Sanguosha:cloneCard("jink", suit, point)
			jink:setSkillName(self:objectName())
			jink:addSubcard(id)
			return jink
		end
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "jink"
	end
}
--[[
	技能名：倾国
	相关武将：1v1·甄姬1v1
	描述：你可以将一张装备区的装备牌当【闪】使用或打出。
]]--
--[[
	技能名：求援
	相关武将：一将成名2013·伏皇后
	描述：每当你成为【杀】的目标时，你可以令一名除此【杀】使用者外的有手牌的其他角色正面朝上交给你一张手牌。若此牌不为【闪】，该角色也成为此【杀】的目标。
]]--
--[[
	技能名：驱虎
	相关武将：火·荀彧
	描述：出牌阶段限一次，你可以与一名当前的体力值大于你的角色拼点：若你赢，其对其攻击范围内你选择的另一名角色造成1点伤害。若你没赢，其对你造成1点伤害。
	引用：LuaQuhu
	状态：0610验证通过
]]--
LuaQuhuCard = sgs.CreateSkillCard{
	name = "LuaQuhuCard", 
	target_fixed = false, 
	will_throw = false, 
	filter = function(self, targets, to_select) 
		return (#targets == 0) and (to_select:getHp() > sgs.Self:getHp()) and (not to_select:isKongcheng())
	end,
	on_use = function(self, room, source, targets) 
		local tiger = targets[1]
		local success = source:pindian(tiger, self:objectName(), nil)
		if success then
			local players = room:getOtherPlayers(tiger)
			local wolves = sgs.SPlayerList()
			for _,player in sgs.qlist(players) do
				if tiger:inMyAttackRange(player) then
					wolves:append(player)
				end
			end
			if wolves:isEmpty() then
				return
			end
			local wolf = room:askForPlayerChosen(source, wolves, self:objectName(), "@quhu-damage:" .. tiger:objectName())
			room:damage(sgs.DamageStruct(self:objectName(), tiger, wolf))
		else
			room:damage(sgs.DamageStruct(self:objectName(), tiger, source))
		end
	end
}
LuaQuhu = sgs.CreateViewAsSkill{
	name = "LuaQuhu",
	n = 0,
	view_as = function()
		return LuaQuhuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#LuaQuhuCard")) and (not player:isKongcheng())
	end
}

--[[
	技能名：权计
	相关武将：一将成名·钟会
	描述：每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于你的武将牌上，称为“权”；每有一张“权”，你的手牌上限便+1。
	引用：LuaQuanji、LuaQuanjiKeep、LuaQuanjiRemove
	状态：验证通过
]]--
LuaQuanji = sgs.CreateTriggerSkill{
	name = "LuaQuanji", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.Damaged}, 
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local damage = data:toDamage()
			local x = damage.damage
			for i=1, x, 1 do
				room:drawCards(player, 1)
				if not player:isKongcheng() then
					local card_id = -1
					local handcards = player:handCards()
					if handcards:length() == 1 then
						room:getThread():delay(500)
						card_id = handcards:first()
					else
						local cards = room:askForExchange(player, self:objectName(), 1, false, "QuanjiPush")
						card_id = cards:getSubcards():first()
					end
					player:addToPile("power", card_id)
				end
			end
		end
	end
}
LuaQuanjiKeep = sgs.CreateMaxCardsSkill{
	name = "#LuaQuanjiKeep", 
	extra_func = function(self, target) 
		if target:hasSkill(self:objectName()) then
			local powers = target:getPile("power")
			return powers:length()
		end
	end
}
LuaQuanjiRemove = sgs.CreateTriggerSkill{
	name = "#LuaQuanjiRemove", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.EventLoseSkill}, 
	on_trigger = function(self, event, player, data)
		local name = data:toString()
		if name == "LuaQuanji" then
			player:removePileByName("power")
		end
		return false
	end, 
	can_trigger = function(self, target)
		return (target ~= nil)
	end
}
--[[
	技能名：权计
	相关武将：胆创·钟会
	描述：其他角色的回合开始时，你可以与该角色进行一次拼点。若你赢，该角色跳过回合开始阶段及判定阶段。 
]]--
--[[
	技能名：劝谏
	相关武将：3D织梦·沮授
	描述：出牌阶段，你可以交给一名其他角色一张【闪】，展示其一张手牌：若为【闪】，则你与该角色各摸一张牌。每阶段限一次。 
]]--
