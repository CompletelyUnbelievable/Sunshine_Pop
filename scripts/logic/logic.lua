-- put logic functions here using the Lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
-- don't be afraid to use custom logic functions. it will make many things a lot easier to maintain, for example by adding logging.
-- to see how this function gets called, check: locations/locations.json
-- example:
function has_more_then_n_consumable(n)
    local count = Tracker:ProviderCountForCode('consumable')
    local val = (count > tonumber(n))
    if ENABLE_DEBUG_LOG then
        print(string.format("called has_more_then_n_consumable: count: %s, n: %s, val: %s", count, n, val))
    end
    if val then
        return 1 -- 1 => access is in logic
    end
    return 0 -- 0 => no access
end
function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

levelaccess = Tracker:FindObjectForCode("progression")
bluecoinsenabled = Tracker:FindObjectForCode("blue_coin_sanity")
coin_shine_enabled = Tracker:FindObjectForCode("coin_shine_enabled")

-- Shine Counter
function shines()
    return Tracker:ProviderCountForCode("shine")
end
function shinecount(targetshines)
    return shines() >= tonumber(targetshines)
end
function blues()
    return Tracker:ProviderCountForCode("blue")
end
function bluecount(targetblues)
    return blues() >= tonumber(targetblues)
end
function Boathousetrade()
    return Tracker:ProviderCountForCode("boat_maximum")
end
function hascoronashines()
    return Tracker:ProviderCountForCode("shine") >= Tracker:ProviderCountForCode("coronashines")
end

-- Moves
function spray()
    return has("fludd") --or has("nozzlespray")
end

function hover()
    return has("hover") --or has("nozzlehover")
end

function turbo()
   return has("turbo")
end

function rocket()
    return has("rocket")
end

-- Yoshi Logic

function yoshi()
    if has("yoshistart") == has("skip_pinna") then
        return has("yoshi")
    elseif has("yoshistart") == has("plaza_only") then
        return isPinnaEnterable() and asplasher()
    end
end

function skipPinnaYoshi()
    if has("yoshistart") == has("skip_pinna") then
        return has("yoshi")
    end
end
-- Specific conditions

function fiveshines()
	return shines() > 4
end

function postcoronastate() -- Function for post Corona plaza states such as Airstrip Entrance
	return hascoronashines()
end

-- General Items (or)

function splasher()
    return has("fludd") or has("hover")
end

function height()
    return has("hover") or has("rocket")
end

function speed()
    return has("fludd") or has("turbo")
end

function squirter()
    return has("fludd") or has("yoshi")
end

function skipintro() -- Is this meant to match "skip_into" from the AP?
    return has("nozzlefluddless")
end
-- General Items (and)

function asplasher()
    return has("fludd") and has("hover")
end

function aheight()
    return has("hover") and has("rocket")
end

function aspeed()
    return has("fludd") and has("turbo")
end

function asquirter()
    return has("fludd") and has("yoshi")
end

-- Progression Modes

function isVanilla()
    return has("progression") == has("progression_vanilla")
end

function isTicket()
    return has("progression") == has("progression_ticket")
end

-- Entrance Functions

function buggedEntryLogic(ticket) -- I had forgotten, but all level entry logic is screwed in SMS AP v0.4.3-alpha b/c entry requirements don't exist in ticket mode when fluddless at least.
	return skipintro() and ((type(ticket) == "string" and isTicket() and has(ticket)) or isVanilla())
end

-- Corona

function iscoronaenterable()
    return hascoronashines() and asplasher() --All requirements should actually be required unlike skip_into.
end

-- Bianco

function isBiancoEnterable() --Enterable without requirements while Fluddless (still needs Bianco ticket in ticket mode though) or enterable with hover start ticket mode Bianco ticket.
    --return syntax: (skipinto conditions) or ((entrance requirements) and ((ticket progression and has ticket) or (is vanilla progression and has shine count)))
    return (skipintro() and ((isTicket() and has("bianco")) or isVanilla())) or (has("nozzlehover") and isTicket() and has("bianco")) or (squirter() and ((isTicket() and has("bianco")) or isVanilla()))
end

-- Ricco

function isRiccoEnterable()
    --return syntax: (entrance requirements) and ((ticket progression and has ticket) or (is vanilla progression and has shine count))
    return buggedEntryLogic("ricco") or ((splasher() or yoshi()) and ((isTicket() and has("ricco")) or (isVanilla() and shines() > 2)))
end

-- Gelato

function isGelatoEnterable()
    --return syntax: (entrance requirements) and ((ticket progression and has ticket) or (is vanilla progression and has shine count))
    return buggedEntryLogic("gelato") or ((splasher() or yoshi()) and ((isTicket() and has("gelato")) or (isVanilla() and shines() > 4)))
end

-- Pinna

function isPinnaEnterable()
    --return syntax: (entrance requirements) and ((ticket progression and has ticket) or (is vanilla progression and has shine count))
    return buggedEntryLogic("pinna") or ((isTicket() and has("pinna")) or (isVanilla() and shines() > 9))
end

--Sirena

function isSirenaEnterable()
    --return syntax: (entrance requirements) and ((ticket progression and has ticket) or (is vanilla progression and has shine count))
    return buggedEntryLogic("sirena") or (has("yoshi") and ((isTicket() and has("sirena")) or isVanilla()))
end

--Noki

function isNokiEnterable()
    --return syntax: (entrance requirements) and ((ticket progression and has ticket) or (is vanilla progression and has shine count))
    return buggedEntryLogic("noki") or ((isTicket() and has("noki")) or (isVanilla() and shines() > 19))
end

-- Pianta

function isPiantaEnterable()
    --return syntax: (entrance requirements) and ((ticket progression and has ticket) or (is vanilla progression and has shine count))
    return buggedEntryLogic("pianta") or (has("rocket") and ((isTicket() and has("pianta")) or (isVanilla() and shines() > 9)))
end

-- Sub-Regions (Episode logic)

function bianco3()
	--return syntax: episodes in any order setting condition or (prior non-entrance region/location requirements and current region's requirements)
	return asplasher()
end

function bianco4()
	return bianco3() and height()
end

function bianco5()
	return bianco4() and height()
end

function bianco6()
	return bianco5() and spray()
end

function bianco7()
	return bianco6() and splasher()
end

function bianco8()
	return bianco7() and spray()
end

function ricco2()
	return spray()
end

function ricco3()
	return ricco2()
end

function ricco4()
	return ricco3() and height()
end

function ricco8()
	return ricco4() and spray()
end

function gelato4()
	return hover() and asplasher() --wiggler ahoy requires mirror madness
end

function gelato5() --eps 5-8.
	return gelato4() and hover()
end

function gelato6()
	return gelato5() and (hover() or turbo())
end

function pinna2()
	return spray()
end

function pinna5() --eps 5-8; req red pirate ships which requires beach cannon's secret.
	return pinna2() and (hover() and splasher()) and yoshi()
end

function pinna6()
	return pinna5() and asplasher()
end

function sirena2() --eps 2-8.
	return asplasher()
end

function sirena3() --eps 3-8.
	return sirena2() and (yoshi() and splasher())
end

function sirena4() --eps 4-5 and 4-8 blue coins.
	return sirena3() and asplasher()
end

function sirena5() --For blue coin.
	return sirena3() and asplasher()
end

function sirena6() --For blue coins.
	return sirena3() and asplasher()
end

function sirena7() --eps 7-8; yes ik this is the same function 4 times in a row but it is meant to help when things change.
	return sirena3() and asplasher()
end

function noki2() --blue coins eps 2 and 4-8.
	return asplasher()
end

function noki4() --blue coins eps 4 and 8.
	return asplasher()
end

function noki6() --blue coins eps 6-8.
	return asplasher()
end

function pianta2() --blue coins eps 2/4/6/8. No pianta1 function since it doesn't have any requirements.
	return rocket() and splasher()
end

function pianta3() --blue coins.
	return rocket() and spray()
end

function piantaonly5() --blue coins.
	return rocket() and splasher()
end

function pianta5() --eps 5-8.
	return yoshi()
end

function pianta6() --blue coins.
	return pianta5() and yoshi()
end

function pianta8() -- soak the sun and blue coin.
	return pianta5() and spray()
end

-- Boathouse

function BH(sAmount) -- Replaces BH1; sAmount meaning shine amount.
	sAmount = tonumber(sAmount)
	if not sAmount then
		sAmount = 1
	end
	return (has("blues") == has("blues_on") or has("blues_boathouse")) and blues() > ((sAmount * 10) - 1)
end

function BH2()
    return BH(2)
end

function BH3()
    return BH(3)
end

function BH4()
    return BH(4)
end
function BH5()
    return BH(5)
end

function BH6()
    return BH(6)
end

function BH7()
    return BH(7)
end

function BH8()
    return BH(8)
end

function BH9()
    return BH(9)
end

function BH10()
    return BH(10)
end

function BH11()
    return BH(11)
end

function BH12()
    return BH(12)
end

function BH13()
    return BH(13)
end

function BH14()
    return BH(14)
end

function BH15()
    return BH(15)
end

function BH16()
    return BH(16)
end

function BH17()
    return BH(17)
end

function BH18()
    return BH(18)
end

function BH19()
    return BH(19)
end

function BH20()
    return BH(20)
end

function BH21()
    return BH(21)
end

function BH22()
    return BH(22)
end

function BH23()
    return BH(23)
end

function BH24()
    return BH(24)
end

function BHT(sAmount)
	sAmount = tonumber(sAmount)
	if not sAmount then
		return Boathousetrade() > 0
	end
    return Boathousetrade() > sAmount
end

function B2()
    return BHT(1)
end

function B3()
    return BHT(2)
end

function B4()
    return BHT(3)
end

function B5()
    return BHT(4)
end

function B6()
    return BHT(5)
end

function B7()
    return BHT(6)
end

function B8()
    return BHT(7)
end

function B9()
    return BHT(8)
end

function B10()
    return BHT(9)
end

function B11()
    return BHT(10)
end

function B12()
    return BHT(11)
end

function B13()
    return BHT(12)
end

function B14()
    return BHT(13)
end

function B15()
    return BHT(14)
end

function B16()
    return BHT(15)
end

function B17()
    return BHT(16)
end

function B18()
    return BHT(17)
end

function B19()
    return BHT(18)
end

function B20()
    return BHT(19)
end

function B21()
    return BHT(20)
end

function B22()
    return BHT(21)
end

function B23()
    return BHT(22)
end

function B24()
    return BHT(23)
end

-- Episode Select

function allEpisodes()
    return has("episode1") or has("episode2") or has("episode3") or has("episode4") or has("episode5") or has("episode6") or has ("episode7") or has("episode8") or has("allepisodes")
end