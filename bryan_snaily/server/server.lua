InsertNewCitizen = function(firstname, lastname, birthdate, gender, ethnicity, height, weight, hairColor, eyeColor, address)
    local formatedTable = FormatCitizenInsertData({
        firstname = firstname,
        lastname = lastname,
        birthdate = birthdate,
        gender = gender,
        ethnicity = ethnicity,
        height = height,
        weight = weight,
        hairColor = hairColor,
        eyeColor = eyeColor,
        address = address
    })

    if not formatedTable then
        print('[Error] Incorrect Citizen Data')
        return
    end

    PerformHttpRequest(string.format('%sadmin/import/citizens', Config.API.URL),
        function(errorCode, resultData, resultHeaders) end,
        'POST',
        json.encode({
            formatedTable
        }), {
            [Config.API.TOKEN_HEADER_NAME] = Config.API.TOKEN,
            ['Content-Type'] = 'application/json',
        }
    )
end

exports('InsertNewCitizen', InsertNewCitizen)

InsertNewWeapon = function(weaponHash, firstname, lastname)
    local formatedTable = FormatWeaponData({
        weaponHash = weaponHash,
        firstname = firstname,
        lastname = lastname
    })

    if not formatedTable then
        print('[Error] Incorrect Weapon Data')
        return
    end

    PerformHttpRequest(string.format('%sadmin/import/weapons', Config.API.URL),
        function(errorCode, resultData, resultHeaders) end,
        'POST',
        json.encode({
            formatedTable
        }),
        {
            [Config.API.TOKEN_HEADER_NAME] = Config.API.TOKEN,
            ['Content-Type'] = 'application/json',
        }
    )
end

exports('InsertNewWeapon', InsertNewWeapon)

InsertNewVehicle = function(plate, vehicleHash, firstname, lastname, color)
    local formatedTable = FormatVehicleData({
        plate = plate,
        vehicleHash = vehicleHash,
        firstname = firstname,
        lastname = lastname,
        color = color
    }) 

    if not formatedTable then
        print('[Error] Incorrect Vehicle Data')
        return
    end

    PerformHttpRequest(string.format('%sadmin/import/vehicles', Config.API.URL),
        function(errorCode, resultData, resultHeaders) end,
        'POST',
        json.encode({
            formatedTable
        }),
        {
            [Config.API.TOKEN_HEADER_NAME] = Config.API.TOKEN,
            ['Content-Type'] = 'application/json',
        }
    )
end

exports('InsertNewVehicle', InsertNewVehicle)

SetLicenseToCitizen = function(license, value, firstname, lastname)
    local citizenId = GetCitizenId(firstname, lastname)
    local licenseId = GetValueId('license', value)

    if not citizenId then
        print('[Error] Could not find character')
        return
    end

    if not licenseId then
        print('[Error] Could not find license type')
        return
    end

    PerformHttpRequest(string.format('%ssearch/actions/licenses/%s', Config.API.URL, citizenId),
        function(errorCode, resultData, resultHeaders) end,
        'PUT',
        json.encode({
            [license] = licenseId
        }),
        {
            [Config.API.TOKEN_HEADER_NAME] = Config.API.TOKEN,
            ['Content-Type'] = 'application/json',
        }
    )
end

exports('SetLicenseToCitizen', SetLicenseToCitizen)

IsCitizenRegistered = function(firstname, lastname)
    return GetCitizenId(firstname, lastname) ~= false
end

exports('IsCitizenRegistered', IsCitizenRegistered)

FormatCitizenInsertData = function(data)
    if not data.firstname or not data.lastname or not data.birthdate then
        return false
    end

    if data.gender and type(data.gender) == 'number' then
        data.gender = data.gender == 0 and 'Male' or 'Female'
    elseif data.gender and type(data.gender) == 'string' and string.len(data.gender) == 1 then
        data.gender = data.gender == 'm' and 'Male' or 'Female'
    end

    return {
        ['name'] = data.firstname,
        ['surname'] = data.lastname,
        ['dateOfBirth'] = string.format('%sT00:00:00.000Z', data.birthdate),
        ['gender'] = data.gender and GetValueId('gender', data.gender) or GetValueId('gender'),
        ['ethnicity'] = data.ethnicity and GetValueId('ethnicity', data.ethnicity) or GetValueId('ethnicity'),
        ['height'] = data.height and tostring(data.height) or nil,
        ['weight'] = data.weight and tostring(data.weight) or nil,
        ['hairColor'] = data.hairColor or nil,
        ['eyeColor'] = data.eyeColor or nil,
        ['address'] = data.address or nil
    }
end

FormatWeaponData = function(data)
    if not data.weaponHash or not data.firstname or not data.lastname then
        return false
    end

    return {
        ['modelId'] = GetValueId('weapon', data.weaponHash, 'hash'),
        ['registrationStatusId'] = GetValueId('license', Config.Defaults.registrationStatus),
        ['ownerId'] = GetCitizenId(data.firstname, data.lastname),
    }
end

FormatVehicleData = function(data)
    if not data.plate or not data.firstname or not data.lastname or not data.vehicleHash then
        return false
    end

    return {
        ['plate'] = data.plate,
        ['ownerId'] = GetCitizenId(data.firstname, data.lastname),
        ['modelId'] = GetValueId('vehicle', data.vehicleHash, 'hash'),
        ['registrationStatusId'] = GetValueId('license', Config.Defaults.registrationStatus),
        ['color'] = data.color or nil
    }
end

GetValueId = function(table, value, columnToCheck)
    local valueId

    PerformHttpRequest(string.format('%sadmin/values/%s', Config.API.URL, table), function(errorCode, resultData, resultHeaders)
        local resultDataJson = json.decode(resultData)

        for k, v in ipairs(resultDataJson[1].values) do
            if not value or (columnToCheck and v[columnToCheck] == value or v.value == value) then
                valueId = v.id
                break
            end
        end

        if valueId == nil then valueId = false end
    end, 'GET', json.encode({}), {
        [Config.API.TOKEN_HEADER_NAME] = Config.API.TOKEN,
        ['Content-Type'] = 'application/json',
    })

    while valueId == nil do Wait(10) end

    return valueId
end

GetCitizenId = function(firstname, lastname)
    local citizenId

    PerformHttpRequest(string.format('%sadmin/manage/citizens?query=%s+%s', Config.API.URL, firstname, lastname), function(errorCode, resultData, resultHeaders)
        local resultDataJson = json.decode(resultData)

        if resultDataJson and resultDataJson.totalCount > 0 then
            citizenId = resultDataJson.citizens[1].id
        else
            citizenId = false
        end
    end, 'GET', json.encode({}), {
        [Config.API.TOKEN_HEADER_NAME] = Config.API.TOKEN,
        ['Content-Type'] = 'application/json',
    })

    while citizenId == nil do Wait(10) end

    return citizenId
end