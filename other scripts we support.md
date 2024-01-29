Before opening a ticket or reporting an issue, please [check here](https://github.com/EWANZO101/Bryan-Snaily-CAD-Integration/issues?q=is%3Aissue+is%3Aclosed) to see if someone has encountered a similar issue in the past.



# Scripts Compatible with Renzu Multicharacter
framework == ESX or qb core 

## 1. Bryan Snaily's New Citizen System
- **Script Name:** Bryan Snaily's New Citizen System
- **GitHub Repository:** [Bryan Snaily - New Citizen]([https://github.com/bryan_snaily/new_citizen](https://github.com/EWANZO101/Bryan-Snaily-CAD-Integration)
- **Compatibility Modification:**
- framework  ESX OR QB CORE 
  - Modify the `renzu_multicharacter/server/framework/main.lua` file.
  - Find the `Login` function.
  - Change the following...:
    ```lua
    Login = function(source, data, new, qbslot)
        local source = source
        if Config.framework == 'ESX' then
            TriggerEvent('esx:onPlayerJoined', source, Config.Prefix..data, new or nil)
            LoadPlayer(source)
        else
            if new then
                new.cid = data
                new.charinfo = {
                    firstname = new.firstname,
                    lastname = new.lastname,
                    birthdate = new.birthdate or new.dateofbirth,
                    gender = new.sex == 'm' and 0 or 1,
                    nationality = new.nationality
                }
                -- Insert This Here --
                exports['bryan_snaily']:InsertNewCitizen(new.charinfo.firstname, new.charinfo.lastname, new.charinfo.birthdate, new.charinfo.gender, new.charinfo.nationality)
                --
            end
            <...>
        end
    end
    ```
  - Save the changes.


----



## 2. D-Vehicle shop

Hello.

So in the file you've provided, you would need to locate `Vehicleshop.giveVehicle` function. Now these would be the changes you would want to make:

```lua
if Config.framework == "esx" or Config.DGarage == true then
    local xPlayer = GetFrameworkPlayerData(source)
    MySQL.Async.execute(
        'INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, price, category, categoryname, km, age, fuel, name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        { xPlayer.identifier,
            props.plate,
            json.encode(props), data.type, job, data.price, data.category, data.categorylabel, 0, os.time(), 100,
            data.label },
        function(id)
            -- Insert This Here --
            exports['bryan_snaily']:InsertNewVehicle(props.plate, data.name, xPlayer.get('firstname'), xPlayer.get('lastname'))
            --
        end
    )
else
    local player = QBCore.Functions.GetPlayer(source)
    MySQL.Async.execute(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, fakeplate, garage, fuel, engine, body, state, depotprice, drivingdistance, status, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        { player.PlayerData.license,
            player.PlayerData.citizenid,
            data.name,
            GetHashKey(data.name),
            json.encode(props.mods),
            props.plate,
            props.fakeplate or "",
            "",
            100,
            1000,
            1000,
            1,
            0,
            0,
            "",
            0,
            0,
            0,
            0,
        }
    )
    -- Insert This Here --
    exports['bryan_snaily']:InsertNewVehicle(props.plate, data.name, player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
    --
end

