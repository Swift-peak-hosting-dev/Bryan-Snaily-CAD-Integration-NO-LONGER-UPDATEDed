# Scripts Compatible with Renzu Multicharacter
framework == 'ESX or qb core ' 

## 1. Bryan Snaily's New Citizen System
- **Script Name:** Bryan Snaily's New Citizen System
- **GitHub Repository:** [Bryan Snaily - New Citizen]([https://github.com/bryan_snaily/new_citizen](https://github.com/EWANZO101/Bryan-Snaily-CAD-Integration)
- **Compatibility Modification:**
  - Modify the `renzu_multicharacter/server/framework/main.lua` file.
  - Find the `Login` function.
  - Add the following code block:
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

## 2. more coming soon 
- **Script Name:** Example Script
- **GitHub Repository:** [Example Script](https://github.com/example-script)
- **Compatibility Modification:**
  - Modify the relevant files following a similar pattern as demonstrated above.

